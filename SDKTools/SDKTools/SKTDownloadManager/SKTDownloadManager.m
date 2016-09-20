//
//  SKTDownloadManager.m
//  

//

#import "SKTDownloadManager.h"
#import "SKTDownloadBuilder.h"

#import "SKTDownloadManager+Additions.h"
#import "SKTDownloadManager+DatabaseManager.h"
#import "SKTDownloadManager+ResumeManager.h"
#import "SKTDownloadManager+DownloadSpeedMeasure.h"

#import "SKTGroupedDownloadOperation.h"

#import "SKTDownloadObjectHelper.h"

#import "AFNetworkReachabilityManager.h"

const int kFMRequestTimeoutAlertTag = 99;
const int kFMRequestErrorNetworkSomethingWentWrong = 100;

NSString* const kFMUserDicAcceptCellularDownload = @"kFMUserDicAcceptCellularDownload";

@interface SKTDownloadManager ()

//keeps all download/unzip operations
//each download operation will create it's own unzip operations if neccesary. download operations will have dependency of their unzip operations

@property(atomic, strong) SKTGroupedDownloadOperation *currentItem;
@property(atomic, strong, readwrite) NSMutableArray *downloadOperations;

@property(nonatomic, strong) NSTimer *downloadSpeedTimer;           //Timer for checking download speed.
@property(nonatomic, strong) NSMutableArray *downloadSpeeds;        //Array with the last speeds, used for calculating an average speed.

@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

@property (nonatomic, assign) AFNetworkReachabilityStatus previousReachabilityStatus;
@property (nonatomic, assign) AFNetworkReachabilityStatus currentReachabilityStatus;

@property (nonatomic, strong) UIAlertView *networkErrorAlert;
@end

@implementation SKTDownloadManager

#pragma mark - Init

+ (SKTDownloadManager *)sharedInstance {
    static dispatch_once_t onceToken = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    self.lock = [[NSRecursiveLock alloc] init];
    self.lock.name = @"SKTDownloadManagerLock";
    
    self.userDidAcceptCellularDownload = NO;
    self.previousReachabilityStatus = AFNetworkReachabilityStatusUnknown;
    self.currentReachabilityStatus = AFNetworkReachabilityStatusUnknown;
    
    _downloadOperations = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        self.previousReachabilityStatus = self.currentReachabilityStatus;
        self.currentReachabilityStatus = status;
        
        if (status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown) {
            //not reachable
            [self didLooseConnection];
        } else {
            [self didEstablishConnection];
        }
    }];
    
    return self;
}

- (void)dealloc {
    [self cancelSpeedCalculationTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Download Operations

//request downloads
- (void)requestDownloads:(NSArray *)downloads startAutomatically:(BOOL)shouldStart withDelegate:(id<SKTDownloadManagerDelegate>)delegate withDataSource:(id<SKTDownloadManagerDataSource>)dataSource {
    if (![downloads count]) {
        return;
    }
    
    self.downloadDelegate = delegate;
    self.downloadDataSource = dataSource;
    
    if (![SKTDownloadManager deviceHasEnoughSpaceForItems:downloads]) {
        //we dont have enough space, inform our delegate
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.downloadDelegate respondsToSelector:@selector(notEnoughDiskSpace)]) {
                [self.downloadDelegate notEnoughDiskSpace];
            }
        });
        return;
    }
    if (![SKTDownloadManager canStartDownload]) {
        //notify delegate that we cannot start the download, onboard mode.
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.downloadDelegate respondsToSelector:@selector(cannotStartDownload)]) {
                [self.downloadDelegate cannotStartDownload];
            }
        });
        return;
    }
    
    NSMutableArray *downloadOperations = [NSMutableArray array];
    
    NSMutableArray *mutableDownloads = [downloads mutableCopy];
    
    for (SKTDownloadObjectHelper *downloadHelper in downloads) {
        NSAssert([downloadHelper isKindOfClass:[SKTDownloadObjectHelper class]], @"%@ should be kind of class %@", downloadHelper, [[SKTDownloadObjectHelper class] description]);
        if (![self isDownloadHelperEnqueued:downloadHelper]) {
            SKTGroupedDownloadOperation *operation = [SKTDownloadBuilder groupedDownloadOperationForDownloadHelper:downloadHelper];
            [operation setDelegate:self];
            [downloadOperations addObject:operation];
        } else {
            [mutableDownloads removeObject:downloadHelper];
        }
    }
    
    [SKTDownloadManager storeDownloadObjects:mutableDownloads];
    
    BOOL shouldStartDownload = ![self.downloadOperations count]; //start download only if we dont have any items added, if we do just add them to the download queue
    
    BOOL isDownloadRunning = [self isDownloadRunning];
    if (isDownloadRunning) {
        shouldStartDownload = NO; //do not start another download if one is already running
    }
    
    [self.downloadOperations addObjectsFromArray:downloadOperations];
    
    //start off the first added opperation
    if (shouldStartDownload && [downloadOperations count]) {
        SKTGroupedDownloadOperation *operation = [downloadOperations objectAtIndex:0];
        self.currentItem = operation;
        if (shouldStart) {
            [operation start];
            [self startSpeedCalculationTimer];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.downloadDelegate respondsToSelector:@selector(didStartDownload)]) {
                    [self.downloadDelegate didStartDownload];
                }
            });
        }
    }
}

