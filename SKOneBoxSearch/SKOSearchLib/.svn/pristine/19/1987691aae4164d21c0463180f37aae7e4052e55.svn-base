//
//  SKOSearchLibUtils.h
//  SKOSearchLib
//
//  Created by Mihai Costea on 14/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import <SKMaps/SKMaps.h>
#import <CoreLocation/CoreLocation.h>
#import <SKOSearchLib/SKODefinitions.h>

/** Helper class for SKOSearchLib classes.
 */
@interface SKOSearchLibUtils : NSObject

/** Convert language code to SKLanguage type used by SKMaps framework
 @param language NSString representing language code eg.: @"de"
 @return SKLanguage type
 */
+ (int)codeForLanguage:(NSString *)language;

/**
 * Returns the distance asynchronous between the two given spheric coordinate pairs
 * (pointA long, pointA lat) and (pointB long, pointB lat). The distance
 * will be delivered in meter considering that the earth is a sphere with a
 * predefined radius.
 * <p>
 * The distance is calculated according to the spheric trigonometry. The
 * accuracy of the distance is about 200 to 250 ppm if the distance is less
 * than 200 km. This is a maximum of 2,5 meter failure in 1 km.
 *
 * @param pointA first coordinate
 * @param pointB second coordinate
 * @return distance on surface in meter
 */
+ (void)getAsyncAirDistancePointA:(CLLocationCoordinate2D)pointA pointB:(CLLocationCoordinate2D)pointB completionBlock:(void (^)(const double result))completionBlock;

/**
 * Returns the distance between the two given spheric coordinate pairs
 * (pointA long, pointA lat) and (pointB long, pointB lat). The distance
 * will be delivered in meter considering that the earth is a sphere with a
 * predefined radius.
 * <p>
 * The distance is calculated according to the spheric trigonometry. The
 * accuracy of the distance is about 200 to 250 ppm if the distance is less
 * than 200 km. This is a maximum of 2,5 meter failure in 1 km.
 *
 * @param pointA first coordinate
 * @param pointB second coordinate
 * @return distance on surface in meter
 */
+ (double)getAirDistancePointA:(CLLocationCoordinate2D)pointA pointB:(CLLocationCoordinate2D)pointB;

/**
 * Returns the Levenshtein distance between two strings
 * @param first First string
 * @param second Second string
 * @return Levenshtein distance
 */
+ (NSUInteger)levenshteinDistanceFirstString:(NSString *)first secondString:(NSString *)second;

/**
 * Returns boolean indicating wether a coordinate is in US
 * @param coordinate coordinate
 * @return boolean indicating wether a coordinate is in US
 */
+ (BOOL)isCoordinateInUS:(CLLocationCoordinate2D)coordinate;

/** Compares two locations and returns YES
 if the distance between them is lower then provided distance in m.
 */
+ (BOOL)isSameLocation:(CLLocationCoordinate2D)firstLocation asLocation:(CLLocationCoordinate2D)secondLocation withDistance:(double)distance;

@end
