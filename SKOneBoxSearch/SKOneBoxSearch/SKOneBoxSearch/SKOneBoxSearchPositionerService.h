//
//  SKOneBoxSearchPositionerService.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *const kOneBoxDidChangeCenterMapLocationNotification;

@interface SKOneBoxSearchPositionerService : NSObject
@property (nonatomic, assign) float zoomLevel;

+ (instancetype)sharedInstance;

- (void)reportLocation:(CLLocation*)location;
- (void)reportCenterMapLocation:(CLLocation*)location;

- (CLLocationCoordinate2D)currentCoordinate;
- (CLLocationCoordinate2D)currentMapCenterCoordinate;

- (CLLocationCoordinate2D)currentSearchCoordinate;

@end
