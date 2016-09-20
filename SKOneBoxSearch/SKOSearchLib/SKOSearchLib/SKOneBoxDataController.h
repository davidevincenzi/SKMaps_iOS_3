//
//  SKOneBoxDataController.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKSearchProviderProtocol.h"

@class SKOneBoxSearchObject;
@class SKOneBoxDataController;
@class SKOneBoxSearchResultMetaData;
@class SKOneBoxFilterController;

/** Data controller protocol.
 */
@protocol SKOneBoxDataControllerDelegate <NSObject>

/** Callback sent by the data controller containing results and the provider from which the results are from.
 @param dataController Data controller which handles the providers.
 @param results results from provider
 @param provider The provider from which the results came from.
 */
- (void)oneBoxDataController:(SKOneBoxDataController *)dataController didReceiveResults:(NSDictionary*)results fromProvider:(id<SKSearchProviderProtocol>)provider;

@optional
/** Callback sent by the data controller containing results and the provider from which the results are from.
 @param dataController Data controller which handles the providers.
 @param results all the results and among them we also find those with topResult set to YES
 */
- (void)oneBoxDataController:(SKOneBoxDataController *)dataController didReceiveTopHitResults:(NSDictionary*)results;

@end

/** Data controller which contains a search provider data controller for each search provider.
 */
@interface SKOneBoxDataController : NSObject

/** Delegate on which callbacks are sent.
 */
@property (nonatomic, weak) id<SKOneBoxDataControllerDelegate> delegate;

/** Boolean indicating wether any of the search providers are searching.
 */
@property (nonatomic, assign, readonly) BOOL isSearching;

/** Dictionary containing the results for each provider.
 */
@property (atomic, strong, readonly) NSDictionary *results;

- (instancetype)initWithSearchProviders:(NSArray *)searchProviders filteringController:(SKOneBoxFilterController*)filterController;

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

/** Function to cancel an ongoing search.
 */
- (void)cancelSearch;

/** Function to cancel an ongoing search for a specific provider.
 @param provider. The provider for which to cancel the search.
 */
- (void)cancelSearchForProvider:(id<SKSearchProviderProtocol>)provider;

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
- (void)clearSearchForProvider:(id<SKSearchProviderProtocol>)provider;

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

/** Function to return results for a provider.
 @param provider. The provider for which to clear the search.
 @return results for the specified provider.
 */
-(NSArray*)resultsForProvider:(id<SKSearchProviderProtocol>)provider;

@end