//Cancel all download and clear temporary files.
- (void)cancelDownload {
    NSArray *tempArray = [self.downloadOperations copy];
    for (SKTGroupedDownloadOperation *operation in tempArray) {
        if (operation.overallStateDownloadItem != SKTMapDownloadItemStatusFinished) {
            [operation cancel];
        }
    }
    
    [SKTDownloadManager removeDownloadObjects:[self downloadHelpersFromDownloadOperations:tempArray]];
    
    [self.downloadOperations removeAllObjects];
    self.currentItem = nil;
    [self cancelSpeedCalculationTimer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.downloadDelegate respondsToSelector:@selector(didCancelDownload)]) {
            [self.downloadDelegate didCancelDownload];
        }
    });
}

//Cancel download for a certain item
- (BOOL)cancelDownloadForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    BOOL cancelled = NO;

    NSArray *operationsToCancel = [self operationsForDownloadHelper:downloadHelper];
    SKTGroupedDownloadOperation *currentRunningOperation = [self currentGroupedOperation];
    
    if ([operationsToCancel count]) {
        //remove operations for canceled item
        BOOL isCurrentItem = NO;
        BOOL shouldResumeNextItem = NO;
        
        SKTGroupedDownloadOperation *operationToCancel = [operationsToCancel objectAtIndex:0];
        
        BOOL isDownloadRunning = [self isDownloadRunning];
        cancelled = [operationToCancel cancel];
        if (cancelled) {
            isCurrentItem = (currentRunningOperation.downloadHelper == downloadHelper);
            
            //if the download is manually paused then we dont resume the download after a cancel.
            shouldResumeNextItem = (isDownloadRunning && isCurrentItem);
            
            [self.downloadOperations removeObject:operationToCancel];
            
            [SKTDownloadManager removeDownloadObjects:[self downloadHelpersFromDownloadOperations:operationsToCancel]];
            
            //check to see if we finished all downloads or not
            if ([self countDownloadHelpersNotFullyDownloaded] == 0) { //finished all downloads
                [[self downloadOperations] removeAllObjects];
                [self cancelSpeedCalculationTimer];
                self.currentItem = nil;
            } else {
                //we have remaining downloads
                //if the current item is the one canceled then get the next one and resume it
                
                if (isCurrentItem && shouldResumeNextItem) {
                    self.currentItem = [self getNextDownloadOperationToDownloadIncludePausedDownload:NO];
                }
                if (self.currentItem && shouldResumeNextItem) {
                    [[self currentItem] resume];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.downloadDelegate respondsToSelector:@selector(downloadManager:didCancelDownloadForDownloadHelper:)]) {
                    [self.downloadDelegate downloadManager:self didCancelDownloadForDownloadHelper:downloadHelper];
                }
            });
        }
        
    }
    return cancelled;
}

//Pause download.
- (void)pauseDownload {
    SKTDownloadObjectHelper *currentMapItem = [[SKTDownloadManager sharedInstance] currentDownloadHelper];
    
    if ([[SKTDownloadManager sharedInstance] pauseDownloadForDownloadHelper:currentMapItem]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.downloadDelegate respondsToSelector:@selector(didPauseDownload)]) {
                [self.downloadDelegate didPauseDownload];
            }
        });
    }
}

