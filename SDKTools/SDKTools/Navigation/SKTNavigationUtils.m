//
//  SKTNavigationUtils.m
//  FrameworkIOSDemo
//

//

#import <SKMaps/SKReverseGeocoderService.h>
#import <SKMaps/SKPositionerService.h>
#import <SKMaps/SKSearchResult.h>
#import <SKMaps/SKSearchResultParent.h>

#import "SKTNavigationUtils.h"

#define kDeg2RadFactor M_PI / 180.0
#define kEarthRadius 6367444

@implementation SKTNavigationUtils

+ (NSString *)formattedTimeForTime:(int)seconds {
    int hours = seconds / 3600;
	int secondsRest = seconds - hours * 3600.0;
	int minutes = secondsRest / 60.0;
    NSString *hourString = [NSString stringWithFormat:@"%d", hours];
    if (hours < 10) {
        hourString = [NSString stringWithFormat:@"0%d", hours];
    }
    
    NSString *minutesString = [NSString stringWithFormat:@"%d", minutes];
    if (minutes < 10) {
        minutesString = [NSString stringWithFormat:@"0%d", minutes];
    }
    
    NSString *unitString = (hours > 0 ? @"h" : @"min");
    
    return  [NSString stringWithFormat:@"%@:%@ %@", hourString, minutesString, unitString];
}

+ (NSString *)formattedDistanceWithDistance:(int)meters format:(SKDistanceFormat)format {
    NSString *valueString = nil;
    NSString *formatString = nil;
    
    if (format == SKDistanceFormatMilesFeet) {
        float feet = [SKTNavigationUtils convertFromMeters:meters toDistanceWithFormat:SKTNavigationUnitReturnFeet];
        float miles = [SKTNavigationUtils convertFromMeters:meters toDistanceWithFormat:SKTNavigationUnitReturnMiles];
        if (feet >= 1500.0) {
            valueString = miles > 10.0 ? [NSString stringWithFormat:@"%d", (int)miles] : [NSString stringWithFormat:@"%.1f", miles];
            formatString = NSLocalizedString(@"mi", nil);
        } else {
            valueString = [NSString stringWithFormat:@"%d", (int)feet > 100 ? (int)feet / 10 * 10 : (int)feet];
            formatString = NSLocalizedString(@"ft", nil);
        }
    } else if (format == SKDistanceFormatMetric) {
        float distance = meters / 1000.0;
        if (meters >= 1000) {
            valueString = distance > 10.0 ? [NSString stringWithFormat:@"%d", (int)distance] : [NSString stringWithFormat:@"%.1f", distance];
            formatString = NSLocalizedString(@"km", nil);
        } else {
            valueString = [NSString stringWithFormat:@"%d", meters > 100 ? meters / 10 * 10 : meters];
            formatString = NSLocalizedString(@"m", nil);
        }
    } else if (format == SKDistanceFormatMilesYards) {
        float yard = [SKTNavigationUtils convertFromMeters:meters toDistanceWithFormat:SKTNavigationUnitReturnYards];
        float miles = [SKTNavigationUtils convertFromMeters:meters toDistanceWithFormat:SKTNavigationUnitReturnMiles];
        if (yard >= 1000.0) {
            valueString = miles > 10.0 ? [NSString stringWithFormat:@"%d", (int)miles] : [NSString stringWithFormat:@"%.1f", miles];
            formatString = NSLocalizedString(@"mi", nil);
        } else {
            valueString = [NSString stringWithFormat:@"%d", (int)yard > 100 ? (int)yard / 10 * 10 : (int)yard];
            formatString = NSLocalizedString(@"yd", nil);
        }
    }
    
    if ([valueString isEqualToString:@"-1"]) {
        valueString = @"";
        formatString = @"";
    }
    
    return [NSString stringWithFormat:@"%@ %@", valueString, formatString];
}

