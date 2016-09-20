//
//  SKOneBoxSearchLogger.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SKOneBoxSearchLogger : NSObject

+(void)logSearchQuery:(NSString*)searchQuery location:(CLLocationCoordinate2D)coordinate;

@end