// Pause download for item
- (BOOL)pauseDownloadForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    BOOL paused = NO;
    
    NSArray *operations = [self operationsForDownloadHelper:downloadHelper];
    if ([operations count]) {
        for (SKTGroupedDownloadOperation *operation in operations) {
            paused = [operation pause];
            if (paused) {
                [self cancelSpeedCalculationTimer];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.downloadDelegate respondsToSelector:@selector(downloadManager:didPauseDownloadForDownloadHelper:)]) {
                        [self.downloadDelegate downloadManager:self didPauseDownloadForDownloadHelper:downloadHelper];
                    }
                });
            }
        }
    }
    return paused;
}

//Resume download.
- (void)resumeDownload {
    if (![SKTDownloadManager canStartDownload]) {
        //notify delegate that we cannot start the download, onboard mode.
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.downloadDelegate respondsToSelector:@selector(cannotStartDownload)]) {
                [self.downloadDelegate cannotStartDownload];
            }
        });
        return;
    }
    
    SKTDownloadObjectHelper *currentMapItem = [[SKTDownloadManager sharedInstance] currentDownloadHelper];
    if ([[SKTDownloadManager sharedInstance] resumeDownloadForDownloadHelper:currentMapItem]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.downloadDelegate respondsToSelector:@selector(didResumeDownload)]) {
                [self.downloadDelegate didResumeDownload];
            }
        });
    }
}

- (BOOL)resumeDownloadForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    BOOL resumed = NO;
    
    if (![SKTDownloadManager canStartDownload]) {
        //notify delegate that we cannot start the download, onboard mode.
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.downloadDelegate respondsToSelector:@selector(cannotStartDownload)]) {
                [self.downloadDelegate cannotStartDownload];
            }
        });
        return resumed;
    }
    
    BOOL isDownloadRunning = [self isDownloadRunning];
    if (isDownloadRunning) {
        return resumed;
    }
    
    NSArray *operations = [self operationsForDownloadHelper:downloadHelper];
    
    if ([operations count]) {
        SKTGroupedDownloadOperation *operation = [operations objectAtIndex:0];
        resumed = [operation resume];
        if (resumed) {
            self.currentItem = operation;
            [self startSpeedCalculationTimer];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.downloadDelegate respondsToSelector:@selector(downloadManager:didResumeDownloadForDownloadHelper:)]) {
                    [self.downloadDelegate downloadManager:self didResumeDownloadForDownloadHelper:downloadHelper];
                }
            });
        }
    }
    return resumed;
}

+ (BOOL)canRestartDownload {
    return ![[SKTDownloadManager sharedInstance] isOnboardMode] && [[SKTDownloadManager storedDownloadObjects] count];
}

#pragma mark - Helpers

- (SKTGroupedDownloadOperation *)currentGroupedOperation {
    if (self.currentItem) {
        return self.currentItem;
    }
    return [self getNextDownloadOperationToDownloadIncludePausedDownload:YES];
}

- (SKTDownloadObjectHelper *)currentDownloadHelper {
    SKTGroupedDownloadOperation *grouped = [self currentGroupedOperation];
    return grouped.downloadHelper;
}

- (BOOL)isDownloadRunning {
    [self.lock lock];
    BOOL returnVal = NO;
    NSArray *tempOperations = [NSArray arrayWithArray:self.downloadOperations];
    
    for (SKTGroupedDownloadOperation *operation in tempOperations) {
        if ([operation overallStateDownloadItem] == SKTMapDownloadItemStatusDownloading || [operation overallStateDownloadItem] == SKTMapDownloadItemStatusInstalling || [operation overallStateDownloadItem] == SKTMapDownloadItemStatusProcessing) {
            returnVal = YES;
            break;
        }
    }
    
    [self.lock unlock];
    return returnVal;
}

- (BOOL)isUnzipping {
    [self.lock lock];
    BOOL returnVal = NO;
    NSArray *tempOperations = [NSArray arrayWithArray:self.downloadOperations];
    
    for (SKTGroupedDownloadOperation *operation in tempOperations) {
        if ([operation overallStateDownloadItem] == SKTMapDownloadItemStatusInstalling) {
            returnVal = YES;
            break;
        }
    }
    [self.lock unlock];
    return returnVal;
}

