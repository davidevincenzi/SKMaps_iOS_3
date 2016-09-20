//
//  SKTUnzipOperation.h
//  
//
//

#import <Foundation/Foundation.h>
#import "SKTUnzipOperationDelegate.h"
#import "SKTDownloadTypes.h"

@class SKTDownloadObjectHelper;

/**
 Subclass of NSOperation which handles unzipping and reports back progress via delegate.
 */
@interface SKTUnzipOperation : NSOperation

/**
 Download helper object used for keeping track of download sizes and download states.
 */
@property (nonatomic, strong) SKTDownloadObjectHelper *downloadHelper;

/**
 Unzip delegate.
 */
@property (nonatomic, weak) id<SKTUnzipOperationDelegate>    unzipDelegate;

/**
 Download file type (Texture,Map,NB,Voice,Wiki).
 */
@property (nonatomic, assign) SKTDownloadFileType downloadType;

/**
 Total unzip size in 'long long' bytes.
 */
@property (nonatomic, assign) long long totalSize;

/**
 Unzip percentage as 'int'. 
 */
@property (nonatomic, assign) int unzipPercentage;

/**
 The dispatch queue for unzip. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, strong) dispatch_queue_t queue;

/**
 Factory class for creating an unzip operation.
 @param delegate Unzip delegate.
 @param downloadHelper Download helper used for setting unzip states and retrieving unziping paths.
 @param downloadFileType Download file type (Texture,Map,NB,Voice,Wiki).
 @return Newly created unzip operation.
 */
+ (instancetype)unzipOperationWithDelegate:(id<SKTUnzipOperationDelegate>)delegate withDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper withType:(SKTDownloadFileType)downloadFileType;

@end
