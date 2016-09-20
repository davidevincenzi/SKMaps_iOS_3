//
//  SKTDownloadManagerDelegate.h
//  
//

//

#import <Foundation/Foundation.h>

@class SKTDownloadManager;
@class SKTDownloadObjectHelper;

/**
 SKTDownloadManagerDelegate delegate of SKTDownloadManager.
 */
@protocol SKTDownloadManagerDelegate <NSObject>

@optional

/**
 Delegate method called when there is not enough space on disk.
 */
- (void)notEnoughDiskSpace;

/**
 Delegate method called when the download cannot be started. When onboard mode is on, or network not reachable.
 */
- (void)cannotStartDownload;

/**
 Delegate method called when the download started.
 */
- (void)didStartDownload;

/**
 Delegate method called when the download was paused.
 */
- (void)didPauseDownload;

/**
 Delegate method called when the download was resumed.
 */
- (void)didResumeDownload;

/**
 Delegate method called when the download was canceled.
 */
- (void)didCancelDownload;

/**
 Delegate method called when the download was canceled by the OS. Background operations cancelled.
 @param downloadManager the download manager object.
 */
- (void)operationsCancelledByOSDownloadManager:(SKTDownloadManager *)downloadManager;

/**
 Delegate method called when the download was paused.
 @param downloadManager the download manager object.
 @param downloadHelper the download helper object.
 */
- (void)downloadManager:(SKTDownloadManager *)downloadManager didPauseDownloadForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper;

/**
 Delegate method called when the download was resumed.
 @param downloadManager the download manager object.
 @param downloadHelper the download helper object.
 */
- (void)downloadManager:(SKTDownloadManager *)downloadManager didResumeDownloadForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper;

/**
 Delegate method called when the download was canceled.
 @param downloadManager the download manager object.
 @param downloadHelper the download helper object.
 */
- (void)downloadManager:(SKTDownloadManager *)downloadManager didCancelDownloadForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper;

/**
 Delegate method called when the internet connectivity changed.
 @param downloadManager the download manager object.
 @param isAvailable boolean indicating wether internet connection is available.
 */
- (void)downloadManager:(SKTDownloadManager *)downloadManager internetAvailabilityChanged:(BOOL)isAvailable;

/**
 Delegate method called when the internet connection switched from wifi to cellular.
 @param downloadManager the download manager object.
 */
- (void)downloadManagerSwitchedWifiToCellularNetwork:(SKTDownloadManager *)downloadManager;

/**
 Delegate method called when the download speed and time was changed.
 @param downloadManager the download manager object.
 @param speed formatted string representing the download speed.
 @param remainingTime formatted string representing the remaining download time.
 */
- (void)downloadManager:(SKTDownloadManager *)downloadManager didUpdateDownloadSpeed:(NSString *)speed andRemainingTime:(NSString *)remainingTime;

/**
 Delegate method called when the download progress was changed.
 @param downloadManager the download manager object.
 @param currentPorgressString formatted string representing the current item download progress.
 @param currentPercentage float representing the current item download percentage.
 @param overallProgressString formatted string representing the overall download progress.
 @param overallPercentage float representing the overall download percentage.
 @param downloadHelper the download helper object.
 */
- (void)downloadManager:(SKTDownloadManager *)downloadManager didUpdateCurrentDownloadProgress:(NSString *)currentPorgressString currentDownloadPercentage:(float)currentPercentage overallDownloadProgress:(NSString *)overallProgressString overallDownloadPercentage:(float)overallPercentage forDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper;

/**
 Delegate method called when the unzip progress was changed.
 @param downloadManager the download manager object.
 @param progressString formatted string representing the unzip progress.
 @param percentage float representing the unzip percentage.
 @param downloadHelper the download helper object.
 */
- (void)downloadManager:(SKTDownloadManager *)downloadManager didUpdateUnzipProgress:(NSString *)progressString percentage:(float)percentage forDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper;

/**
 Delegate method for finished downloading.
 @param downloadManager the download manager object.
 @param downloadHelper the download helper object.
 @param success a boolean indicating if the download was succesfull.
 */
- (void)downloadManager:(SKTDownloadManager *)downloadManager didDownloadDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper withSuccess:(BOOL)success;

/**
 Delegate method for informing the user it's safe to save the data to a local database.
 @param downloadManager the download manager object.
 @param downloadHelper the download helper object.
 */
- (void)downloadManager:(SKTDownloadManager *)downloadManager saveDownloadHelperToDatabase:(SKTDownloadObjectHelper *)downloadHelper;

@end
