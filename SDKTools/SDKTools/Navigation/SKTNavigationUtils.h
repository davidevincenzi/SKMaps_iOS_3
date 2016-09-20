//
//  SKTNavigationUtils.h
//  FrameworkIOSDemo
//

//

#import <Foundation/Foundation.h>

#import <SKMaps/SKDefinitions.h>

#import "SKTNavigationConstants.h"

/** SKTNavigationUtils provides convenience and conversion methods
 */
@interface SKTNavigationUtils : NSObject

/** Returns a string containing time formatted using hh:mm format. This is useful for formatting estimated time to arrival.
 @param seconds Number of seconds to be converted.
 */
+ (NSString *)formattedTimeForTime:(int)seconds;

/** Returns a string containing the formatted distance including measurement unit. The distance is rounded to the closest suitable number so that it's more visually appealing.
 @param meters Distance in meters.
 @param format Desired format to convert to.
 */
+ (NSString *)formattedDistanceWithDistance:(int)meters format:(SKDistanceFormat)format;

/** Returns a string containing the converted distance including measurement unit. No rounding is done.
 @param meters Distance in meters.
 @param returnFormat Unit to convert to.
 */
+ (NSString *)convertMeters:(int)meters toUnitFormat:(SKTNavigationUnitReturnFormat)returnFormat;

/** Converts the distance to a desired format.
 @param meters Distance in meters.
 @param returnFormat Unit to convert to.
 */
+ (float)convertFromMeters:(int)meters toDistanceWithFormat:(SKTNavigationUnitReturnFormat)returnFormat;

/** Converts the distance to a desired format.
 @param metersPerSecond Distance in meters.
 @param distanceFormat Unit to convert to.
 */
+ (float)convertSpeed:(float)metersPerSecond toFormat:(SKDistanceFormat)distanceFormat;

/** Converts a SKRouteMode type to SKTransportMode type.
 @param routeMode a SKRouteMode type.
 */
+ (SKTransportMode)transportModeFromRouteMode:(SKRouteMode)routeMode;

/** Converts a SKRouteMode type to SKTNavigationViewType type.
 @param routeMode a SKRouteMode type.
 */
+ (SKTNavigationViewType)navigationViewTypeFromRouteMode:(SKRouteMode)routeMode;

/** Converts a SKRouteMode type to SKTNavigationFreeDriveViewType type.
 @param routeMode a SKRouteMode type.
 */
+ (SKTNavigationFreeDriveViewType)navigationFreeDriveViewTypeFromRouteMode:(SKRouteMode)routeMode;

/** Checks whether is night.
 */
+ (BOOL)isNight;

/** Return time of day.
 */
+ (SKTNavigationTimeOfDay)timeOfDay;

/** Removes local notifications that contain the given key in their user info dictionary.
 @param userInfoKey Key to search for.
 */
+ (void)cancelLocalNoficationWithUserInfoKey:(NSString *)userInfoKey;

/** Returns the full path for the mp3 files contained in SKAdvisorResources.bundle for the given language
 @param language Audio language.
 */
+ (NSString *)audioFilesFolderPathForLanguage:(SKAdvisorLanguage)language;

/** Returns current country code using reverse geocoding.
 */
+ (NSString *)currentCountryCode;

/** Key of the background color for a given street type.
 @param streetType Street type.
 */
+ (NSString *)backgroundColorNameForStreetType:(SKStreetType)streetType;

/** Key of the sign color for a given street type.
 @param streetType Street type.
 */
+ (NSString *)adviceSignColorNameForStreetType:(SKStreetType)streetType;

/** Key of the text color for a given street type.
 @param streetType Street type.
 */
+ (NSString *)streetTextColorNameForStreetType:(SKStreetType)streetType;

/** Key of the status bar style for a given street type. This is used on iOS 7 to change status bar appearence so that the contrast between status bar and the view underneath it is more visually appealing,
 @param streetType Street type.
 */
+ (NSString *)statusBarStyleNameForStreetType:(SKStreetType)streetType;

/** Key of the destination image for a given street type.
 @param streetType Street type.
 */
+ (NSString *)destinationImageNameForStreetType:(SKStreetType)streetType;

/** Tells whether the given location is zero.
 @param location Location to test.
 */
+ (BOOL)locationIsZero:(CLLocationCoordinate2D)location;

/** Returns an array containing the street, city and country for a given location.
 @param location Location to reverse geocode.
 */
+ (NSArray *)streetCityAndCountryForLocation:(CLLocationCoordinate2D)location;

/**
 */
+ (NSString *)languageNameForLanguage:(SKAdvisorLanguage)language;

/** Returns the SKTNavigationResources.bundle
 */
+ (NSBundle *)navigationBundle;

@end
