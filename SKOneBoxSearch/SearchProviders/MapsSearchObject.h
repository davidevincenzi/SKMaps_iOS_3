//
//  MapsSearchObject.h
//

#import <SKOSearchLib/SKOSearchLib.h>

@interface MapsSearchObject : SKOBaseSearchObject

/** The code of the country where the search is executed.
 */
@property(nonatomic, strong) NSString *countryCode;

/** The search term is used to filter the results. It should be empty for all the results.
 */
@property(nonatomic, strong) NSString *searchTerm;

/** The center location of the searched area. This is an optional parameter but it can help to return better search results
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/** Specifies the search categories for the POI's.
 */
@property(nonatomic, strong) NSArray *searchCategories;

/** How many items to be displayed per page (should be set for searches that support pagination). Can be Nil.
 */
@property(nonatomic, strong) NSNumber *itemsPerPage;

/** Search radius in meters (should be set for searches that support radius). Can be Nil.
 */
@property(nonatomic, strong) NSNumber *radius;

/** A newly initialized MapsSearchObject.
 */
+ (instancetype)searchObject;

@end
