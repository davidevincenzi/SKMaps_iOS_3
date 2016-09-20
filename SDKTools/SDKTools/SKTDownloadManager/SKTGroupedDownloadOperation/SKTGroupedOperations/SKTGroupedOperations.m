//
//  SKGroupedOperations.m
//  
//

#import "SKTGroupedOperations.h"
#import "SKTDownloadOperation.h"
#import "SKTUnzipOperation.h"
#import "SKTDownloadManager+Additions.h"
#import "SKTDownloadTypes.h"

@interface SKTGroupedOperations ()

@property (nonatomic, strong) SKTUnzipOperation *unzipOperation;

@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

@end

@implementation SKTGroupedOperations

#pragma mark - Init

+ (instancetype)groupedOperation {
    return [[SKTGroupedOperations alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        //init status with queued
        _stateDownloadItem = SKTMapDownloadItemStatusQueued;
        
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = @"SKGroupedOperationsLock";
    }
    return self;
}

- (void)setupWithDownloadOperation:(SKTDownloadOperation *)downloadOperation andUnzipOperation:(SKTUnzipOperation *)unzipOperation {
    NSAssert(downloadOperation, @"Download operation must not be null");
    _downloadOperation = downloadOperation;
    [_downloadOperation setDownloadDelegate:self];
    
    if (unzipOperation) {
        _unzipOperation = unzipOperation;
        [_unzipOperation setUnzipDelegate:self];
    }
}

#pragma mark - Public

- (void)pause {
    [self.lock lock];
    if (self.downloadOperation) {
        [self.downloadOperation pause];
    }
    if (self.unzipOperation && [self.unzipOperation isExecuting]) {
        //unzipping has no pause/resume
        [self.unzipOperation cancel];
    }
    //set status paused
    [self setDownloadStatus:SKTMapDownloadItemStatusPaused];
    [self.lock unlock];
}

- (void)resume {
    [self.lock lock];
    if (self.unzipOperation && [self.unzipOperation isCancelled]) {
        self.unzipOperation = [SKTDownloadOperation unzipOperationForDownloadOperation:self.downloadOperation withUnzipDelegate:self];
        [self.unzipOperation setQueue:self.queue];
        
        [self.unzipOperation start];
        //set as installing
        [self setDownloadStatus:SKTMapDownloadItemStatusInstalling];
    } else {
        if (self.downloadOperation) {
            if ([self.downloadOperation isPaused]) {
                [self.downloadOperation resume];
            } else {
                if ([self.downloadOperation isFinished] || [self.downloadOperation isCancelled]) {
                    //if it's finished we cannot restart it
                    self.downloadOperation = [SKTDownloadOperation downloadOperationWithDownloadOperation:self.downloadOperation];
                }
                
                [self.downloadOperation start];
            }
        }
        
        //set downloading
        [self setDownloadStatus:SKTMapDownloadItemStatusDownloading];
    }
    [self.lock unlock];
}

- (void)cancel {
    [self.lock lock];
    if (self.downloadOperation) {
        self.downloadOperation.progressiveDownloadCallbackQueue = NULL;
        self.downloadOperation.completionQueue = nil;
        
        if (self.stateDownloadItem != SKTMapDownloadItemStatusFinished) {
            [self.downloadOperation cancel];
        }
        
        [self.downloadOperation deleteTempFileWithError:nil];
    }
    if (self.unzipOperation) {
        [self.unzipOperation cancel];
    }
    
    //invalid state, cancelled
    [self setDownloadStatus:SKTMapDownloadItemStatusInvalidState];
    [self.lock unlock];
}

- (long long)sampleSize {
    return [self.downloadOperation sampleSize];
}

#pragma mark - Private

- (void)setQueue:(dispatch_queue_t)queue {
    [self.lock lock];
    _queue = queue;
    if (self.downloadOperation) {
        [_downloadOperation setProgressiveDownloadCallbackQueue:queue];
        [_downloadOperation setCompletionQueue:queue];
    }
    if (self.unzipOperation) {
        [self.unzipOperation setQueue:queue];
    }
    [self.lock unlock];
}

- (void)setDownloadStatus:(SKTMapDownloadItemStatus)downloadStatus {
    [self.lock lock];
    _stateDownloadItem = downloadStatus;
    if ([self.delegate respondsToSelector:@selector(groupedOperation:didUpdateDownloadState:)]) {
        [self.delegate groupedOperation:self didUpdateDownloadState:downloadStatus];
    }
    [self.lock unlock];
}

- (void)notifyDelegateOperationFinishedWithSuccess:(BOOL)success {
    [self.lock lock];
    //finished state
    [self setStateDownloadItem:SKTMapDownloadItemStatusFinished];
    
    dispatch_async(self.queue ? self.queue : dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(groupedOperation:totalBytesRead:fromTotalExpected:)]) {
            [self.delegate groupedOperation:self totalBytesRead:0 fromTotalExpected:0];
        }
        if ([self.delegate respondsToSelector:@selector(groupedOperation:finishedWithSuccess:)]) {
            [self.delegate groupedOperation:self finishedWithSuccess:success];
        }
    });
    [self.lock unlock];
}

