//
//  SKTDownloadOperation.m
//  
//

#import "SKTDownloadOperation.h"
#import "SKTUnzipOperation.h"

#import "SKTDownloadManager+Additions.h"
#import "SKTDownloadObjectHelper.h"

const int kDownloadOperationTimeoutInterval = 15;
const int kDownloadOperationNumberOfRetries = 3;

@interface SKTDownloadOperation ()

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSURL *url;

@property (atomic, assign) int nrOfTimeouts;

@end

@implementation SKTDownloadOperation

#pragma mark - Init

+ (instancetype)downloadOperationWithDelegate:(id<SKTDownloadOperationDelegate>)delegate URL:(NSURL *)url downloadFilePath:(NSString *)filePath withType:(SKTDownloadFileType)downloadFileType withDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    return [[SKTDownloadOperation alloc] initWithDelegate:delegate URL:url downloadFilePath:filePath withType:downloadFileType withDownloadHelper:downloadHelper];
}

+ (instancetype)downloadOperationWithDownloadOperation:(SKTDownloadOperation *)downloadOperation {
    return [SKTDownloadOperation downloadOperationWithDelegate:downloadOperation.downloadDelegate URL:downloadOperation.url downloadFilePath:downloadOperation.filePath withType:downloadOperation.downloadType withDownloadHelper:downloadOperation.downloadHelper];
}

+ (SKTUnzipOperation *)unzipOperationForDownloadOperation:(SKTDownloadOperation *)downloadOperation withUnzipDelegate:(id<SKTUnzipOperationDelegate>)delegate {
    SKTUnzipOperation *unzipOperation = [SKTUnzipOperation unzipOperationWithDelegate:delegate withDownloadHelper:downloadOperation.downloadHelper withType:downloadOperation.downloadType];
    return unzipOperation;
}

+ (NSArray *)dependentOperationsWithDelegate:(id<SKTDownloadOperationDelegate>)delegate URL:(NSURL *)url downloadFilePath:(NSString *)filePath withType:(SKTDownloadFileType)downloadFileType withDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    SKTDownloadOperation *operation = [SKTDownloadOperation downloadOperationWithDelegate:delegate URL:url downloadFilePath:filePath withType:downloadFileType withDownloadHelper:downloadHelper];
    
    NSArray *operations = [NSArray arrayWithObject:operation];
    
    if ([SKTDownloadOperation operationNeedsUnzipForDownloadType:downloadFileType]) {
        //needs unzip
        SKTUnzipOperation *unzipOperation = [SKTUnzipOperation unzipOperationWithDelegate:nil withDownloadHelper:downloadHelper withType:downloadFileType];
        
        operations = [NSArray arrayWithObjects:operation, unzipOperation, nil];
    }
    
    return operations;
}

