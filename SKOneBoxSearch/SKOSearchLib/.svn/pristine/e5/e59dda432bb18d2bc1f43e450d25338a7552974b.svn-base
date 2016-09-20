//
//  SKOSearchLibUtils.m
//  SKOSearchLib
//
//  Created by Mihai Costea on 14/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOSearchLibUtils.h"
#import <SKMaps/SKMaps.h>

#define kDeg2RadFactor M_PI / 180.0
#define kEarthRadius 6367444

@implementation SKOSearchLibUtils

+ (int)codeForLanguage:(NSString *)language {
    
    if ([language isEqualToString:@"en"]) {
        return SKMapLanguageEN;
    }
    if ([language isEqualToString:@"de"]) {
        return SKMapLanguageDE;
    }
    if ([language isEqualToString:@"es"]) {
        return SKMapLanguageES;
    }
    if ([language isEqualToString:@"fr"]) {
        return SKMapLanguageFR;
    }
    if ([language isEqualToString:@"it"]) {
        return SKMapLanguageIT;
    }
    if ([language isEqualToString:@"ru"]) {
        return SKMapLanguageRU;
    }
    if ([language isEqualToString:@"tr"]) {
        return SKMapLanguageTR;
    }
    
    return SKMapLanguageEN;
}

+ (BOOL)isCoordinateInUS:(CLLocationCoordinate2D)coordinate {
    NSArray *positions = [self polygonPointsForUS];
    NSInteger i, j;
    BOOL result = NO;
    CGPoint currentCoordinate = {coordinate.longitude, coordinate.latitude};
    
    for (i = 0, j = positions.count - 1; i < positions.count; j = i++) {
        CGPoint coordinateI = [[positions objectAtIndex:i] CGPointValue];
        CGPoint coordinateJ = [[positions objectAtIndex:j] CGPointValue];
        
        if (((coordinateI.y > currentCoordinate.y) != (coordinateJ.y > currentCoordinate.y)) &&
            (currentCoordinate.x < (coordinateJ.x - coordinateI.x) *
             (currentCoordinate.y - coordinateI.y) /
             (coordinateJ.y - coordinateI.y) + coordinateI.x)) {
                result = !result;
            }
    }
    
    return result;
}

+ (NSArray *)polygonPointsForUS {
    static NSArray *positions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *mutablePositions = [NSMutableArray array];
        
        CGPoint coordinates[] = {
            {-123.486328,   49.781264},
            {-95.712891,    49.325122},
            {-95.273438,    50.064192},
            {-91.494141,    48.574790},
            {-88.505859,    48.980217},
            {-82.001953,    45.767523},
            {-81.474609,    42.811522},
            {-77.255859,    45.026950},
            {-72.333984,    46.739861},
            {-68.466797,    47.989922},
            {-65.654297,    45.274886},
            {-69.785156,    42.940339},
            {-68.730469,    41.376809},
            {-79.716797,    31.203405},
            {-77.783203,    26.115986},
            {-80.947266,    23.805450},
            {-86.484375,    29.535230},
            {-90.878906,    27.916767},
            {-95.009766,    28.381735},
            {-96.591797,    25.085599},
            {-99.755859,    25.878994},
            {-102.128906,   29.152161},
            {-103.798828,   28.536275},
            {-107.050781,   31.278551},
            {-108.193359,   30.902225},
            {-118.125000,   31.578535},
            {-121.816406,   33.284620},
            {-126.738281,   41.310824},
            {-125.771484,   48.516604},
            {-123.662109,   49.667628}
        };
        
        int count = sizeof(coordinates) / sizeof(coordinates[0]);
        
        for (int i = 0; i < count; i++) {
            [mutablePositions addObject:[NSValue valueWithCGPoint:coordinates[i]]];
        }
        positions = mutablePositions;
    });
    
    return positions;
}

#pragma mark - Unit conversions and metrics helpers