- (BOOL)isOnboardMode {
    BOOL isAppInOnboardMode = NO;
    if ([[self downloadDataSource] respondsToSelector:@selector(isOnBoardMode)]) {
        isAppInOnboardMode = [[self downloadDataSource] isOnBoardMode];
    }
    return isAppInOnboardMode;
}

+ (BOOL)canStartDownload {
    //can only start if not onboard and we have internet connection
    BOOL isReachable = [[AFNetworkReachabilityManager sharedManager] isReachable];
    BOOL isOnaboard = [[SKTDownloadManager sharedInstance] isOnboardMode];
    return !isOnaboard && isReachable;
}

- (BOOL)isDownloadPaused {
    [self.lock lock];
    BOOL returnVal = NO;
    NSArray *tempOperations = [NSArray arrayWithArray:self.downloadOperations];
    
    for (SKTGroupedDownloadOperation *operation in tempOperations) {
        if ([operation overallStateDownloadItem] == SKTMapDownloadItemStatusPaused) {
            returnVal = YES;
            break;
        }
    }
    [self.lock unlock];
    return returnVal;
}

- (NSUInteger)countDownloadHelpersNotFullyDownloaded {
    return [[self downloadOperationsNotFullyDownloaded] count];
}

- (NSArray*)downloadOperationsNotFullyDownloaded {
    [self.lock lock];
    
    NSMutableArray *notFullyDownloadedArray = [NSMutableArray array];
    NSArray *tempOperations = [NSArray arrayWithArray:self.downloadOperations];
    
    for (SKTGroupedDownloadOperation *operation in tempOperations) {
        if (![operation.downloadHelper isFullyDownloaded]) {
            [notFullyDownloadedArray addObject:operation];
        }
    }
    [self.lock unlock];
    return notFullyDownloadedArray;
}

- (NSArray *)downloadHelpersFromDownloadOperations:(NSArray *)downloadOperations {
    [self.lock lock];
    NSMutableArray *downloadHelpers = [NSMutableArray array];
    
    for (SKTGroupedDownloadOperation *operation in downloadOperations) {
        [downloadHelpers addObject:operation.downloadHelper];
    }
    [self.lock unlock];
    return downloadHelpers;
}

- (NSArray *)downloadHelpersFromDownloadOperationQueue {
    [self.lock lock];
    NSMutableArray *downloadHelpers = [NSMutableArray array];
    
    NSArray *tempOperations = [NSArray arrayWithArray:self.downloadOperations];
    
    for (SKTGroupedDownloadOperation *operation in tempOperations) {
        [downloadHelpers addObject:operation.downloadHelper];
    }
    [self.lock unlock];
    return downloadHelpers;
}

- (SKTGroupedDownloadOperation *)groupedOperationForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    [self.lock lock];
    SKTGroupedDownloadOperation *returnOperation = nil;
    NSArray *tempOperations = [NSArray arrayWithArray:self.downloadOperations];
    
    for (SKTGroupedDownloadOperation *operation in tempOperations) {
        if (operation.downloadHelper == downloadHelper) {
            returnOperation = operation;
            break;
        }
    }
    [self.lock unlock];
    return returnOperation;
}

- (NSArray *)operationsForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    [self.lock lock];
    NSArray *tempOperations = [NSArray arrayWithArray:self.downloadOperations];
    NSMutableArray *operations = [NSMutableArray array];
    
    for (SKTGroupedDownloadOperation *operation in tempOperations) {
        if (operation.downloadHelper == downloadHelper) {
            [operations addObject:operation];
        }
    }
    [self.lock unlock];
    return operations;
}

- (SKTGroupedDownloadOperation *)getNextDownloadOperationToDownloadIncludePausedDownload:(BOOL)includePaused {
    [self.lock lock];
    SKTGroupedDownloadOperation *returnOperation = nil;
    NSArray *tempOperations = [NSArray arrayWithArray:self.downloadOperations];
    for (SKTGroupedDownloadOperation *operation in tempOperations) {
        if (!includePaused && operation.overallStateDownloadItem != SKTMapDownloadItemStatusDownloading && operation.overallStateDownloadItem != SKTMapDownloadItemStatusInstalling && operation.overallStateDownloadItem != SKTMapDownloadItemStatusProcessing && operation.overallStateDownloadItem != SKTMapDownloadItemStatusFinished && operation.overallStateDownloadItem != SKTMapDownloadItemStatusPaused) {
            returnOperation = operation;
            break;
        } else if (includePaused && operation.overallStateDownloadItem == SKTMapDownloadItemStatusPaused) {
            returnOperation = operation;
            break;
        }
    }
    [self.lock unlock];
    return returnOperation;
}

