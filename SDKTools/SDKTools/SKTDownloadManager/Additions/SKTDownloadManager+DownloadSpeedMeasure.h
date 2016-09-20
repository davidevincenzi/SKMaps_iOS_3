//
//  SKTDownloadManager+DownloadSpeedMeasure.h
//  

//

#import "SKTDownloadManager.h"
#import "SKTDownloadTypes.h"

/**
 Constans used to read valued returned by downloadSpeedMeasurementInfo: function.
 - kSKDownloadSpeed - download speed string
 - kSKDownloadEstimatedTime - download estimated time
 */
extern NSString *const kSKDownloadSpeed;
extern NSString *const kSKDownloadEstimatedTime;

@interface SKTDownloadManager (DownloadSpeedMeasure)

/**
 Times used to measure the download speed
 */
@property(nonatomic, strong) NSTimer *downloadSpeedTimer;

/**
 Array used to hold download speed samples
 */
@property(nonatomic, strong) NSMutableArray *downloadSpeeds;

/**
 Function to start the speed calculation timer.
 */
- (void)startSpeedCalculationTimer;

/**
 Function to stop the speed calculation timer.
 */
- (void)cancelSpeedCalculationTimer;

/**
 Returns download speed measurments info.
 @return The dictionary contains following keys/values:
 - an `NSString` object under the `kSKDownloadSpeed` key, representing download speed string.
 - an `NSString` object under the `kSKDownloadEstimatedTime` key, representing download estimated time string.
 */
- (NSDictionary *)downloadSpeedMeasurementInfo;

@end
