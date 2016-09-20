//
//  SKOneBoxAddPOIViewController.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <SKOneBoxSearch/SKOneBoxSearchBaseViewController.h>
#import <SKOneBoxSearch/SKOneBoxSearch.h>
#import "SKOneBoxSearchDefines.h"

@interface SKOneBoxAddPOIViewController : SKOneBoxSearchBaseViewController

@property (nonatomic, readonly) SKOneBoxAddPOIType poiType;
@property (nonatomic, assign) BOOL shouldRestrictBackAction; //certain flows in the client require direct navigation to this screen.
@property (nonatomic, strong) NSArray *defaultSearchProviders;
@property (nonatomic, strong) NSArray *defaultItems;

//to be used instead of oneboxsearchdelegate
@property (nonatomic, strong) void (^selectResultBlock)(SKOneBoxSearchResult *, NSArray *);

- (instancetype)initWithSearchBar:(SKOneBoxSearchBar *)searchBar searchProviders:(NSArray *)searchProviders poiType:(SKOneBoxAddPOIType)poiType;

@end
