//
//  SKTDownloadManager.h
//  

//

#import <Foundation/Foundation.h>

#import "SKTDownloadManagerDelegate.h"
#import "SKTDownloadManagerDataSource.h"

#import "SKTGroupedDownloadOperationDelegate.h"

@class SKTGroupedDownloadOperation;

/**
 - kFMRequestTimeoutAlertTag - timeout alert tag
 - kFMRequestErrorNetworkSomethingWentWrong - generic error alert tag
 - kFMUserDicAcceptCellularDownload - notification name for user accepted cellular network download
 */
extern const int kFMRequestTimeoutAlertTag;
extern const int kFMRequestErrorNetworkSomethingWentWrong;
extern NSString* const kFMUserDicAcceptCellularDownload;

@interface SKTDownloadManager : NSObject <SKTGroupedDownloadOperationDelegate>

/**
 Download delegate, can be NULL.
 */
@property (nonatomic, weak) id<SKTDownloadManagerDelegate> downloadDelegate;

/**
 Download data source, can be NULL.
 */
@property (nonatomic, weak) id<SKTDownloadManagerDataSource> downloadDataSource;

/**
 Container for SKTGroupedDownloadOperation operations.
 */
@property (atomic, strong, readonly) NSMutableArray *downloadOperations;

/** Method for retrieving SKTDownloadManager singleton
 @return SKTDownloadManager singleton instance.
 */
+ (SKTDownloadManager *)sharedInstance;

/** Method for requesting downloads.
 @param downloads Array of SKTDownloadObjectHelper objects.
 @param shouldStart A boolean indicating wether the download should start after adding downloads to the queue.
 @param delegate Download delegate.
 @param dataSource Download data source
 */
- (void)requestDownloads:(NSArray *)downloads startAutomatically:(BOOL)shouldStart withDelegate:(id<SKTDownloadManagerDelegate>)delegate withDataSource:(id<SKTDownloadManagerDataSource>)dataSource; //request downloads

/*
 Download operations
 */

/** 
 Cancel all downloads and clear temporary files.
 */
- (void)cancelDownload;

/** Cancel download for a certain item
 @param downloadHelper The SKTDownloadObjectHelper object containing information regarding the download.
 @return A boolean indicating wether the download was cancelled succesfully.
 */
- (BOOL)cancelDownloadForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper;

/**
 Pause all downloads.
 */
- (void)pauseDownload;

/** Pause download for a certain item
 @param downloadHelper The SKTDownloadObjectHelper object containing information regarding the download.
 @return A boolean indicating wether the download was paused succesfully.
 */
- (BOOL)pauseDownloadForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper;

/**
 Resume download.
 */
- (void)resumeDownload;

/** Resume download for a certain item
 @param downloadHelper The SKTDownloadObjectHelper object containing information regarding the download.
 @return A boolean indicating wether the download was resumed succesfully.
 */
- (BOOL)resumeDownloadForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper;

/**
 Whether or not the download is paused.
 @return A Boolean indicating whether or not the download is paused.
 */
- (BOOL)isDownloadPaused;

/**
 Whether or not unzip is in progress.
 @return A Boolean indicating whether or not unzipping is in progress.
 */
- (BOOL)isUnzipping;

/**
 Whether or not download is in progress.
 @return A Boolean indicating whether or not download is in progress.
 */
- (BOOL)isDownloadRunning;

/**
 Whether or not download can be started. Internet connection should be available and app should not be in onboard mode.
 @return A Boolean indicating whether or not download can be started.
 */
+ (BOOL)canStartDownload;

/**
 Whether or not download can be restarted. A previous download session should have been terminated and app should not be in onboard mode.
 @return A Boolean indicating whether or not download can be restarted.
 */
+ (BOOL)canRestartDownload;

/**
 Whether or not app is in onboard mode. Download cannot be started in onboard mode.
 @return A Boolean indicating whether or not app is in onboard mode.
 */
- (BOOL)isOnboardMode;

/**
 The current grouped download operation.
 @return The current SKTGroupedDownloadOperation instance.
 */
- (SKTGroupedDownloadOperation *)currentGroupedOperation;

/**
 The current grouped download operation download helper.
 @return The current SKTDownloadObjectHelper instance.
 */
- (SKTDownloadObjectHelper *)currentDownloadHelper;

/**
 Returns the SKTGroupedDownloadOperation corresponding to the SKTDownloadObjectHelper object.
 @param downloadHelper The SKTDownloadObjectHelper object containing information regarding the download.
 @return The SKTGroupedDownloadOperation instance.
 */
- (SKTGroupedDownloadOperation *)groupedOperationForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper;

/**
 Returns an array of SKTGroupedDownloadOperation corresponding to the SKTDownloadObjectHelper object.
 @param downloadHelper The SKTDownloadObjectHelper object containing information regarding the download.
 @return Array of SKTGroupedDownloadOperation instances.
 */
- (NSArray *)operationsForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper;

/**
 Returns an array of SKTDownloadObjectHelper from the download queue.
 @return Array of SKTDownloadObjectHelper instances.
 */
- (NSArray *)downloadHelpersFromDownloadOperationQueue;

/**
 Count of downloads which are not fully finished.
 @return An integer representing the count of downloads which are not fully finished.
 */
- (NSUInteger)countDownloadHelpersNotFullyDownloaded;

/**
 Downloads which are not fully finished.
 @return An array representing the SKTGroupedDownloadOperations which are not fully finished.
 */
- (NSArray*)downloadOperationsNotFullyDownloaded;

/**
 Whether or not connectiong changed from Wifi to cellular.
 @return A Boolean indicating whether or not connectiong changed from Wifi to cellular.
 */
- (BOOL)changedWifiToCellular;

@end
