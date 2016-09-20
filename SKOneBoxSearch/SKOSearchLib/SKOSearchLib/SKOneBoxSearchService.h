//
//  SKOneBoxSearchService.h
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 02/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SKOSearchLib/SKOneBoxSearchObject.h>
#import "SKSearchProviderProtocol.h"
#import "SKOneBoxDataController.h"

@class SKOneBoxSearchService;

/** Search service protocol.
 */
@protocol SKOneBoxSearchServiceDelegate <NSObject>

/** Callback sent by the search service containing results and the provider from which the results are from.
 @param searchService Search service which handles the providers.
 @param results Results retrieved by a provider.
 @param provider The provider from which the results came from.
 */
- (void)searchService:(SKOneBoxSearchService *)searchService didReceiveResults:(NSArray *)results forProvider:(id<SKSearchProviderProtocol>)provider;

/** Callback sent by the search service containing marked top hit results and the provider from which the results are from.
 @param searchService Search service which handles the providers.
 @param results all the current results.
 */
@optional
- (void)searchService:(SKOneBoxSearchService *)searchService didMarkTopHitResults:(NSDictionary *)results;

@end

/** Search service exposed to the View Controllers to handle the searches for each provider.
 */
@interface SKOneBoxSearchService : NSObject

/** Search providers contained in this search service.
 */
@property (nonatomic, strong, readonly) NSArray *searchProviders;

/** Data controller for search service. Data controller which communicates with the data controller for each provider.
 */
@property (nonatomic, strong, readonly) SKOneBoxDataController *dataController;

/** Boolean indicating if a search is currently in progress.
 */
@property (nonatomic, assign, readonly) BOOL isSearching;

/** Designated initializer.
 @param searchProviders Array of search providers to be used by the search service.
 @param relevancyType minimum relevancy type supported by the filtering controller.
 @param shouldUseFilter wether to apply filtering to received results.
 @return SKOneBoxSearchService instance.
 */
- (instancetype)initWithSearchProviders:(NSArray *)searchProviders withMinimumRelevancy:(SKOneBoxSearchResultRelevancyType)relevancyType shouldUseFilter:(BOOL)shouldUseFilter;

/** Function to add search service delegate.
 @param delegate. The caller objects should adopt the SKOneBoxSearchServiceDelegate to receive callbacks.
 */
- (void)addDelegate:(id<SKOneBoxSearchServiceDelegate>)delegate;

/** Function to remove search service delegate.
 @param delegate. The object to remove from the delegates array.
 */
- (void)removeDelegate:(id<SKOneBoxSearchServiceDelegate>)delegate;

/** Function to cancel an ongoing search.
 */
- (void)cancelSearch;

/** Function to cancel an ongoing search for a specific provider.
 @param provider. The provider for which to cancel the search.
 */
- (void)cancelSearchForProvider:(id<SKSearchProviderProtocol>)provider;

/** Search function to call on search service. The search object in turn will be passed to each search provider.
 @param searchObject - stores the input parameters for the oneline search.
 */
- (void)search:(SKOneBoxSearchObject *)searchObject;

/** Search function to call on a specific search provider.
 @param searchObject Stores the input parameters for the oneline search.
 @param provider Provider on which to search.
 */
- (void)search:(SKOneBoxSearchObject *)searchObject forProvider:(id<SKSearchProviderProtocol>)provider;

/** Returns the meta data for a provider.
 @param provider Provider for which to return the meta data.
 @return current meta data for a provider.
 */
- (SKOneBoxSearchResultMetaData *)currentMetaDataForProvider:(id<SKSearchProviderProtocol>)provider;

/** Returns the current search object for a provider.
 @param provider Provider for which to return the current search object.
 @return current search object.
 */
- (SKOneBoxSearchObject *)currentSearchObjectForProvider:(id<SKSearchProviderProtocol>)provider;

/** Returns the provider for a unique provider id.
 @param providerId The id of the provider to find.
 @return The found provider.
 */
- (id<SKSearchProviderProtocol>)providerForProviderId:(NSNumber*)providerId;

/** Function to clean data for all providers.
 */
- (void)clearSearchData;

/** Function to clean data for a specific provider.
 @param provider. The provider for which to clear the search.
 */
- (void)clearSearchDataProvider:(id<SKSearchProviderProtocol>)provider;

/** Function to check if a provider is searching.
 @param provider. The provider for which to clear the search.
 @return boolean indicating if the provider is searching.
 */
-(BOOL)isProviderSearching:(id<SKSearchProviderProtocol>)provider;

/** Function to check if a set of provider are searching.
 @param providers. The providers for which to check if they are searching.
 @return boolean indicating if the providers are searching.
 */
-(BOOL)areProvidersSearching:(NSArray*)providers;

@end
