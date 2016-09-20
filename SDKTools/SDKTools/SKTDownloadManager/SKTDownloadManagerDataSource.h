//
//  SKTDownloadManagerDataSource.h
//  SDKTools
//
//

#import <Foundation/Foundation.h>

/**
 SKTDownloadManagerDataSource data source of SKTDownloadManager.
 */
@protocol SKTDownloadManagerDataSource <NSObject>

@optional

/**
 Data source method used to tell the download manager the mode of the application. Onboard or offboard.
 @return boolean indicating if the app is in onboard mode.
 */
- (BOOL)isOnBoardMode;

@end
