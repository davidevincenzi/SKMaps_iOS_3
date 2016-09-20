//
//  SKOneBoxTestCase.h
//  SKOneBoxSearch
//
//  Created by Dragos Dobrean on 15/01/16.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SKOSearchLib/SKOSearchLib.h>

/** Class used by the testin algortihm which encapsulates all
 details about a search and its results
*/

@interface SKOneBoxTestCase : NSObject

/** Creates an object from a JSON Dictionary read from the disk
 */
- (instancetype)initFromJSONDictionary:(NSDictionary *)dictionary;

/** Creates an object from the search results and the search object used for obtaining those results
 */
- (instancetype)initWithSearchResults:(NSDictionary *)results searchObject:(SKOneBoxSearchObject *)searchObject andProvidersNames:(NSDictionary *)providersNames;

/** Creates an dictionary from all the values that the object contains
 */
- (NSDictionary *)toJSONDictionary;

/** Returns the search object for the test case
 */
- (SKOneBoxSearchObject *)searchObject;

/** Get the results for the current test case
 */
- (NSDictionary *)allResults;

/** Returns the provider names
 */
- (NSDictionary *)allProviderNames;

@end
