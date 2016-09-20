//
//  SKTGroupedDownloadOperation.h
//  
//

//

#import <Foundation/Foundation.h>
#import "SKTGroupedOperationsDelegate.h"
#import "SKTGroupedDownloadOperationDelegate.h"

@class SKTDownloadObjectHelper;
@class SKTGroupedOperations;

/**
 SKTGroupedDownloadOperation contains multiple SKTGroupedOperations.
 For example a map download will contain 3 SKTGroupedOperations (Map, Name browser zip, texture file).
 */
@interface SKTGroupedDownloadOperation : NSObject <SKTGroupedOperationsDelegate>

/**
 Download helper object used for keeping track of download sizes and download states.
 */
@property (nonatomic, strong) SKTDownloadObjectHelper *downloadHelper;

/**
 Download helper object used for keeping track of download sizes and download states.
 */
@property (nonatomic, weak) id<SKTGroupedDownloadOperationDelegate>  delegate;

/**
 Current overall state of the downloads
 */
@property (atomic, assign) SKTMapDownloadItemStatus overallStateDownloadItem;

/**
 Download file type (Texture,Map,NB,Voice,Wiki).
 */
@property (nonatomic, assign) SKTDownloadFileType downloadType;

/**
 Overall download percentage represented as a 'float'.
 */
@property (atomic, assign) float overallPercentage;

/**
 Overall unzip percentage represented as a 'float'.
 */
@property (atomic, assign) float unzipPercentage;

/**
 Total download size of the download operations 'long long'.
 */
@property (atomic, assign) long long totalDownloadSize;

/**
 Total download bytes of the download operations 'long long'.
 */
@property (atomic, assign) long long totalBytesDownloaded;

/**
 Factory class for returning an empty SKTGroupedDownloadOperation.
 */
+ (instancetype)downloadGroupedOperation;

/**
 Adds SKTGroupedOperations objects to the SKTGroupedDownloadOperation instance.
 @param groupedOperation SKTGroupedOperations object.
 */
- (void)addSKGroupedOperation:(SKTGroupedOperations *)groupedOperation;

/**
 Method for starting the SKTGroupedDownloadOperation object.
 @return A boolean indicating is the SKTGroupedDownloadOperation was started succesfully.
 */
- (BOOL)start;

/**
 Method for pausing the SKTGroupedDownloadOperation object.
 @return A boolean indicating is the SKTGroupedDownloadOperation was paused succesfully.
 */
- (BOOL)pause;

/**
 Method for resuming the SKTGroupedDownloadOperation object.
 @return A boolean indicating is the SKTGroupedDownloadOperation was resumed succesfully.
 */
- (BOOL)resume;

/**
 Method for canceling the SKTGroupedDownloadOperation object.
 @return A boolean indicating is the SKTGroupedDownloadOperation was cancelled succesfully.
 */
- (BOOL)cancel;

/**
 Whether or not the download is in progress.
 @return A boolean indicating is the SKTGroupedDownloadOperation is downloading.
 */
- (BOOL)isDownloading;

/**
 Whether or not the unzip is in progress.
 @return A boolean indicating is the SKTGroupedDownloadOperation is unzipping.
 */
- (BOOL)isUnzipping;

/**
 Whether or not the SKTGroupedDownloadOperation is paused.
 @return A boolean indicating is the SKTGroupedDownloadOperation is paused.
 */
- (BOOL)isPaused;

/**
 Method for calculating total download size, total bytes downloaded and the overall percentage
 @param totalDownloadSize Total download size passed by pointer.
 @param totalBytesDownloaded Total bytes downloaded passed by pointer.
 @param overallPercentage Overall percentage passed by pointer.
 */
- (void)totalDownloadSize:(long long *)totalDownloadSize totalBytesDownloaded:(long long *)totalBytesDownloaded overallPercentage:(float *)overallPercentage;

/**
 Method for retrieving download sample size for measuring download speed.
 @return 'long long' representing size in bytes between bytes read (totalBytesRead - totalBytesPreviouslyRead).
 */
- (long long)sampleSize;

@end