- (BOOL)isDownloadHelperEnqueued:(SKTDownloadObjectHelper *)downloadHelper {
    [self.lock lock];
    BOOL returnValue = NO;
    NSArray *tempArray = [NSArray arrayWithArray:self.downloadOperations];
    for (int i = 0; i < tempArray.count; i++) {
        SKTGroupedDownloadOperation *groupOperation = [tempArray objectAtIndex:i];
        if ([groupOperation.downloadHelper compare:downloadHelper] == NSOrderedSame) {
            returnValue = YES;
            break;
        }
    }
    [self.lock unlock];
    return returnValue;
}

-(BOOL)changedWifiToCellular {
    BOOL changedWifiToCellular = NO;
    if (self.previousReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi && self.currentReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
        //changed from Wifi to cellular
        changedWifiToCellular = YES;
    }
    return changedWifiToCellular;
}

#pragma mark - Notification handlers

- (void)didEstablishConnection {
    BOOL changedWifiToCellular = [self changedWifiToCellular];
    
    if (changedWifiToCellular && !self.userDidAcceptCellularDownload) {
        //means the user did not approve downloads on cellular networks and we need to pause everything and alert the user to approve the download
        [self cancelSpeedCalculationTimer];
        [self pauseDownload];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.downloadDelegate respondsToSelector:@selector(downloadManagerSwitchedWifiToCellularNetwork:)]) {
                [self.downloadDelegate downloadManagerSwitchedWifiToCellularNetwork:self];
            }
        });
    }
    else if (![[SKTDownloadManager sharedInstance] isDownloadRunning] && ![[SKTDownloadManager sharedInstance] isDownloadPaused]) {
        //resume only if download was not manually paused and is not running
        [self startSpeedCalculationTimer];
        [self resumeDownloadForDownloadHelper:[[SKTDownloadManager sharedInstance] currentDownloadHelper]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.downloadDelegate respondsToSelector:@selector(downloadManager:internetAvailabilityChanged:)]) {
            [self.downloadDelegate downloadManager:self internetAvailabilityChanged:YES];
        }
    });
}

- (void)didLooseConnection {
    if (![[SKTDownloadManager sharedInstance] isDownloadRunning]) {
        //alredy paused
        return;
    }
    
    [self cancelSpeedCalculationTimer];
    
    //pause
    [self pauseDownload];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.downloadDelegate respondsToSelector:@selector(downloadManager:internetAvailabilityChanged:)]) {
            [self.downloadDelegate downloadManager:self internetAvailabilityChanged:NO];
        }
    });
}

- (void)appWillTerminate:(NSNotification *)note {
    [self cancelSpeedCalculationTimer];
    NSArray *downloadHelpers = [self downloadHelpersFromDownloadOperationQueue];
    [SKTDownloadManager storeDownloadObjects:downloadHelpers];
}

#pragma mark - SKTGroupedDownloadOperationDelegate

- (void)didReceiveTimeoutGroupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation {
    if (!self.networkErrorAlert) {
        self.networkErrorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fm_req_time_out_title", nil)
                                                            message:NSLocalizedString(@"fm_req_time_out_message", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"ok_btn_title_key" , nil)
                                                  otherButtonTitles:nil];
        [self.networkErrorAlert show];
    }
}