+ (float)convertFromMeters:(int)meters toDistanceWithFormat:(SKTNavigationUnitReturnFormat)returnFormat {
    float returnedDistance = 0.0;
    switch ( returnFormat ) {
        case SKTNavigationUnitReturnKilometers:{
            returnedDistance = meters * 0.001;
        }
            break;
            
        case SKTNavigationUnitReturnFeet:{
            returnedDistance = meters * 3.2808398950131;
        }
            break;
            
        case SKTNavigationUnitReturnYards:{
            returnedDistance = meters * 1.0936132983377;
        }
            break;
            
        case SKTNavigationUnitReturnMiles:{
            returnedDistance = meters * 0.00062137119223733;
        }
            break;
            
        default:
            break;
    }
    
    return returnedDistance;
}

+ (float)convertSpeed:(float)metersPerSecond toFormat:(SKDistanceFormat)distanceFormat {
    if (distanceFormat == SKDistanceFormatMetric) {
        return metersPerSecond * kSKTMPSToKMPH;
    } else {
        return metersPerSecond * kSKTMPSToMPH;
    }
}

+ (SKTransportMode)transportModeFromRouteMode:(SKRouteMode)routeMode {
    switch (routeMode) {
        case SKRouteCarShortest:
            return SKTransportCar;
            break;
        case SKRouteCarFastest:
            return SKTransportCar;
            break;
        case SKRouteCarEfficient:
            return SKTransportCar;
            break;
        case SKRouteBicycleFastest:
            return SKTransportBicycle;
            break;
        case SKRouteBicycleQuietest:
            return SKTransportBicycle;
            break;
        case SKRouteBicycleShortest:
            return SKTransportBicycle;
            break;
        case SKRoutePedestrian:
            return SKTransportPedestrian;
            break;
            
        default:
            return SKTransportCar;
            break;
    }
}

+ (SKTNavigationViewType)navigationViewTypeFromRouteMode:(SKRouteMode)routeMode {
    switch (routeMode) {
        case SKRouteCarShortest:
            return SKTNavigationViewTypeCar;
            break;
        case SKRouteCarFastest:
            return SKTNavigationViewTypeCar;
            break;
        case SKRouteCarEfficient:
            return SKTNavigationViewTypeCar;
            break;
        case SKRouteBicycleFastest:
            return SKTNavigationViewTypeCar;
            break;
        case SKRouteBicycleQuietest:
            return SKTNavigationViewTypeCar;
            break;
        case SKRouteBicycleShortest:
            return SKTNavigationViewTypeCar;
            break;
        case SKRoutePedestrian:
            return SKTNavigationViewTypePedestrian;
            break;
            
        default:
            return SKTNavigationViewTypeCar;
            break;
    }
}

+ (SKTNavigationFreeDriveViewType)navigationFreeDriveViewTypeFromRouteMode:(SKRouteMode)routeMode {
    switch (routeMode) {
        case SKRouteCarShortest:
            return SKTNavigationFreeDriveViewTypeCar;
            break;
        case SKRouteCarFastest:
            return SKTNavigationFreeDriveViewTypeCar;
            break;
        case SKRouteCarEfficient:
            return SKTNavigationFreeDriveViewTypeCar;
            break;
        case SKRouteBicycleFastest:
            return SKTNavigationFreeDriveViewTypeCar;
            break;
        case SKRouteBicycleQuietest:
            return SKTNavigationFreeDriveViewTypeCar;
            break;
        case SKRouteBicycleShortest:
            return SKTNavigationFreeDriveViewTypeCar;
            break;
        case SKRoutePedestrian:
            return SKTNavigationFreeDriveViewTypePedestrian;
            break;
            
        default:
            return SKTNavigationFreeDriveViewTypeCar;
            break;
    }
}


