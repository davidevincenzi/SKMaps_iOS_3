//
//  SKTGroupedDownloadOperation.m
//  
//

#import "SKTGroupedDownloadOperation.h"
#import "SKTGroupedOperations.h"
#import "SKTDownloadOperation.h"

#import "SKTDownloadManager+DatabaseManager.h"
#import "SKTDownloadManager+Additions.h"

@interface SKTGroupedDownloadOperation ()

@property (atomic, strong) NSMutableArray *groupedOperations;
@property (nonatomic, strong) SKTGroupedOperations *currentRunningGroupedOperation;
@property (nonatomic, strong) dispatch_queue_t queue;

@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

@end

@implementation SKTGroupedDownloadOperation

#pragma mark - Init

+ (instancetype)downloadGroupedOperation {
    return [[self alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        self.groupedOperations = [NSMutableArray array];
        
        self.overallPercentage = 0.;
        self.totalDownloadSize = 0;
        self.totalBytesDownloaded = 0;
        self.unzipPercentage = 0.;
        self.queue = dispatch_queue_create("com.skobbler.SKTGroupedDownloadOperation", NULL);
        
        self.overallStateDownloadItem = SKTMapDownloadItemStatusQueued;
        
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = @"SKTGroupedDownloadOperationLock";
    }
    return self;
}

#pragma mark - Public

- (BOOL)start {
    if (self.currentRunningGroupedOperation.stateDownloadItem >= SKTMapDownloadItemStatusDownloading) {
        return NO; //cannot start download,isntall, finsihed
    }
    
    [self.lock lock];
    
    if ([self.groupedOperations count]) {
        if (!self.currentRunningGroupedOperation) {
            SKTGroupedOperations *operation = [self.groupedOperations objectAtIndex:0];
            self.currentRunningGroupedOperation = operation;
        }
        [self.currentRunningGroupedOperation resume];
    }

    [self.lock unlock];
    return YES;
}

- (BOOL)pause {
    if (self.currentRunningGroupedOperation.stateDownloadItem == SKTMapDownloadItemStatusDownloading || self.currentRunningGroupedOperation.stateDownloadItem == SKTMapDownloadItemStatusInstalling) {
        
        [self.lock lock];
        
        if (self.currentRunningGroupedOperation) {
            [self.currentRunningGroupedOperation pause];
        }

        [self.lock unlock];
        return YES;
    }
    return NO;
}

- (BOOL)resume {
    if (self.currentRunningGroupedOperation.stateDownloadItem >= SKTMapDownloadItemStatusDownloading) {
        return NO; //cannot start download,isntall, finsihed
    }
    [self.lock lock];
    if (self.currentRunningGroupedOperation) {
        [self.currentRunningGroupedOperation resume];
    } else {
        [self start];
    }
    [self.lock unlock];

    return YES;
}

- (BOOL)cancel {
    if (self.overallStateDownloadItem == SKTMapDownloadItemStatusProcessing) { //cannot cancel an item in processing, multiple items with addOfflineMapPackage will get locked.
        return NO;
    }
    
    [self.lock lock];
    for (SKTGroupedOperations *groupedOp in self.groupedOperations) {
        [groupedOp cancel];
    }
    
    [self.groupedOperations removeAllObjects];
    
    if (self.currentRunningGroupedOperation) {
        self.currentRunningGroupedOperation = nil;
    }
    
    [SKTDownloadManager cleanupDownloadHelper:self.downloadHelper];
    [self.lock unlock];
    return YES;
}

- (void)addSKGroupedOperation:(SKTGroupedOperations *)groupedOperation {
    [self.lock lock];
    groupedOperation.queue = self.queue;
    
    self.downloadType = groupedOperation.downloadOperation.downloadType;
    [groupedOperation setDelegate:self];
    [self.groupedOperations addObject:groupedOperation];
    
    [self updateDownloadSizes];
    [self.lock unlock];
}

- (BOOL)isDownloading {
    for (SKTGroupedOperations *groupedOp in self.groupedOperations) {
        if ([groupedOp stateDownloadItem] == SKTMapDownloadItemStatusDownloading) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isUnzipping {
    for (SKTGroupedOperations *groupedOp in self.groupedOperations) {
        if ([groupedOp stateDownloadItem] == SKTMapDownloadItemStatusInstalling) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isPaused {
    for (SKTGroupedOperations *groupedOp in self.groupedOperations) {
        if (groupedOp.stateDownloadItem == SKTMapDownloadItemStatusPaused) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Private

- (void)updateDownloadSizes {
    float overallPercentage = 0;
    long long totalDownloadSize = 0;
    long long totalBytesDownloaded = 0;
    
    [self totalDownloadSize:&totalDownloadSize totalBytesDownloaded:&totalBytesDownloaded overallPercentage:&overallPercentage];
    
    overallPercentage = (float)(totalBytesDownloaded) / (float)(totalDownloadSize)*100;
    if (isnan(overallPercentage)) {
        overallPercentage = 0;
    }
    
    self.overallPercentage = overallPercentage;
    self.totalDownloadSize = totalDownloadSize;
    self.totalBytesDownloaded = totalBytesDownloaded;
    self.unzipPercentage = 0.;
}

- (void)totalDownloadSize:(long long *)totalDownloadSize totalBytesDownloaded:(long long *)totalBytesDownloaded overallPercentage:(float *)overallPercentage {
    NSArray *tempArray = [NSArray arrayWithArray:self.groupedOperations];
    for (int i = 0; i < [tempArray count]; i++) {
        SKTGroupedOperations *operation = [tempArray objectAtIndex:i];
        
        //current item
        *totalDownloadSize += operation.downloadOperation.totalBytesExpectedToReadForFile;
        *totalBytesDownloaded += operation.downloadOperation.totalBytesReadForFile;
    }
    
    *overallPercentage = *totalBytesDownloaded/(float)*totalDownloadSize;
    if (isnan(*overallPercentage)) {
        *overallPercentage = 0;
    }
}

- (SKTGroupedOperations *)groupedOperationWithState:(SKTMapDownloadItemStatus)state {
    NSArray *tempArray = [NSArray arrayWithArray:self.groupedOperations];
    for (int i = 0; i < [tempArray count]; i++) {
        SKTGroupedOperations *operation = [tempArray objectAtIndex:i];
        if ([operation stateDownloadItem] == state) {
            return operation;
        }
    }
    return nil;
}

#pragma mark - Others

- (SKTGroupedOperations *)getNextGroupedOperationToDownload {
    NSArray *tempOperations = [NSArray arrayWithArray:self.groupedOperations];
    for (SKTGroupedOperations *operation in tempOperations) {
        if (operation.stateDownloadItem != SKTMapDownloadItemStatusDownloading && operation.stateDownloadItem != SKTMapDownloadItemStatusInstalling && operation.stateDownloadItem != SKTMapDownloadItemStatusFinished && operation.stateDownloadItem != SKTMapDownloadItemStatusProcessing) {
            return operation;
        }
    }
    return nil;
}

- (long long)sampleSize {
    long long totalSampleSize = 0;
    
    NSArray *tempArray = [NSArray arrayWithArray:self.groupedOperations];
    
    for (int i = 0; i < [tempArray count]; i++) {
        SKTGroupedOperations *operation = [tempArray objectAtIndex:i];
        totalSampleSize += [operation sampleSize];
    }
    
    return totalSampleSize;
}

#pragma mark - SKGroupedOperationsDelegate

-(void)groupedOperationDidReceiveTimeout {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(didReceiveTimeoutGroupedDownloadOperation:)]) {
            [self.delegate didReceiveTimeoutGroupedDownloadOperation:self];
        }
    });
}

- (void)groupedOperation:(SKTGroupedOperations *)groupedOperation finishedWithSuccess:(BOOL)success {
    [self.lock lock];
    //start next group operation
    SKTGroupedOperations *operation = [self getNextGroupedOperationToDownload];
    if (operation && success) {
        
        self.currentRunningGroupedOperation = operation;
        [operation resume];
    } else {
        //finished
        
        //processing is a special state, since it can take awile until package is added to sdk and cleanup is made we need to check this and make sure the user is not pausing/resuming in this state.
        [self setOverallStateDownloadItem:SKTMapDownloadItemStatusProcessing];
        
        if (self.queue) {
            self.queue = NULL;
        }
        
        SKTDownloadObjectHelper *downloadHelper = self.downloadHelper;
        
        if (success) {
            if ([self.delegate respondsToSelector:@selector(groupedDownloadOperation:saveDownloadHelperToDatabase:)]) {
                [self.delegate groupedDownloadOperation:self saveDownloadHelperToDatabase:downloadHelper];
            }

        } else {
            //cleanup download
            [SKTDownloadManager cleanupDownloadHelper:downloadHelper];
        }
        
        //update state after save to database and cleanup
        [self setOverallStateDownloadItem:SKTMapDownloadItemStatusFinished];
        
        if ([self.delegate respondsToSelector:@selector(groupedDownloadOperation:finishedWithSuccess:)]) {
            [self.delegate groupedDownloadOperation:self finishedWithSuccess:success];
        }

    }
    [self.lock unlock];
}

- (void)groupedOperation:(SKTGroupedOperations *)groupedOperation totalBytesRead:(long long)totalBytesRead fromTotalExpected:(long long)totalBytesExpected {
    [self updateDownloadSizes];
    
    NSString *progressDownloadStringOverall = [NSString stringWithFormat:@"%@ / %@", [SKTDownloadManager stringForSize:self.totalBytesDownloaded], [SKTDownloadManager stringForSize:self.totalDownloadSize]];
    
    dispatch_async(self.queue ? self.queue : dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(groupedDownloadOperation:currentDownloadProgress:currentDownloadPercentage:forDownloadHelper:)]) {
            [self.delegate groupedDownloadOperation:self currentDownloadProgress:progressDownloadStringOverall currentDownloadPercentage:self.overallPercentage forDownloadHelper:self.downloadHelper];
        }
    });
}

- (void)groupedOperation:(SKTGroupedOperations *)groupedOperation didUpdateDownloadState:(SKTMapDownloadItemStatus)downloadStatus {
    if (downloadStatus != SKTMapDownloadItemStatusFinished) { //overall finished is set in finishedWithSucce
        [self setOverallStateDownloadItem:downloadStatus];
    }
}

- (void)groupedOperation:(SKTGroupedOperations *)groupedOperation unzipUpdatedProgressString:(NSString *)percentageStr unzipPercentage:(float)percentage {
    self.unzipPercentage = percentage;
    if ([self.delegate respondsToSelector:@selector(groupedDownloadOperation:currentUnzipProgress:currentUnzipPercentage:)]) {
        [self.delegate groupedDownloadOperation:self currentUnzipProgress:percentageStr currentUnzipPercentage:percentage];
    }
}

- (void)groupedOperationCanceledByOS:(SKTGroupedOperations *)groupedOperation {
    dispatch_async(self.queue ? self.queue : dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(groupedDownloadOperationCanceledByOS:)]) {
            [self.delegate groupedDownloadOperationCanceledByOS:self];
        }
    });
}

@end
