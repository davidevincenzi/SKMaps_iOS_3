//
//  SKOBBox.m
//  SKOSearchLib
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOBBox.h"
#import <math.h>

static const float KEquatorialRadius = 6378137;

#define radiansToDegrees(_ANGLE_)       (((_ANGLE_) / M_PI) * 180.0f)
#define degreesToRadians(x)             (M_PI * (x) / 180.0)

@interface SKOBBox ()

@property (nonatomic, assign) CLLocationCoordinate2D topLeft;
@property (nonatomic, assign) CLLocationCoordinate2D bottomRight;

@end

@implementation SKOBBox

+ (instancetype)boundingBoxWithTopLeftCoordinate:(CLLocationCoordinate2D)topLeft bottomRightCoordinate:(CLLocationCoordinate2D)bottomRight {
    SKOBBox *boundingBox = [[SKOBBox alloc] init];
    
    boundingBox.topLeft = topLeft;
    boundingBox.bottomRight = bottomRight;
    
    return boundingBox;
}

- (BOOL)containsLocation:(CLLocationCoordinate2D)location {
    BOOL result = NO;
    if ((self.topLeft.longitude <= location.longitude) &&
        (location.longitude <= self.bottomRight.longitude) &&
        (self.bottomRight.latitude <= location.latitude) &&
        (location.latitude <= self.topLeft.latitude)) {
        result = YES;
    }
    
    return result;
}

+ (instancetype)boundingBoxForCoordinate:(CLLocationCoordinate2D)coordinate radius:(int)radius {
    float R = KEquatorialRadius / 1000.0; // earth radius in km
    
    float factor = cos(degreesToRadians(coordinate.latitude));
    float latFactor = radiansToDegrees(radius / R);
    float longFactor = radiansToDegrees(radius / R / factor);
    CLLocationCoordinate2D topLeft = CLLocationCoordinate2DMake(coordinate.latitude + latFactor, coordinate.longitude - longFactor);
    CLLocationCoordinate2D bottomRight = CLLocationCoordinate2DMake(coordinate.latitude - latFactor, coordinate.longitude + longFactor);
    SKOBBox *boundingBox = [SKOBBox boundingBoxWithTopLeftCoordinate:topLeft bottomRightCoordinate:bottomRight];
    
    return boundingBox;
}

@end
