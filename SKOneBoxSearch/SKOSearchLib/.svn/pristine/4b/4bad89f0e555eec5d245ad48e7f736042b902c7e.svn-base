//
//  SKSearchProviderProtocol.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SKSearchProviderDelegate.h"
#import "SKOneBoxSearchObject.h"
#import "SKOneBoxSearchResult.h"
#import "SKOneBoxSearchResultMetaData.h"

/** Each search provider implemented by the client and used by SKOneBoxSearch component should conform to this protocol
 */
@protocol SKSearchProviderProtocol <NSObject>

/** Overwrite getter to provide your own provider name.
 */
@property (nonatomic, strong, readonly) NSString *localizedProviderName;

/** Overwrite getter to provide your own provider image.
 */
@property (nonatomic, strong) UIImage *providerIcon;

/** Overwrite getter to specify the number of results to be displayed in in the search results.
 */
@property (nonatomic, assign) NSInteger numberOfResultsToShow;

/** Overwrite getter to specify whether the SKOneBoxSearch component should display a header for the provider.
 */
@property (nonatomic, assign) BOOL shouldShowSectionHeader;

/** Overwrite getter to specify whether the SKOneBoxSearch component should display the provider in search results.
 */
@property (nonatomic, assign) BOOL shouldShowSearchProviderInSearchResults;

/** Overwrite getter to specify whether the SKOneBoxSearch component should display the provider in the default list, when there's no search term in the search field.
 */
@property (nonatomic, assign) BOOL shouldAppearInDefaultList;

/** Overwrite getter to specify whether provider supports category search and whether category list can be accesed from the default list.
 */
@property (nonatomic, assign) BOOL shouldShowCategories;

/** Overwrite getter to specify whether the SKOneBoxSearch component should display a header for the provider in the default list.
 */
@property (nonatomic, assign) BOOL shouldShowSectionHeaderDefaultList;

/** Overwrite getter to specify whether pagination is supported for this provider.
 */
@property (nonatomic, assign) BOOL allowsPagination;

/** Overwrite getter to specify the number of categories the SKOneBoxSearch component should display in the default list. if the number of categories is bigger than the number set by the client, an extra item "All categories" will be added to display a list of full categories.
 */
@property (nonatomic, assign) NSInteger numberOfCategoriesToShowDefaultList;

/** Overwrite getter to specify a unique identifier for the provider.
 */
@property (nonatomic, strong) NSNumber  *providerID;

/** Overwrite getter to specify the number of results to be retrieved per page in case the service supports pagination. Default value is 20.
 */
@property (nonatomic, strong) NSNumber *searchNumberOfItemsPerPage;

/** Each provider can have it's own custom UI for displaying data in the result list. Use this block to create your own UITableViewCell.
 */
@property (nonatomic, copy) UITableViewCell* (^providerResultTableViewCell)(UITableView* tableView);

/** Function to populate custom UITableViewCell created by providerResultTableViewCell block.
 */
@property (nonatomic, copy) void (^populateResultTableViewCell)(UITableViewCell* cell, SKOneBoxSearchResult *searchResult);

/** Height of the default custom cell. Only used when providerResultTableViewCell blocks is provided.
 */
@property (nonatomic, assign) CGFloat customResultsCellHeight;

/** Search radius for search provider. By default it's 10km
 */
@property (nonatomic, strong) NSNumber *searchRadius;

/**Category searches supported for the search provider. Objects should be of type SKSearchProviderCategory.
 */
@property (nonatomic, strong) NSArray *categories;

/**The callers objects should adopt the SKSearchProviderDelegate to receive callbacks.
 */
@property (nonatomic, strong) NSHashTable *delegates;

/** Overwrite getter to specify whether filtering and sorting rules should be applied to this provider.
 */
@property (nonatomic, assign) BOOL allowsFiltering;

@required

/**Search function to be implemented with the provider.
 @param searchObject - Search object containing neccesary parameters for a search.
 */
- (void)search:(SKOneBoxSearchObject *)searchObject;

/**Cancels an ongoing search request.
 */
- (void)cancelSearch;

/**Mapping function to be implemented with the provider. Converts specific result from an API to SKOneBoxSearchResult.
 @param searchResult Search result returned by the Search API.
 @return mapped SKOneBoxSearchResult.
 */
- (SKOneBoxSearchResult *)mappedOneBoxSearchResultFromSearchResult:(id)searchResult;

/**Mapping function to be implemented with the provider. Converts specific meta data from an API to SKOneBoxSearchResultMetaData.
 @param searchMetaData Search meta data returned by the Search API.
 @return mapped SKOneBoxSearchResultMetaData.
 */
- (SKOneBoxSearchResultMetaData *)mappedMetaDataObjectFromSearchMetaData:(id)searchMetaData;

/**Function to specify if the search provider is enabled. Function could be used to disable a certain search provider for certain conditions such as geolocation.
 @return Boolean indicating if the search provider should be enabled.
 */
- (BOOL)isSearchProviderEnabled;

- (void)addDelegate:(id<SKSearchProviderDelegate>)delegateObj;
- (void)removeDelegate:(id<SKSearchProviderDelegate>)delegateObj;

@optional

/**Return sorting comparators supported for the search provider. Objects should be of type SKOneBoxSearchComparator.
 @return Array of SKOneBoxSearchComparator objects.
 */
- (NSArray *)sortingComparators;

/**Details function to be implemented with the provider, if the provider has such a functionality.
 @param seachResult - Search Result to get details for.
 */
- (void)searchDetails:(SKOneBoxSearchObject *)searchobject withCompletionBlock:(void (^)(SKOneBoxSearchResult *searchResult, NSError *error))completionBlock;

@end
