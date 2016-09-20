//
//  SKOneBoxSearchPositionerService.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxSearchPositionerService.h"
#import <SKOSearchLib/SKOSearchLibUtils.h>

NSString *const kOneBoxDidChangeCenterMapLocationNotification = @"kOneBoxDidChangeCenterMapLocationNotification";

#define kMinZoomLevel 11.0f
#define kMaxDistanceCenterMapUserPosition 100000

@interface SKOneBoxSearchPositionerService ()
@property (nonatomic, strong) CLLocation *centerMapLocation;
@property (nonatomic, strong) CLLocation *currentLocation;
@end

@implementation SKOneBoxSearchPositionerService

+ (instancetype)sharedInstance {
    static SKOneBoxSearchPositionerService *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SKOneBoxSearchPositionerService alloc] init];
    });
    return sharedInstance;
}

- (void)reportLocation:(CLLocation*)location {
    self.currentLocation = location;
}

- (void)reportCenterMapLocation:(CLLocation*)location {
    self.centerMapLocation = location;
    [[NSNotificationCenter defaultCenter] postNotificationName:kOneBoxDidChangeCenterMapLocationNotification object:nil];
}

- (CLLocationCoordinate2D)currentCoordinate {
    if(self.currentLocation){
        return self.currentLocation.coordinate;
    }
    return CLLocationCoordinate2DMake(0, 0);
}

- (CLLocationCoordinate2D)currentMapCenterCoordinate {
    if(self.centerMapLocation){
        return self.centerMapLocation.coordinate;
    }
    return CLLocationCoordinate2DMake(0, 0);
}

- (CLLocationCoordinate2D)currentSearchCoordinate {
    /*
     In case the center of the map is relative close to current location search using current location, define relative close.
     If zoomed out alot use center position
     Else use center map
     */
    if (self.zoomLevel <= kMinZoomLevel) {
        //zoomed out, return user location
        return [self currentCoordinate];
    }
    else {
        //check distance between center map and user position
        double result = [SKOSearchLibUtils getAirDistancePointA:[self currentMapCenterCoordinate] pointB:[self currentCoordinate]];
        
        if (result <= kMaxDistanceCenterMapUserPosition) {
            return [self currentCoordinate];
        }
        else {
            return [self currentMapCenterCoordinate];
        }
    }
}

@end
