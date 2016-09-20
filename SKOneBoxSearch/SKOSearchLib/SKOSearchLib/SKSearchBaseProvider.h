//
//  SKSearchBaseProvider.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKSearchProviderProtocol.h"
#import "SKSearchBaseProviderDataSource.h"
#import "SKSearchProviderCategory.h"
#import "SKOneBoxSearchComparator.h"

/** Base class for each search provider.
 */
@interface SKSearchBaseProvider : NSObject <SKSearchProviderProtocol>

/** Api key to be used by the service.
 */
@property (nonatomic, strong, readonly) NSString *apiKey;

/** Api secret to be used by the service.
 */
@property (nonatomic, strong, readonly) NSString *apiSecret;

/** Search provider data source.
 */
@property (nonatomic, weak) id<SKSearchBaseProviderDataSource> dataSource;

/**Creates an empty SKSearchBaseProvider
 @param apiKey - api key to be used for the service
 @param apiSecret - api secret to be used for the services which support it. Can be NIL.
 @return - an empty autoreleased object
 */
- (instancetype)initWithAPIKey:(NSString*)apiKey apiSecret:(NSString*)apiSecret NS_DESIGNATED_INITIALIZER;

/**Function to be implemented with the provider to specify the supported search mode.
 @return the search mode supported by the search provider.
 */
- (SKOSearchMode)searchMode;

@end
