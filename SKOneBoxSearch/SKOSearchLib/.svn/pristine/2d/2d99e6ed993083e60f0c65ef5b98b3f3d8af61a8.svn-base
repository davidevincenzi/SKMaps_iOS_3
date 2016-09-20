//
//  SKOBBox.h
//  SKOSearchLib
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@interface SKOBBox : NSObject

+ (instancetype)boundingBoxWithTopLeftCoordinate:(CLLocationCoordinate2D)topLeft bottomRightCoordinate:(CLLocationCoordinate2D)bottomRight;
+ (instancetype)boundingBoxForCoordinate:(CLLocationCoordinate2D)coordinate radius:(int)radius;

- (BOOL)containsLocation:(CLLocationCoordinate2D)location;

@end