- (instancetype)initWithDelegate:(id<SKTDownloadOperationDelegate>)delegate URL:(NSURL *)url downloadFilePath:(NSString *)filePath withType:(SKTDownloadFileType)downloadFileType withDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:kDownloadOperationTimeoutInterval];
    
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    self = [super initWithRequest:request targetPath:filePath shouldResume:YES];
    if (self) {
        self.downloadDelegate = delegate;
        self.downloadHelper = downloadHelper;
        self.downloadType = downloadFileType;
        self.filePath = filePath;
        self.url = url;
        
        self.deleteTempFileOnCancel = YES;
        self.shouldOverwrite = YES;
        
        //set current read as the temp size
        _totalBytesReadForFile = [SKTDownloadManager fileSizeForPath:[self tempPath]];
        _totalBytesExpectedToReadForFile = [SKTDownloadManager expectedDownloadSizeForDownloadHelper:downloadHelper withFileType:downloadFileType];
        
        __weak __typeof(self) weakSelf = self;
        [self setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            
            BOOL isFinished = [strongSelf isFinished];
            BOOL isCancelled = [strongSelf isCancelled];
            
            BOOL shouldAlertDelegate = YES;
            if (isFinished || isCancelled) {
                shouldAlertDelegate = NO;
            }

            if (shouldAlertDelegate) {
                if ([strongSelf.downloadDelegate respondsToSelector:@selector(operationCanceledByOS:)]) {
                    [strongSelf.downloadDelegate operationCanceledByOS:strongSelf];
                }
            }
        }];
        
        [self setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
            
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            
            BOOL isCorrectURL = YES;
            NSString *responseURL = [[[operation response] URL] absoluteString];
            if (![responseURL isEqualToString:[url absoluteString]]) {
                isCorrectURL = NO;
            }
            
            strongSelf.nrOfTimeouts = 0;
            
            if ([strongSelf.downloadDelegate respondsToSelector:@selector(downloadOperation:finishedSuccessfully:)]) {
                if (isCorrectURL) {
                    [strongSelf updateDownloadHelperDownloadState];
                    [strongSelf.downloadDelegate downloadOperation:strongSelf finishedSuccessfully:YES];
                } else {
                    [strongSelf.downloadDelegate downloadOperation:strongSelf finishedSuccessfully:NO];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([operation isCancelled]) {
                return;
            }
            
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            
            if (strongSelf.nrOfTimeouts < kDownloadOperationNumberOfRetries) {
                strongSelf.nrOfTimeouts++;

                if ([strongSelf.downloadDelegate respondsToSelector:@selector(downloadOperation:willRetryWithDownloadOperation:)]) {
                    [strongSelf.downloadDelegate downloadOperation:strongSelf willRetryWithDownloadOperation:[strongSelf retryDependentOperation]];
                }
            } else {
                //TRIED 3 TIMES RETRY
                //strongSelf.nrOfTimeouts = 0;
                
                if (error && ABS([error code]) == 1001) {
                    [(AFDownloadRequestOperation *)operation deleteTempFileWithError : nil];
                    if ([strongSelf.downloadDelegate respondsToSelector:@selector(didReceiveTimeOut:)]) {
                        [strongSelf.downloadDelegate didReceiveTimeOut:strongSelf];
                    }
                } else if (error && ABS([error code]) == 1009) {
                    //in case download fails with network lost retry.
                    strongSelf.nrOfTimeouts = 0;
                    if ([strongSelf.downloadDelegate respondsToSelector:@selector(downloadOperation:willRetryWithDownloadOperation:)]) {
                        [strongSelf.downloadDelegate downloadOperation:strongSelf willRetryWithDownloadOperation:[strongSelf retryDependentOperation]];
                    }
                } else {

                    [(AFDownloadRequestOperation *)operation deleteTempFileWithError : nil];
                    if ([strongSelf.downloadDelegate respondsToSelector:@selector(downloadOperation:finishedSuccessfully:)]) {
                        [strongSelf.downloadDelegate downloadOperation:strongSelf finishedSuccessfully:NO];
                    }
                    
                }
            }
        }];
        
        [self setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile){
            
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            
            //set bytes read for operation
            strongSelf.totalBytesExpectedToReadForFile = totalBytesExpectedToReadForFile;
            strongSelf.totalBytesReadForFile = totalBytesReadForFile;
            
            //reset nr of timeouts if we get something from the server
            strongSelf.nrOfTimeouts = 0;
            if ([weakSelf.downloadDelegate respondsToSelector:@selector(downloadOperation:bytesRead:totalBytesRead:totalBytesExpected:totalBytesExpectedToReadForFile:)]) {
                if (!strongSelf.isCancelled) {
                    [strongSelf.downloadDelegate downloadOperation:strongSelf bytesRead:bytesRead totalBytesRead:totalBytesRead totalBytesExpected:totalBytesExpected totalBytesExpectedToReadForFile:totalBytesExpectedToReadForFile];
                }
            }
            
        }];
    }
    return self;
}

- (long long)sampleSize {
    long long sampleSize = self.totalBytesRead - self.totalBytesPreviouslyRead;
    self.totalBytesPreviouslyRead = self.totalBytesRead;
    return sampleSize;
}

#pragma mark - Private

+ (SKTDownloadOperation *)downloadOperationFromArray:(NSArray *)operations {
    for (id operation in operations) {
        if ([operation isKindOfClass:[SKTDownloadOperation class]]) {
            return operation;
        }
    }
    return nil;
}

- (NSArray *)retryDependentOperation {
    NSArray *operations = [SKTDownloadOperation dependentOperationsWithDelegate:self.downloadDelegate URL:self.url downloadFilePath:self.filePath withType:self.downloadType withDownloadHelper:self.downloadHelper];
    
    SKTDownloadOperation *downloadOperation = [SKTDownloadOperation downloadOperationFromArray:operations];
    downloadOperation.nrOfTimeouts = self.nrOfTimeouts;
    
    return operations;
}

+ (BOOL)operationNeedsUnzipForDownloadType:(SKTDownloadFileType)downloadFileType {
    switch (downloadFileType) {
        case SKTDownloadFileTypeTexture:
        {
            return NO;
        }
            
        case SKTDownloadFileTypeNBFile:
        {
            return YES;
        }
            
        case SKTDownloadFileTypeMapFile:
        {
            return NO;
        }
            
        case SKTDownloadFileTypeWikiTravel:
        {
            return NO;
        }
            
        case SKTDownloadFileTypeVoice:
        {
            return YES;
        }
            
        default:
            return NO;
    }
}

- (void)updateDownloadHelperDownloadState {
    switch (self.downloadType) {
        case SKTDownloadFileTypeTexture:
        {
            self.downloadHelper.details.downloadState.bTexturesDownloaded = YES;
        }
            break;
            
        case SKTDownloadFileTypeNBFile:
        {
            self.downloadHelper.details.downloadState.bNBDownloaded = YES;
        }
            break;
            
        case SKTDownloadFileTypeMapFile:
        {
            self.downloadHelper.details.downloadState.bSkmDownloaded = YES;
        }
            break;
        default:
            break;
    }
}

@end
