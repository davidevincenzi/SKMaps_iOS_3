//
//  SKOneBoxFilterController.h
//  SKOSearchLib
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKOneBoxSearchResult.h"
#import "SKOneBoxSearchObject.h"
#import "SKOneBoxFilter.h"
#import "SKSearchProviderProtocol.h"

@class SKOneBoxFilterController;

/** Filter controller protocol.
 */
@protocol SKOneBoxFilterControllerDelegate <NSObject>

/** Callback sent by the filter controller containing the most probable location.
 @param controller Filter controller which handles the filtering.
 @param result the most problable location of the search.
 */
-(void)filterController:(SKOneBoxFilterController*)controller didFindMostProbableLocation:(SKOneBoxSearchResult*)result;

@end

@interface SKOneBoxFilterController : NSObject

/** Delegate on which callbacks are sent.
 */
@property (nonatomic, weak) id<SKOneBoxFilterControllerDelegate> delegate;

/** An array with the search providers, used by the top hit algorithm,
 for the order obtaining the correct order of the providers
 */
@property (nonatomic, strong) NSArray *providers;

/** Init function, returns a filter controller with the relevancy type specified.
 @param relevancyType - used to filter results.
 */
- (id)initWithMinimumRelevancy:(SKOneBoxSearchResultRelevancyType)relevancyType;

/** Filter function.
 @param dictionaryToFilter the dictionary of objects to filter.
 @param searchObject the search object used for the current search.
 @param completionBlock completion block to be called at the end of the filter process.
 @param top hits block called after the results have been marked as top
 */
-(void)filterResults:(NSDictionary*)dictionaryToFilter searchObject:(SKOneBoxSearchObject*)searchObject completionBlock:(void (^)(NSDictionary *filteredDictionary))completionBlock andTopHitsBlock:(void (^)(NSDictionary *filteredDictionary))topHitsBlock;

/** Reset clusters
 Used when a search was canceled and we need to delete all the existing clusters.
 */
- (void)resetClusters;

@end
