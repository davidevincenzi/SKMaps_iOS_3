//
//  SKTGroupedOperations.h
//  
//

#import <Foundation/Foundation.h>

#import "SKTDownloadOperationDelegate.h"
#import "SKTUnzipOperationDelegate.h"
#import "SKTGroupedOperationsDelegate.h"

@class SKTDownloadOperation;
@class SKTUnzipOperation;

/**
 SKTGroupedOperations a SKTDownloadOperation and a SKTUnzipOperation if neccesary.
 For example a map download will contain 3 SKTGroupedOperations (Map, Name browser zip, texture file).
 */
@interface SKTGroupedOperations : NSOperation <SKTDownloadOperationDelegate, SKTUnzipOperationDelegate>

/**
 The download operation.
 */
@property (nonatomic, strong) SKTDownloadOperation *downloadOperation;

/**
 Download delegate for the grouped operation
 */
@property (nonatomic, strong) id<SKTGroupedOperationsDelegate> delegate;

/**
 Current state of the download
 */
@property (atomic, assign) SKTMapDownloadItemStatus stateDownloadItem;

/**
 The dispatch queue for download. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, strong) dispatch_queue_t queue;

/**
 Factory class for returning an empty SKTGroupedOperations.
 */
+ (instancetype)groupedOperation;

/**
 Sets SKTDownloadOperation and SKTUnzipOperation on a SKTGroupedOperations.
 @param downloadOperation The download operation (required).
 @param unzipOperation The unzip operation, can be NULL.
 */
- (void)setupWithDownloadOperation:(SKTDownloadOperation *)downloadOperation andUnzipOperation:(SKTUnzipOperation *)unzipOperation;

/**
 Method for pausing the SKTGroupedOperations. Unzipping operation cannot be paused so it will be cancelled and restarted on resume.
 */
- (void)pause;

/**
 Method for resuming the SKTGroupedOperations. Cancelled or finished download operations will be recreated and started
 */
- (void)resume;

/**
 Method for cancelling the SKTGroupedOperations.
 */
- (void)cancel;

/**
 Method for retrieving download sample size for measuring download speed.
 @return 'long long' Representing size in bytes between bytes read (totalBytesRead - totalBytesPreviouslyRead).
 */
- (long long)sampleSize;

@end