+ (NSString *)convertMeters:(int)meters toUnitFormat:(SKTNavigationUnitReturnFormat)returnFormat {
    float returnedDistance = 0;
    NSString *returnString = nil;
    switch (returnFormat) {
        case SKTNavigationUnitReturnFeet: {
            returnedDistance = meters * 3.2808398950131;
            returnString = NSLocalizedString(@"ft_key",nil);
        }
            break;
        case SKTNavigationUnitReturnKilometers: {
            returnedDistance = meters * 0.001;
            returnString = NSLocalizedString(@"km_key",nil);
        }
            break;
        case SKTNavigationUnitReturnYards: {
            returnedDistance = meters * 1.0936132983377;
            returnString = NSLocalizedString(@"yd_key",nil);
        }
            break;
        case SKTNavigationUnitReturnMiles: {
            returnedDistance = meters * 0.00062137119223733;
            returnString = NSLocalizedString(@"mi_key",nil);
        }
            break;
            
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%f %@",returnedDistance,returnString];
}

static const double kOfficialZenith = 90.5;
#define deg(x) (x * 180 / M_PI)
#define rad(x) (x * M_PI / 180.0)
/** Returns the hour that the given time of day switches. 
    E.g. for day it returns the hour that the sun rises, for night returns the hour that the sun sets.
    implemented using http://williams.best.vwh.net/sunrise_sunset_algorithm.htm
 */
+ (double)switchHourForTimeOfDay:(SKTNavigationTimeOfDay)timeOfDay location:(CLLocationCoordinate2D)location {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [components setTimeZone:[NSTimeZone systemTimeZone]];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    
//1. first calculate the day of the year

	double N1 = floor(275 * month / 9);
	double N2 = floor((month + 9) / 12);
	double N3 = (1 + floor((year - 4 * floor(year / 4) + 2) / 3));
	double N = N1 - (N2 * N3) + day - 30;

//2. convert the longitude to hour value and calculate an approximate time

	double lngHour = location.longitude / 15;
	double t = 0.0;
	if (timeOfDay == SKTNavigationDay) {
        t = N + ((6 - lngHour) / 24);
    } else {
        t = N + ((18 - lngHour) / 24);
    }

//3. calculate the Sun's mean anomaly
	
	double M = (0.9856 * t) - 3.289;

//4. calculate the Sun's true longitude
	
	double L = M + (1.916 * sin(rad(M))) + (0.020 * sin(rad(2 * M))) + 282.634;
//	NOTE: L potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
    L = normalize(L, 360.0);

//5a. calculate the Sun's right ascension
	
	double RA = deg(atan(0.91764 * tan(rad(L))));
//	NOTE: RA potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
    RA = normalize(RA, 360.0);

//5b. right ascension value needs to be in the same quadrant as L

	double Lquadrant  = (floor( L/90)) * 90;
	double RAquadrant = (floor(RA/90)) * 90;
	RA = RA + (Lquadrant - RAquadrant);

//5c. right ascension value needs to be converted into hours

	RA = RA / 15;

//6. calculate the Sun's declination

	double sinDec = 0.39782 * sin(rad(L));
	double cosDec = cos(asin(sinDec));

//7a. calculate the Sun's local hour angle
	
	double cosH = (cos(rad(kOfficialZenith)) - (sinDec * sin(rad(location.latitude)))) / (cosDec * cos(rad(location.latitude)));
	
	if (cosH >  1 && timeOfDay == SKTNavigationDay)  {
        return -1;
    } if (cosH < -1 && timeOfDay == SKTNavigationNight) {
        return -1;
    }

//7b. finish calculating H and convert into hours
	double H = 0.0;
	if (timeOfDay == SKTNavigationDay) {
        H = 360 - deg(acos(cosH));
    } else {
        H = deg(acos(cosH));
    }
    
    H = H / 15;

//8. calculate local mean time of rising/setting
	
    double T = H + RA - (0.06571 * t) - 6.622;

//9. adjust back to UTC
	
    double UT = T - lngHour;
//	NOTE: UT potentially needs to be adjusted into the range [0,24) by adding/subtracting 24
    UT = normalize(UT, 24.0);

//10. convert UT value to local time zone of latitude/longitude
	
    double localOffset = [[components timeZone] secondsFromGMTForDate:[NSDate date]] / 3600.0;
	double localT = UT + localOffset;
    localT = normalize(localT, 24.0);
    return localT;
}

+ (double)switchHourForTimeOfDay:(SKTNavigationTimeOfDay)timeOfDay {
    CLLocationCoordinate2D pos = [[SKPositionerService sharedInstance] currentCoordinate];
    return [SKTNavigationUtils switchHourForTimeOfDay:timeOfDay location:pos];
}

/** Normalize x to [0, max) range
 */
inline static double normalize(double x, double max) {
    if (x < 0) {
        while (x < 0) {
            x += max;
        }
    } else {
        while (x >= max) {
            x -= max;
        }
    }
    
    return x;
}

+ (SKTNavigationTimeOfDay)timeOfDay {
    double dayTime = [SKTNavigationUtils switchHourForTimeOfDay:SKTNavigationDay];
    double nightTime = [SKTNavigationUtils switchHourForTimeOfDay:SKTNavigationNight];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];
    double currentTime = [components hour] + [components minute] / 60.0;
    if (currentTime >= dayTime && currentTime <= nightTime) {
        return SKTNavigationDay;
    } else {
        return SKTNavigationNight;
    }
}

