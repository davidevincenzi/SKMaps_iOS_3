//
//  SKTDownloadManager+DownloadSpeedMeasure.m
//  

//

#import "SKTDownloadManager+DownloadSpeedMeasure.h"
#import "SKTGroupedDownloadOperation.h"

NSString *const kSKDownloadSpeed = @"downloadSpeed";
NSString *const kSKDownloadEstimatedTime = @"downloadEstimatedTime";

//Time
const int kTimeSecondsInMinute = 60;
const int kTimeSecondsInHour = 3600;
const int kTimeSecondsInDay = 86400;

const float kDownloadSpeedSamplingInterval = 0.5;
const int kUnitBytesSize = 1024;
const int kDownloadSpeedsMaxCount = 20;

@implementation SKTDownloadManager (DownloadSpeedMeasure)

static double _latestAverageSpeed;
static double _latestEstimatedTime;

@dynamic downloadSpeedTimer;
@dynamic downloadSpeeds;

#pragma mark - Public

- (void)startSpeedCalculationTimer {
    if (!self.downloadSpeeds) {
        self.downloadSpeeds = [NSMutableArray array];
    }
    
    if (!self.downloadSpeedTimer) {
        self.downloadSpeedTimer = [NSTimer scheduledTimerWithTimeInterval:kDownloadSpeedSamplingInterval target:self
                                                                 selector:@selector(calculateDownloadSpeed) userInfo:nil
                                                                  repeats:YES];
    }
}

- (void)cancelSpeedCalculationTimer {
    [self.downloadSpeeds removeAllObjects];
    if (self.downloadSpeedTimer) {
        [self.downloadSpeedTimer invalidate];
        self.downloadSpeedTimer = nil;
    }
}

- (NSDictionary *)downloadSpeedMeasurementInfo {
    NSString *finalSpeedString = [self stringForSpeed:_latestAverageSpeed];
    NSString *finalDurationString = [self stringFormSeconds:_latestEstimatedTime];
    
    return @{kSKDownloadSpeed : finalSpeedString,
             kSKDownloadEstimatedTime : finalDurationString };
}

#pragma mark - Private

- (void)calculateDownloadSpeed {
    if (self.downloadDelegate && [self.downloadDelegate respondsToSelector:@selector(downloadManager:didUpdateDownloadSpeed:andRemainingTime:)]) {
        
        long long bytesInLastSample = 0;
        long long bytesRemainingToDownload = 0;
        SKTGroupedDownloadOperation *tempOperation;
        NSArray *downloadOperations = [NSArray arrayWithArray:self.downloadOperations];
        for (int i = 0; i < [downloadOperations count]; i++) {
            tempOperation = [downloadOperations objectAtIndex:i];
            bytesInLastSample += [tempOperation sampleSize];
            bytesRemainingToDownload += tempOperation.totalDownloadSize - tempOperation.totalBytesDownloaded;
        }
        
        //Calculate current speed.
        long long kB = bytesInLastSample / kUnitBytesSize;
        double samplingRate = 1 / kDownloadSpeedSamplingInterval;
        double speed = kB * samplingRate;
        
        //Add current speed to history.
        [self.downloadSpeeds addObject:[NSNumber numberWithDouble:speed]];
        
        //Delete oldest speed, if it is necessary.
        if ([self.downloadSpeeds count] > kDownloadSpeedsMaxCount) {
            [self.downloadSpeeds removeObjectAtIndex:0];
        }
        
        //Calculate average speed.
        double averageSpeed = 0;
        for (int i = 0; i < [self.downloadSpeeds count]; i++) {
            averageSpeed += [[self.downloadSpeeds objectAtIndex:i] doubleValue];
        }
        averageSpeed /= [self.downloadSpeeds count];
        
        _latestAverageSpeed = averageSpeed;
        
        NSString *finalSpeedString = [self stringForSpeed:averageSpeed];
        NSString *finalDurationString;
        //Notify the observer for the new speed and time.
        if (averageSpeed > 0) {
            //Calculate remaining time in seconds.
            long long KBRemainingToDownload = bytesRemainingToDownload / kUnitBytesSize;
            long long seconds = KBRemainingToDownload / averageSpeed;
            
            finalDurationString = [self stringFormSeconds:seconds];
        } else {
            finalDurationString = [self stringFormSeconds:kTimeSecondsInDay + 1];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.downloadDelegate && [self.downloadDelegate respondsToSelector:@selector(downloadManager:didUpdateDownloadSpeed:andRemainingTime:)]) {
                [self.downloadDelegate downloadManager:self didUpdateDownloadSpeed:finalSpeedString andRemainingTime:finalDurationString];
            }
        });
    }
}

- (NSString *)stringFormSeconds:(long long)seconds {
    if (![self.downloadSpeedTimer isValid]) {
        return [NSString stringWithFormat:@"-"];
    }
    
    //Format the seconds to a nicer format.
    NSUInteger durationInSeconds = (NSUInteger)seconds;
    NSUInteger durationInHours = durationInSeconds / kTimeSecondsInHour;
    NSUInteger durationInRemainder = durationInSeconds % kTimeSecondsInHour;
    NSUInteger durationInMinutes = durationInRemainder / kTimeSecondsInMinute;
    durationInRemainder = durationInRemainder % kTimeSecondsInMinute;
    
    NSString *finalDurationString = @"";
    if (durationInSeconds > kTimeSecondsInDay) {
        //If more than a day , return infinite.
        finalDurationString = @"∞";
    } else {
        finalDurationString = [NSString stringWithFormat:@"%02lu:%02i:%02i", (unsigned long)durationInHours, (int)durationInMinutes, (int)durationInRemainder];
    }
    return finalDurationString;
}

- (NSString *)stringForSpeed:(float)speed {
    if (![self.downloadSpeedTimer isValid]) {
        return [NSString stringWithFormat:@"-"];
    }
    
    NSString *unitString = @"KB";
    if (speed >= 800) {
        speed /= kUnitBytesSize;
        unitString = @"MB";
    }
    return [NSString stringWithFormat:@"%.1f %@/s", speed, unitString];
}

@end
