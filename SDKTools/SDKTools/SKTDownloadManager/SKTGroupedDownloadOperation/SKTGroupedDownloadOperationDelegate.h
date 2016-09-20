//
//  SKTGroupedDownloadOperationDelegate.h
//  
//
//

#import <Foundation/Foundation.h>

@class SKTGroupedDownloadOperation;
@class SKTDownloadObjectHelper;

/**
 SKTGroupedDownloadOperationDelegate delegate of SKTGroupedDownloadOperation.
 */
@protocol SKTGroupedDownloadOperationDelegate <NSObject>

@required

/**
 Delegate method called when the grouped download operation finished.
 @param groupedDownloadOperation the grouped download operation.
 @param success A boolean indicating if the grouped download finished with success.
 */
- (void)groupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation finishedWithSuccess:(BOOL)success;

/**
 Delegate method called when the grouped download operation started.
 @param groupedDownloadOperation the grouped download operation.
 */
- (void)didStartGroupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation;

/**
 Delegate method called when the grouped download operation was cancelled.
 @param groupedDownloadOperation the grouped download operation.
 */
- (void)didCancelGroupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation;

/**
 Delegate method called when the grouped download operation was paused.
 @param groupedDownloadOperation the grouped download operation.
 */
- (void)didPauseGroupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation;

/**
 Delegate method called when the grouped download operation was resumed.
 @param groupedDownloadOperation the grouped download operation.
 */
- (void)didResumeGroupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation;

/**
 Delegate method called when the grouped download operation was cancelled by the operating system (background task cancelled after a certain period).
 @param groupedDownloadOperation the grouped download operation.
 */
- (void)groupedDownloadOperationCanceledByOS:(SKTGroupedDownloadOperation *)groupedDownloadOperation;

@optional

/**
 Delegate method called when the current download progress of the grouped download operation was changed.
 @param groupedDownloadOperation the grouped download operation.
 @param currentProgressString formatted NSString representing the current download progress.
 @param currentPercentage float representing the current download progress.
 @param downloadHelper the download object helper.
 */
- (void)groupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation currentDownloadProgress:(NSString *)currentProgressString currentDownloadPercentage:(float)currentPercentage forDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper;

/**
 Delegate method called when the current unzip progress of the grouped download operation was changed.
 @param groupedDownloadOperation the grouped download operation.
 @param currentUnzipString formatted NSString representing the current unzip progress.
 @param currentUnzipPercentage float representing the current unzip progress.
 */
- (void)groupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation currentUnzipProgress:(NSString *)currentUnzipString currentUnzipPercentage:(float)currentUnzipPercentage;

/**
 Delegate method called when the grouped download operation received a timeout.
 @param groupedDownloadOperation the grouped download operation.
 */
- (void)didReceiveTimeoutGroupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation;


/**
 Delegate method called to inform the user to do any additional operations, such as saving to the database.
 @param groupedDownloadOperation the grouped download operation.
 @param downloadHelper the download object helper.
 */
- (void)groupedDownloadOperation:(SKTGroupedDownloadOperation *)groupedDownloadOperation saveDownloadHelperToDatabase:(SKTDownloadObjectHelper *)downloadHelper;

@end