+ (BOOL)isNight {
    return ([SKTNavigationUtils timeOfDay] == SKTNavigationNight);
}

+ (void)cancelLocalNoficationWithUserInfoKey:(NSString *)userInfoKey {
    NSArray *notifications = [NSArray arrayWithArray:[UIApplication sharedApplication].scheduledLocalNotifications];
    for (UILocalNotification *notification in notifications) {
        if (notification.userInfo[userInfoKey]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

+ (NSString *)audioFilesFolderPathForLanguage:(SKAdvisorLanguage)language {
    NSBundle* advisorResourcesBundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SKAdvisorResources.bundle"]];
    NSString* soundFilesFolder = [advisorResourcesBundle pathForResource:@"Languages" ofType:@""];
    NSString* audioFilesFolderPath = [NSString stringWithFormat:@"%@/%@/sound_files", soundFilesFolder, [SKTNavigationUtils languageNameForLanguage:language]];
    
    return audioFilesFolderPath;
}

+ (NSString *)currentCountryCode {
    SKSearchResult *result = [[SKReverseGeocoderService sharedInstance] reverseGeocodeLocation:[SKPositionerService sharedInstance].currentCoordinate];
    
    for (SKSearchResultParent *parent in result.parentSearchResults) {
        if (parent.type == SKSearchResultCountryCode) {
            return parent.name;
        }
    }
    
    return nil;
}

+ (NSString *)backgroundColorNameForStreetType:(SKStreetType)streetType {
    switch (streetType) {
        case SKStreetTypeMotorway:
            return @"motorway";
            break;
        case SKStreetTypeMotorway_link:
            return @"motorway_link";
            break;
        case SKStreetTypePrimary:
            return @"primary";
            break;
        case SKStreetTypePrimary_link:
            return @"primary_link";
            break;
        case SKStreetTypeTrunk:
            return @"trunk";
            break;
        case SKStreetTypeTrunk_link:
            return @"trunk_link";
            break;
        default:
            return @"any_road";
            break;
    }
}

+ (NSString *)adviceSignColorNameForStreetType:(SKStreetType)streetType {
    switch (streetType) {
        case SKStreetTypeMotorway:
            return @"motorway_advice_route_color";
            break;
        case SKStreetTypeMotorway_link:
            return @"motorway_link_advice_route_color";
            break;
        case SKStreetTypePrimary:
            return @"primary_advice_route_color";
            break;
        case SKStreetTypePrimary_link:
            return @"primary_link_advice_route_color";
            break;
        case SKStreetTypeTrunk:
            return @"trunk_advice_route_color";
            break;
        case SKStreetTypeTrunk_link:
            return @"trunk_link_advice_route_color";
            break;
        default:
            return @"any_road_advice_route_color";
            break;
    }
}


+ (NSString *)streetTextColorNameForStreetType:(SKStreetType)streetType {
    switch (streetType) {
        case SKStreetTypeMotorway:
            return @"motorway_street_name_text_color";
            break;
        case SKStreetTypeMotorway_link:
            return @"motorway_link_street_name_text_color";
            break;
        case SKStreetTypePrimary:
            return @"primary_street_name_text_color";
            break;
        case SKStreetTypePrimary_link:
            return @"primary_link_street_name_text_color";
            break;
        case SKStreetTypeTrunk:
            return @"trunk_street_name_text_color";
            break;
        case SKStreetTypeTrunk_link:
            return @"trunk_link_street_name_text_color";
            break;
        default:
            return @"any_road_street_name_text_color";
            break;
    }
}

+ (NSString *)statusBarStyleNameForStreetType:(SKStreetType)streetType {
    switch (streetType) {
        case SKStreetTypeMotorway:
            return @"motorway_statusBarStyleDefault";
            break;
        case SKStreetTypeMotorway_link:
            return @"motorway_link_statusBarStyleDefault";
            break;
        case SKStreetTypePrimary:
            return @"primary_statusBarStyleDefault";
            break;
        case SKStreetTypePrimary_link:
            return @"primary_link_statusBarStyleDefault";
            break;
        case SKStreetTypeTrunk:
            return @"trunk_statusBarStyleDefault";
            break;
        case SKStreetTypeTrunk_link:
            return @"trunk_link_statusBarStyleDefault";
            break;
        default:
            return @"any_road_statusBarStyleDefault";
            break;
    }
}

+ (NSString *)destinationImageNameForStreetType:(SKStreetType)streetType {
    switch (streetType) {
        case SKStreetTypeMotorway:
            return @"motorway_destination_image_name";
            break;
        case SKStreetTypeMotorway_link:
            return @"motorway_link_destination_image_name";
            break;
        case SKStreetTypePrimary:
            return @"primary_destination_image_name";
            break;
        case SKStreetTypePrimary_link:
            return @"primary_link_destination_image_name";
            break;
        case SKStreetTypeTrunk:
            return @"trunk_destination_image_name";
            break;
        case SKStreetTypeTrunk_link:
            return @"trunk_link_destination_image_name";
            break;
        default:
            return @"any_road_destination_image_name";
            break;
    }
}

+ (BOOL)locationIsZero:(CLLocationCoordinate2D)location {
    return (fabs(location.latitude) < 0.000001 && fabs(location.longitude) < 0.000001);
}

+ (NSArray *)streetCityAndCountryForLocation:(CLLocationCoordinate2D)location {
    NSString *street = @"";
    NSString *city = @"";
    NSString *country = @"";
    
    SKSearchResult *result = [[SKReverseGeocoderService sharedInstance] reverseGeocodeLocation:location];
    
    switch (result.type) {
        case SKSearchResultStreet:
            street = result.name;
            break;
            
        case SKSearchResultCity:
            city = result.name;
            break;
            
        case SKSearchResultCountry:
            country = result.name;
            break;
            
        default:
            break;
    }

    for (SKSearchResultParent *parent in result.parentSearchResults) {
        switch (parent.type) {
            case SKSearchResultCity:
                if ([city isEmptyOrWhiteSpace]) {
                    city = parent.name;
                }
                break;
                
            case SKSearchResultStreet:
                if ([street isEmptyOrWhiteSpace]) {
                    street = parent.name;
                }
                break;
                
            case SKSearchResultCountry:
                if ([country isEmptyOrWhiteSpace]) {
                    country = parent.name;
                }
                break;
                
            default:
                break;
        }
    }
    
    return @[safeString(street), safeString(city), safeString(country)];
}

static const char *languageMap[] =
    {"da",
    "de",
    "en",
    "en_us",
    "es",
    "fr",
    "hu",
    "it",
    "nl",
    "pl",
    "pt",
    "ro",
    "ru",
    "sv",
    "tr",
    "ch_can",
    "ch_man",
    "kor",
    "es_sa",
    "fr_can",
    "jap"};

+ (NSString *)languageNameForLanguage:(SKAdvisorLanguage)language {
    return [NSString stringWithUTF8String:languageMap[language]];
}

+ (NSBundle *)navigationBundle {
    return [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:kSKTNavigationResourcesBundle withExtension:nil]];
}

@end