+ (double)getAirDistancePointA:(CLLocationCoordinate2D)pointA pointB:(CLLocationCoordinate2D)pointB {
    if ((pointA.longitude == 0.0 && pointA.latitude == 0.0) || (pointB.longitude == 0.0 && pointB.latitude == 0.0)) {
        return -1;
    }
    
    // Convert degrees to radians
    const double pA_long_RAD = (pointA.longitude * kDeg2RadFactor);
    const double pA_lat_RAD = (pointA.latitude * kDeg2RadFactor);
    const double pB_long_RAD = (pointB.longitude * kDeg2RadFactor);
    const double pB_lat_RAD = (pointB.latitude * kDeg2RadFactor);
    
    /*
     * Side a and b are the angles from the pole to the latitude (=> 90 -
     * latitude). Gamma is the angle between the longitudes measured at the
     * pole. The missing side c can be calculated with the given sides a and
     * b and the angle gamma. Therefore the spherical law of cosines is
     * used.
     */
    const double cosb = cos(M_PI_2 - pA_lat_RAD);
    const double cosa = cos(M_PI_2 - pB_lat_RAD);
    const double cosGamma = cos(pB_long_RAD - pA_long_RAD);
    const double sina = sin(M_PI_2 - pA_lat_RAD);
    const double sinb = sin(M_PI_2 - pB_lat_RAD);
    
    /*
     * Law of cosines for the sides (Spherical trigonometry) cos(c) = cos(a)
     * * cos(b) + sin(a) * sin(b) * cos(Gamma)
     */
    double cosc = cosa * cosb + sina * sinb * cosGamma;
    
    // Limit the cosine from 0 to 180 degrees.
    if (cosc < -1) {
        cosc = -1;
    }
    if (cosc > 1) {
        cosc = 1;
    }
    
    // Calculate the angle in radians for the distance
    const double side_c = acos(cosc);
    
    // return the length in meter by multiplying the angle with
    // the standard sphere radius.
    const double result = MAX(0.0, kEarthRadius * side_c);
    
    return result;
}

+ (void)getAsyncAirDistancePointA:(CLLocationCoordinate2D)pointA pointB:(CLLocationCoordinate2D)pointB completionBlock:(void (^)(const double result))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        const double result = [self getAirDistancePointA:pointA pointB:pointB];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(result);
        });
    });
}

+ (BOOL)isSameLocation:(CLLocationCoordinate2D)firstLocation asLocation:(CLLocationCoordinate2D)secondLocation withDistance:(double)distance {
//   epsilon 0.001 = 100 m
    double epsilon = (distance / 100000);
    double latitudeDifference = fabs(firstLocation.latitude - secondLocation.latitude);
    double longitudeDifference = fabs(firstLocation.longitude - secondLocation.longitude);
    
    BOOL returnVal = latitudeDifference <= epsilon && longitudeDifference <= epsilon;
    return returnVal;
}

#pragma mark - String comparison

+ (NSUInteger)levenshteinDistanceFirstString:(NSString *)first secondString:(NSString *)second {
    if ([first isEqualToString:second]) {
        return 0;
    }
    
    if (first.length == 0) {
        return second.length;
    }
    
    if (second.length == 0) {
        return first.length;
    }
    
    int v0[first.length + 1];
    int v1[second.length + 1];
    
    for (int i = 0; i < first.length; i++) {
        v0[i] = i;
    }
    
    for (int i = 0; i < first.length; i++) {
        v1[0] = i + 1;
        
        for (int j = 0; j < second.length; j++) {
            int cost = ([first characterAtIndex:i] == [second characterAtIndex:j]) ? 0 : 1;
            v1[j+1] = (int)MIN(v1[j] + 1, MIN(v0[j+1] + 1, v0[j] + cost));
        }
        
        for (int j = 0; j < (int)(sizeof(v0) / sizeof(v0[0])); j++) {
            v0[j] = v1[j];
        }
    }
    
    return v1[second.length];
}

@end