#pragma mark - SKTDownloadOperationDelegate

- (void)downloadOperation:(SKTDownloadOperation *)operation finishedSuccessfully:(BOOL)success {
    if (success) {
        if ([operation downloadType] == SKTDownloadFileTypeMapFile) {
            if (![SKTDownloadManager mapPackageHasCorrectSize:operation.downloadHelper]) {
                success = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *errorNet = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fm_req_incorrect_package_title", nil)
                                                                       message:NSLocalizedString(@"fm_req_incorrect_package_message", nil)
                                                                      delegate:nil
                                                             cancelButtonTitle:NSLocalizedString(@"ok_btn_title_key", nil)
                                                             otherButtonTitles:nil];
                    [errorNet setTag:88];
                    [errorNet show];
                });
            }
        }
        [self.lock lock];
        if (_unzipOperation) {
            [self setDownloadStatus:SKTMapDownloadItemStatusInstalling];
            self.unzipOperation = [SKTDownloadOperation unzipOperationForDownloadOperation:self.downloadOperation withUnzipDelegate:self];
            [self.unzipOperation setQueue:self.queue];
            [self.unzipOperation start];
        }
        [self.lock unlock];
    }
    
    if (!_unzipOperation) {
        [self notifyDelegateOperationFinishedWithSuccess:success];
    }
}

- (void)downloadOperation:(SKTDownloadOperation *)operation willRetryWithDownloadOperation:(NSArray *)newOperations {
    [self.lock lock];
    //cancel old operation
    [operation cancel];
    //add the newly created one to the queue, it will restart due to its dependencies.
    
    SKTDownloadOperation *newDownloadOperation = nil;
    for (int i = 0; i < [newOperations count]; i++) {
        id operation = [newOperations objectAtIndex:i];
        if ([operation isKindOfClass:[SKTDownloadOperation class]]) {
            newDownloadOperation = operation;
            self.downloadOperation = newDownloadOperation;
        } else if ([operation isKindOfClass:[SKTUnzipOperation class]]) {
            self.unzipOperation = operation;
            [self.unzipOperation setUnzipDelegate:self];
        }
    }
    if (newDownloadOperation) {
        [newDownloadOperation start];
        //downloading
        [self setDownloadStatus:SKTMapDownloadItemStatusDownloading];
    }
    [self.lock unlock];
}

- (void)didReceiveTimeOut:(SKTDownloadOperation *)operation {
    [self setDownloadStatus:SKTMapDownloadItemStatusInvalidState];
    dispatch_async(self.queue ? self.queue : dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(groupedOperation:finishedWithSuccess:)]) {
            [self.delegate groupedOperation:self finishedWithSuccess:NO];
        }
        if ([self.delegate respondsToSelector:@selector(groupedOperationDidReceiveTimeout)]) {
            [self.delegate groupedOperationDidReceiveTimeout];
        }
    });
}

- (void)operationCanceledByOS:(SKTDownloadOperation *)operation {
    [self setDownloadStatus:SKTMapDownloadItemStatusInvalidState];
    dispatch_async(self.queue ? self.queue : dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(groupedOperationCanceledByOS:)]) {
            [self.delegate groupedOperationCanceledByOS:self];
        }
    });
}

- (void)downloadOperation:(SKTDownloadOperation *)operation bytesRead:(NSInteger)bytesRead totalBytesRead:(long long)totalBytesRead totalBytesExpected:(long long)totalBytesExpected totalBytesExpectedToReadForFile:(long long)totalBytesExpectedToReadForFile {
    if ([self.delegate respondsToSelector:@selector(groupedOperation:totalBytesRead:fromTotalExpected:)]) {
        [self.delegate groupedOperation:self totalBytesRead:totalBytesRead fromTotalExpected:totalBytesExpectedToReadForFile];
    }
}

#pragma mark - SKTUnzipOperationDelegate

- (void)unzipOperation:(SKTUnzipOperation *)unzipOperation updatedProgressPercentage:(float)percentage {
    long long processedBytes = (percentage/100) * unzipOperation.totalSize;
    
    NSString *progressString = [NSString stringWithFormat:@"%@ / %@", [SKTDownloadManager stringForSize:processedBytes], [SKTDownloadManager stringForSize:unzipOperation.totalSize]];

    if ([self.delegate respondsToSelector:@selector(groupedOperation:unzipUpdatedProgressString:unzipPercentage:)]) {
        [self.delegate groupedOperation:self unzipUpdatedProgressString:progressString unzipPercentage:percentage];
    }
}

- (void)unzipOperation:(SKTUnzipOperation *)unzipOperation finishedForFile:(NSString *)file withSuccess:(BOOL)success {
    [self notifyDelegateOperationFinishedWithSuccess:success];
}

@end