- (void)groupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation finishedWithSuccess:(BOOL)success {
    [SKTDownloadManager removeDownloadObjects:[NSArray arrayWithObject:groupedDownloadOperation.downloadHelper]];
    
    //start next one
    if (![self isDownloadRunning]) {
        SKTGroupedDownloadOperation *operation = [self getNextDownloadOperationToDownloadIncludePausedDownload:NO];

        [operation start];
        self.currentItem = operation;
    }
    
    if (!success) {
        [[self downloadOperations] removeObject:groupedDownloadOperation];
    }
    
    if ([self countDownloadHelpersNotFullyDownloaded] == 0) { //finished all downloads
        [[self downloadOperations] removeAllObjects];
        [self cancelSpeedCalculationTimer];
    } else {
        [self startSpeedCalculationTimer];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.downloadDelegate respondsToSelector:@selector(downloadManager:didDownloadDownloadHelper:withSuccess:)]) {
            NSAssert(groupedDownloadOperation.downloadHelper, @"groupedDownloadOperation.downloadHelper should not be null");
            [self.downloadDelegate downloadManager:self didDownloadDownloadHelper:groupedDownloadOperation.downloadHelper withSuccess:success];
        }
    });
}

- (void)didStartGroupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation {
    self.currentItem = groupedDownloadOperation;
}

- (void)didCancelGroupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation {
    [SKTDownloadManager removeDownloadObjects:[NSArray arrayWithObject:groupedDownloadOperation.downloadHelper]];
    self.currentItem = nil;
}

- (void)didPauseGroupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation {
    self.currentItem = groupedDownloadOperation;
}

- (void)didResumeGroupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation {
    self.currentItem = groupedDownloadOperation;
}

- (void)groupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation currentDownloadProgress:(NSString *)currentProgressString currentDownloadPercentage:(float)currentPercentage forDownloadHelper:(SKTDownloadObjectHelper *)currentDownloadHelper {
    
    NSDictionary *progressDictionary = [SKTDownloadManager downloadProgressDataForGroupedDownloadOperations:self.downloadOperations];
    NSString *overallProgressString = progressDictionary[kSKTDownloadOverallProgressString];
    NSNumber *overallPercentage = progressDictionary[kSKTDownloadOverallPercentage];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.downloadDelegate respondsToSelector:@selector(downloadManager:didUpdateCurrentDownloadProgress:currentDownloadPercentage:overallDownloadProgress:overallDownloadPercentage:forDownloadHelper:)]) {
            [self.downloadDelegate downloadManager:self didUpdateCurrentDownloadProgress:currentProgressString currentDownloadPercentage:currentPercentage overallDownloadProgress:overallProgressString overallDownloadPercentage:[overallPercentage floatValue] forDownloadHelper:currentDownloadHelper];
        }
    });
}

- (void)groupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation currentUnzipProgress:(NSString *)currentUnzipString currentUnzipPercentage:(float)currentUnzipPercentage {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.downloadDelegate respondsToSelector:@selector(downloadManager:didUpdateUnzipProgress:percentage:forDownloadHelper:)]) {
            [self.downloadDelegate downloadManager:self didUpdateUnzipProgress:currentUnzipString percentage:currentUnzipPercentage forDownloadHelper:groupedDownloadOperation.downloadHelper];
        }
    });
}

- (void)groupedDownloadOperationCanceledByOS:(SKTGroupedDownloadOperation *)groupedDownloadOperation {
    [self.lock lock];
    
    NSArray *tempOperations = [NSArray arrayWithArray:self.downloadOperations];
    for (SKTGroupedDownloadOperation *operation in tempOperations) {
        [operation setDelegate:nil];
    }
    
    //we should remove all the downloads from the queue
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray *notFinishedGroupedDownloadOperations = [self downloadOperationsNotFullyDownloaded];
        if ([notFinishedGroupedDownloadOperations count]) {
            [SKTDownloadManager storeDownloadObjects:[self downloadHelpersFromDownloadOperations:notFinishedGroupedDownloadOperations]];
        }
        
        [[self downloadOperations] removeAllObjects];
        
        [self cancelSpeedCalculationTimer];
        
        if ([self.downloadDelegate respondsToSelector:@selector(operationsCancelledByOSDownloadManager:)]) {
            [self.downloadDelegate operationsCancelledByOSDownloadManager:self];
        }
    });
    [[self lock] unlock];
}

- (void)groupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation saveDownloadHelperToDatabase:(SKTDownloadObjectHelper *)downloadHelper {
    if ([self.downloadDelegate respondsToSelector:@selector(downloadManager:saveDownloadHelperToDatabase:)]) {
        [self.downloadDelegate downloadManager:self saveDownloadHelperToDatabase:downloadHelper];
    }
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.networkErrorAlert = nil;
    [self cancelDownload];
}

@end
