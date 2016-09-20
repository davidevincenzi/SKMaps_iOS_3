//
//  SKOneBoxSearchResult.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

typedef NS_ENUM (NSInteger, SKOSearchResultType)
{
    SKOSearchResultCountry = 0,
    SKOSearchResultAdministrativeArea,
    SKOSearchResultLocality,
    SKOSearchResultSubLocality,
    SKOSearchResultNeighborhood,
    SKOSearchResultStreet,
    SKOSearchResultPostalCode,
    SKOSearchResultPOI
};

/**Object returned by SKOSearchLib search services.
 */
@interface SKOSearchResult : NSObject

/**Unique identifier for the search result.
 */
@property (nonatomic, strong) NSString *uid;

/**Coordinate for the search result.
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/** The name of the search result.
 */
@property(nonatomic, strong) NSString *name; // eg. Apple Inc.

/** Street address, eg. 1 Infinite Loop.
 */
@property (nonatomic, strong) NSString *street;

/** City, eg. Cupertino.
 */
@property (nonatomic, strong) NSString *locality;

/** Neighborhood, common name, eg. Mission District.
 */
@property (nonatomic, strong) NSString *subLocality;

/** State, eg. California.
 */
@property (nonatomic, strong) NSString *administrativeArea;

/** State, eg. CA.
 */
@property (nonatomic, strong) NSString *administrativeAreaCode;

/** County, eg. Santa Clara.
 */
@property (nonatomic, strong) NSString *subAdministrativeArea;

/** Zip code, eg. 95014.
 */
@property (nonatomic, strong) NSString *postalCode;

/** House number, eg. 1.
 */
@property (nonatomic, strong) NSString *houseNumber;

/** ISO Country code eg. US.
 */
@property (nonatomic, strong) NSString *ISOcountryCode;

/** Country for the search result eg. United States.
 */
@property (nonatomic, strong) NSString *country;

/** Additional information for search result.
 */
@property(nonatomic, strong) NSDictionary *additionalInformation;

/**The one line address for the POI retrieved by the search. Some searches (e.g. Trip Advisor search) provide this information.
 */
@property(nonatomic, strong) NSString *onelineAddress;

/** POI Type
 */
@property (nonatomic, assign) SKOSearchResultType type;

/**Creates an empty SKOneBoxSearchResult
 @return - an empty autoreleased object
 */
+ (instancetype)searchResult;

@end
