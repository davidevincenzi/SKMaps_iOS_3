//
//  SKOneBoxSearchObject.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

/**SKOneBoxSearchObject - stores the information for a one box search.
 */
@interface SKOneBoxSearchObject : NSObject <NSCopying>

/**Coordinate for the search.
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/**Search term
 */
@property(nonatomic, strong) NSString *searchTerm;

/**Search language
 */
@property(nonatomic, strong) NSString *searchLanguage;

/**How many items to be displayed per page (should be set for searches that support pagination). Can be Nil.
 */
@property(nonatomic, strong) NSNumber *itemsPerPage;

/**The page index for the current search (should be set for searches that support pagination). Can be Nil.
 */
@property(nonatomic, strong) NSNumber *pageIndex;

/**The page url (should be set for searches that support pagination using next/previous urls). Can be Nil.
 */
@property(nonatomic, strong) NSString *pageToLoad;

/**Search radius in meters (should be set for searches that support radius). Can be Nil.
 */
@property(nonatomic, strong) NSNumber *radius;

/**Search category (should be set for searches that support categories). Can be Nil.
 */
@property(nonatomic, strong) id searchCategory;

/**Search sorting (should be set for searches that support categories). Can be Nil.
 */
@property(nonatomic, strong) id searchSort;

//TODO
@property(nonatomic, strong) NSString *uid;

/**Creates an empty SKOneBoxSearchObject
 @return - an empty autoreleased object
 */
+ (instancetype)oneBoxSearchObject;

/** Will return how many components the search term has
 A component is a grup of letters which which is separated by: (spaces, ',')
 */
- (long)numberOfComponents;

/** Checks if the name of the searched location matches a provided string
 Fetches from the initial term the probable location, and compares it with Levenstein
 distance with the provided string
 */
- (BOOL)nameMatchesWithString:(NSString *)name;

/** Returns the string in "quotes" from the initial search term
 */
- (NSString *)quoteString;

- (BOOL)isEqualToSearchObject:(SKOneBoxSearchObject*)object;

@end
