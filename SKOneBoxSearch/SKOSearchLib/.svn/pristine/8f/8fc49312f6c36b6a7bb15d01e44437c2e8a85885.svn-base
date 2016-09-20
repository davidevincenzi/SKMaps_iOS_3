//
//  SKOneBoxOrdering.h
//  SKOSearchLib
//
//  Created by Dragos Dobrean on 25/01/16.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKOneBoxSearchObject.h"
#import "SKOneBoxSearchResult.h"

@interface SKOneBoxOrdering : NSObject

/** Resets the clusters for a new search
 */
- (void)stopSearch;

/** Order the results
 @param dictionaryToFilter - the dictionary of the results we need to filter
 @param seachObject - the search object used for filtering
 @param completitionBlock - the completition block with the results
 */
- (void)orderResultsFrom:(NSDictionary *)dictionaryToFilter withSearchObject:(SKOneBoxSearchObject *)searchObject completionBlock:(void (^)(NSDictionary *filteredDictionary))completionBlock;

@end
