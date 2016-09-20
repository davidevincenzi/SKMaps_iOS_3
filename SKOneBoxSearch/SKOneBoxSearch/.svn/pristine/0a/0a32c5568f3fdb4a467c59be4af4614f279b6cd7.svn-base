//
//  SKOneBoxViewController.h
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 21/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <SKOneBoxSearch/SKOneBoxSearchBaseViewController.h>
#import "SKOneBoxSearchDefines.h"

@class SKSearchProviderCategory;

@interface SKOneBoxViewController : SKOneBoxSearchBaseViewController

-(id<SKSearchProviderProtocol>)searchProviderForId:(NSNumber*)providerId;

-(void)navigateToAddPOIWithType:(SKOneBoxAddPOIType)type shouldRestrictBackAction:(BOOL)shouldRestrictBackAction;

/**Provides functionality to navigate to a certain provider results/category screen.
 @param provider - the provider to which to navigate
 @param searchcategory - can be Nil. Search category is taken from the supported categories of the provider.
 */
-(void)navigateToProvider:(id<SKSearchProviderProtocol>)provider searchCategory:(SKSearchProviderCategory*)searchcategory;

- (void)updateSearchBar;

@end
