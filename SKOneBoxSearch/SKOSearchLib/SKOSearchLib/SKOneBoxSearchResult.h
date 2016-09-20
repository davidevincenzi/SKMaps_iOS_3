//
//  SKOneBoxSearchResult.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

extern NSString *const kSearchResultAdditionalInformationAPIRanking;

typedef NS_ENUM (NSInteger, SKOneBoxSearchResultType)
{
    SKOneBoxSearchResultCountry = 0,
    SKOneBoxSearchResultAdministrativeArea,
    SKOneBoxSearchResultLocality,
    SKOneBoxSearchResultSubLocality,
    SKOneBoxSearchResultNeighborhood,
    SKOneBoxSearchResultStreet,
    SKOneBoxSearchResultPostalCode,
    SKOneBoxSearchResultPOI
};

typedef NS_ENUM (NSInteger, SKOneBoxSearchResultRelevancyType)
{
    SKOneBoxSearchResultHighRelevancy = 0,
    SKOneBoxSearchResultMediumRelevancy,
    SKOneBoxSearchResultLowRelevancy
};

@interface SKOneBoxSearchResult : NSObject <NSCopying>

/**Unique identifier. This will be set by the search provider.
 */
@property(nonatomic, strong) NSString *uid;

/**Coordinate for the search result.
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/**Type of the search result.
 */
@property(nonatomic, assign) SKOneBoxSearchResultType type;

/**Relevancy type of the search result.
 If the search result is in the area of other search results from other providers -> SKOneBoxSearchResultHighRelevancy
 If the search result is not in the area of other search results from other providers, but the search term matches, and distance is not very far far away -> SKOneBoxSearchResultMediumRelevancy
 If the search result is not in the area of other search results from other providers, doesn't match the search term and distance is far far away -> SKOneBoxSearchResultLowRelevancy. This can be filtered out based on this relevancy type
 */
@property(nonatomic, assign) SKOneBoxSearchResultRelevancyType relevancyType;

/**Wether the result is a top result or not.
 */
@property(nonatomic, assign) BOOL topResult;

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

/** Debug value, expected
 */
@property (nonatomic, assign) BOOL expected;

/** Creates an SKOneBoxSearchResult with the values from
 the dictionary provided
 */
- (instancetype)initFromJSONDictionary:(NSDictionary *)dictionary;

/**Creates an empty SKOneBoxSearchResult
 @return - an empty autoreleased object
 */
+ (instancetype)oneBoxSearchResult;

- (BOOL)matchesSearchTerm:(NSString *)searchTerm rankingWeight:(double*)rankingWeight;
- (double)rankingWeightTitleForSearchTerm:(NSString *)searchTerm;

- (BOOL)hasLocationData;

/** Returns a string of locality, sublocality and administrative area
 joined by " "
 */
- (NSString *)localityComponentsString;

/** Returns a JSON Dictionary from the contents of the object
 */
- (NSDictionary *)toJSONDictionary;

/** Returns a boolean indicating if the result is valid. The result must have coordinates different than 0,0
 */
- (BOOL)isValid;

/** Sets a new ranking in the additional information field
 @param ranking the new ranking of the object
 */
- (void)setNewRanking:(double)ranking;

/** Returns a boolean indicating if the result is a major city
 */
- (BOOL)isMajorCity;

@end
