//
//  SKOneBoxSearchBaseViewController.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <SKOneBoxSearch/SKOneBoxBaseViewController.h>

#import <SKOSearchLib/SKOneBoxSearchService.h>

@class SKOneBoxDefaultTableViewDatasource;
@class SKOneBoxDefaultTableViewDelegate;
@class SKOneBoxSearchDelayer;
@class SKOneBoxCoreDataManager;
@class SKSearchProviderCategory;

@interface SKOneBoxSearchBaseViewController : SKOneBoxBaseViewController <SKOneBoxSearchServiceDelegate>

@property (nonatomic, strong) SKOneBoxSearchDelayer *searchDelayer;
@property (nonatomic, strong) SKOneBoxSearchService *searchService;
@property (nonatomic, strong) SKOneBoxCoreDataManager *coreDataManager;

@property (nonatomic, strong) SKOneBoxDefaultTableViewDatasource *defaultDatasource;
@property (nonatomic, strong) SKOneBoxDefaultTableViewDelegate *defaultDelegate;

- (void)search:(NSString *)searchText location:(CLLocationCoordinate2D)coordinate;
- (void)categorySearch:(SKSearchProviderCategory*)category;
- (void)clearSearch;
- (NSArray *)searchEnabledProviders;

@end
