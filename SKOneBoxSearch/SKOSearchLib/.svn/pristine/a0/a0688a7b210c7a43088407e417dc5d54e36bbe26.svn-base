//
//  SKOneBoxFilter.h
//  SKOSearchLib
//
//  Created by Dragos Dobrean on 06/01/16.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKOneBoxSearchObject.h"
#import "SKOneBoxSearchResult.h"

@interface SKOneBoxFilter : NSObject

/** Resets the clusters for a new search
 */
- (void)resetClusters;

/** Sets the cluster radius for the new search object
 This should be called every time the search object changes, after the clusters have been reseted
 */
- (void)setClustersRadius:(SKOneBoxSearchObject *)searchObject;

/** Filters the results
 @param dictionaryToFilter - the dictionary of the results we need to filter
 @param seachObject - the search object used for filtering
 @param completitionBlock - the completition block with the results
 @param probableLocationBlock - the block for the probable location
 */
- (void)filterTheResultsFrom:(NSDictionary *)dictionaryToFilter withSearchObject:(SKOneBoxSearchObject *)searchObject completionBlock:(void (^)(NSDictionary *filteredDictionary))completionBlock andProbableLocationBlock:(void(^)(SKOneBoxSearchResult *probableLocation))probableLocationBlock;

@end
