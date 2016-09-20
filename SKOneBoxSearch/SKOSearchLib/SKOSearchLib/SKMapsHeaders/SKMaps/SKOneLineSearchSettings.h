//
//  SKOneLineSearchSettings.h
//  SKMaps
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "SKDefinitions.h"

/** SKOneLineSearchSettings stores the input parameters for a one line search.
 */
@interface SKOneLineSearchSettings : NSObject

/** The connectivity mode of the search. The default value is SKSearchOnline. The SKSearchHybrid is not supported at this point.
 */
@property(nonatomic, assign) SKSearchMode searchMode;

/** The code of the country where the search is executed. This is an optional parameter, but it can improve search speed.
 */
@property(nonatomic, strong) NSString *countryCode;

/** The search term is used to filter the results. It should be empty for all the results.
 */
@property(nonatomic, strong) NSString *searchTerm;

/** The center location of the searched area. This is an optional parameter, but it can help to return better search results.
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/** A newly initialized SKOneLineSearchSettings.
 */
+ (instancetype)oneLineSearchSettings;

@end
