//
//  SKSearchProviderDataController.h
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 02/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKSearchProviderProtocol.h"

@class SKSearchProviderDataController;

/** Search provider data controller protocol.
 */
@protocol SKSearchProviderDataControllerDelegate <NSObject>

/** Callback sent by the provider data controller containing results and the provider from which the results are from.
 @param dataController Data controller which handles the providers.
 @param results Results received by the provider.
 */
- (void)searchProviderDataController:(SKSearchProviderDataController *)dataController didReceiveSearchResults:(NSArray*)results;

@end

/** Search provider data controller which contains results from a search provider.
 */
@interface SKSearchProviderDataController : NSObject

/** Delegate on which callbacks are sent.
 */
@property (nonatomic, weak) id<SKSearchProviderDataControllerDelegate> delegate;

/** Search provider which corresponds to the search provider data controller.
 */
@property (nonatomic, strong, readonly) id<SKSearchProviderProtocol> searchProvider;

/** Results received on the last search.
 */
@property (atomic, strong, readonly) NSArray *results;

/** Meta data corresponding to the last search.
 */
@property (atomic, strong, readonly) SKOneBoxSearchResultMetaData *metaData;

/** Search object corresponding to the last search.
 */
@property (atomic, strong, readonly) SKOneBoxSearchObject         *searchObject;

/** Boolean indicating wether the search provider is searching.
 */
@property (atomic, assign, readonly) BOOL isSearching;

/** Designated initializer. Create a search provider data controller using a search provider.
 @param searchProvider - Search provider with which to create the search provider data controller.
 */
- (instancetype)initWithSearchProvider:(id<SKSearchProviderProtocol>)searchProvider;

/** Search function to call on search service. The search object in turn will be passed to each search provider.
 @param searchObject - stores the input parameters for the oneline search.
 */
- (void)search:(SKOneBoxSearchObject *)searchObject;

/** Function to cancel an ongoing search.
 */
- (void)cancelSearch;

/** Function to clear search results.
 */
- (void)clearSearch;

@end
