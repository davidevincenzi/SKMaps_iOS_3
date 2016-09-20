//
//  SKSearchProviderDelegate.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKSearchBaseProvider;
@class SKOneBoxSearchResultMetaData;
@class SKOneBoxSearchResult;

@protocol SKSearchProviderProtocol;

@protocol SKSearchProviderDelegate <NSObject>

@optional

/**Callback called in case search provider search failed.
 @param searchProvider The search provider object.
 @param results Mapped results received from the provider Search API.
 @param metaData Mapped meta data received from the provider Search API.
 */
- (void)searchProvider:(id<SKSearchProviderProtocol>)searchProvider didReceiveResults:(NSArray *)results metaData:(id)metaData;

/**Callback called in case search provider search failed.
 @param searchProvider The search provider object.
 */
- (void)searchProviderDidFailToRetrieveResults:(id<SKSearchProviderProtocol>)searchProvider;

@end
