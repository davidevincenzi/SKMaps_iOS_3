//
//  SKTGroupedOperationsDelegate.h
//  
//

#import <Foundation/Foundation.h>
#import "SKTDownloadTypes.h"

@class SKTGroupedOperations;

/**
 SKTGroupedOperationsDelegate delegate of SKTGroupedOperations.
 */
@protocol SKTGroupedOperationsDelegate <NSObject>

@required

/**
 Delegate method called the grouped operations finished.
 @param groupedOperation the grouped operations object.
 @param success boolean indicating wether the grouped operation finished with success.
 */
- (void)groupedOperation:(SKTGroupedOperations *)groupedOperation finishedWithSuccess:(BOOL)success;

@optional

/**
 Delegate method called when the unzip progress was changed.
 @param groupedOperation the grouped operations object.
 @param percentageStr formatted NSString representing the unzip progress for the grouped operation.
 @param percentage float representing the unzip percentage.
 */
- (void)groupedOperation:(SKTGroupedOperations *)groupedOperation unzipUpdatedProgressString:(NSString *)percentageStr unzipPercentage:(float)percentage;

/**
 Delegate method called when the download received bytes.
 @param groupedOperation the grouped operations object.
 @param totalBytesRead long long representing total bytes read by the download operation.
 @param totalBytesExpected long long representing expected total bytes read by the download operation.
 */
- (void)groupedOperation:(SKTGroupedOperations *)groupedOperation totalBytesRead:(long long)totalBytesRead fromTotalExpected:(long long)totalBytesExpected;

/**
 Delegate method called when the download state of the object was updated.
 @param groupedOperation the grouped operations object.
 @param downloadStatus the new updated download status of the operation.
 */
- (void)groupedOperation:(SKTGroupedOperations *)groupedOperation didUpdateDownloadState:(SKTMapDownloadItemStatus)downloadStatus;

/**
 Delegate method called when the download was cancelled by OS. (background task cancelled after a certain time)
 @param groupedOperation the grouped operations object.
 */
- (void)groupedOperationCanceledByOS:(SKTGroupedOperations *)groupedOperation;

/**
 Delegate method called when the download received timeout.
 */
- (void)groupedOperationDidReceiveTimeout;

@end
