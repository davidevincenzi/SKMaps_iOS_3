//
//  SKOneBoxAddPOIViewController.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxAddPOIViewController.h"
#import "UIColor+SKOneBoxColors.h"
#import "SKOneBoxResultsViewController.h"
#import "SKOneBoxSearchPositionerService.h"
#import "SKOneBoxSearchConstants.h"
#import <SKOSearchLib/SKSearchProviderCategory.h>
#import "SKOneBoxSearchDelayer.h"
#import "SKOneBoxDefaultTableViewDatasource.h"
#import "SKOneBoxDefaultTableViewDelegate.h"
#import "SKOneBoxCoreDataManager+SKOneBoxSearchObject.h"
#import "SKOneBoxAbstractMapViewViewController.h"

@interface SKOneBoxAddPOIViewController () <SKOneBoxSearchServiceDelegate>

@property (nonatomic, assign) SKOneBoxAddPOIType poiType;
@property (nonatomic, strong) void (^selectionBlock)(SKOneBoxSearchResult *, NSArray *);

@end

@implementation SKOneBoxAddPOIViewController

#pragma mark - Init

- (instancetype)initWithSearchBar:(SKOneBoxSearchBar *)searchBar searchProviders:(NSArray *)searchProviders poiType:(SKOneBoxAddPOIType)poiType {
    self = [super initWithSearchBar:searchBar searchProviders:searchProviders];
    if (self) {
        _poiType = poiType;
        
        [self.searchBar updateSearchDot:YES];
    }
    return self;
}

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) welf = self;
    
    [[self.searchBar textField] becomeFirstResponder];
    
    //default tableview
    self.defaultDatasource = [[SKOneBoxDefaultTableViewDatasource alloc] init];
    
    self.tableViewDataSource.oneBoxDataSource = self;
    
    self.defaultDelegate = [[SKOneBoxDefaultTableViewDelegate alloc] init];
    self.defaultDelegate.dismissKeyboardBlock = ^{
        [welf.searchBar dismissKeyboard];
    };
    
    //results data source/delegate
    NSArray *searchEnabledProviders = [self searchEnabledProviders];
    self.tableViewDataSource.sections = searchEnabledProviders;
    self.tableViewDelegate.sections = searchEnabledProviders;
    
    [self updateDefaultItems];
    
    self.tableViewDelegate.seeAllBlock = ^(id<SKSearchProviderProtocol> provider) {
        NSLog(@"See all pressed and everything is awesome for provider: %@", provider.localizedProviderName);
        
        SKOneBoxResultsViewController *resultsViewController = [[SKOneBoxResultsViewController alloc] initWithSearchProviders:@[provider] searchService:welf.searchService highlightSearchTerm:welf.searchBar.textField.text];
        resultsViewController.uiConfigurator = welf.uiConfigurator;
        welf.navigationItem.titleView = nil;
        [welf.navigationController pushViewController:resultsViewController animated:YES];
        resultsViewController.delegate = welf.delegate;
        resultsViewController.selectionBlock = welf.selectionBlock;
    };
    
    self.selectionBlock = ^(SKOneBoxSearchResult *result, NSArray *resultList) {
        if ([[result additionalInformation] valueForKey:@"categorySearch"]) {
            SKSearchProviderCategory *category = [[result additionalInformation] valueForKey:@"categorySearch"];
            welf.searchBar.textField.text = [category localizedCategoryName];
            [welf categorySearch:category];
        }
        else if ([[result additionalInformation] valueForKey:@"autocomplete"]) {
            //autocomplete
            welf.searchBar.textField.text = [[result additionalInformation] valueForKey:@"autocomplete"];
            CLLocationCoordinate2D coordinate = [SKOneBoxSearchPositionerService sharedInstance].currentSearchCoordinate;
            [welf search:[[result additionalInformation] valueForKey:@"autocomplete"] location:coordinate];
        }
        else if ([[result additionalInformation] valueForKey:@"locationSuggestion"]) {
            CLLocationCoordinate2D coordinate = result.coordinate;
            [welf search:welf.searchBar.textField.text location:coordinate];
        }
        else if ([result isKindOfClass:[SKOneBoxSearchResult class]]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:result.additionalInformation];
            [dict setObject:[NSNumber numberWithInt:welf.poiType] forKey:@"SKOneBoxAddPOIType"];
            result.additionalInformation = dict;
            
            if (welf.selectResultBlock) {
                welf.selectResultBlock(result,resultList);
            }
            else {
                if ([welf.delegate respondsToSelector:@selector(oneBoxViewController:didSelectSearchResult:fromResultList:)]) {
                    [welf.delegate oneBoxViewController:welf didSelectSearchResult:result fromResultList:resultList];
                }
            }
        }
    };
    
    self.tableViewDelegate.selectionBlock = self.selectionBlock;

    self.tableView.delegate = self.defaultDelegate;
    self.tableView.dataSource = self.defaultDatasource;
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addBackButton];
    
    UIColor *blue = [UIColor hex0080FF];
    [self.navigationController.navigationBar setBarTintColor:blue];
    
    self.navigationItem.titleView = self.searchBar;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [self updateDefaultItems];
}

#pragma mark - Protected

- (void)updateLanguage {
    [self updateDefaultItems];
    [self updateSearchBarPlaceholder];
}

-(void)updateDefaultItems {
    NSArray *defaultItems = [self defaultSectionItems];
    
    self.defaultDatasource.sections = defaultItems;
    self.defaultDelegate.sections = defaultItems;
    
    [self.tableView reloadData];
}

-(void)dismissViewController {
    [super dismissViewController];
    
    //fix retain cyle datasource/delegate
    self.defaultDatasource.sections = nil;
    self.defaultDelegate.sections = nil;
}

- (void)backButtonPressed {
    if (self.uiConfigurator.shouldChangeStatusBarStyle) {
        [[UIApplication sharedApplication] setStatusBarStyle:self.previousOneBoxControllerStatusBarStyle animated:NO];
    }
    
    if (self.shouldRestrictBackAction) {
        [self dismissViewController];
    }
    else {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.15;
        transition.type = kCATransitionFade;
        
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController popViewControllerAnimated:NO];
    }
    
    if ([self.searchService areProvidersSearching:self.searchProviders]) {
        [self.searchService cancelSearch];
    }
    
    //fix retain cyle datasource/delegate
    self.defaultDatasource.sections = nil;
    self.defaultDelegate.sections = nil;
}

#pragma mark - Private

-(void)updateSearchBarPlaceholder {
    switch (self.poiType) {
        case SKOneBoxAddPOITypeFavorite: {
            self.searchBar.placeHolder = [[NSAttributedString alloc] initWithString:SKOneBoxLocalizedString(@"address_or_favorite_name_search_bar_place_holder_key", nil) attributes:@{NSForegroundColorAttributeName:[UIColor hexC3C3C34C]}];
            
        }
            break;
        case SKOneBoxAddPOITypeHome: {
            self.searchBar.placeHolder = [[NSAttributedString alloc] initWithString:SKOneBoxLocalizedString(@"enter_home_address_search_bar_place_holder_key", nil) attributes:@{NSForegroundColorAttributeName:[UIColor hexC3C3C34C]}];
        }
            break;
        case SKOneBoxAddPOITypeOffice: {
            self.searchBar.placeHolder = [[NSAttributedString alloc] initWithString:SKOneBoxLocalizedString(@"enter_office_address_search_bar_place_holder_key", nil) attributes:@{NSForegroundColorAttributeName:[UIColor hexC3C3C34C]}];
        }
            break;
        case SKOneBoxAddPOITypeOther: {
            self.searchBar.placeHolder = [[NSAttributedString alloc] initWithString:SKOneBoxLocalizedString(@"address_or_destination_key", nil) attributes:@{NSForegroundColorAttributeName:[UIColor hexC3C3C34C]}];
        }
            break;
        default:
            break;
    }
}

- (void)categorySearch:(SKSearchProviderCategory*)category {
    [super categorySearch:category];
}

-(void)search:(NSString*)searchText location:(CLLocationCoordinate2D)coordinate {
    [super search:searchText location:coordinate];
}

-(NSString*)addOnMapTitleForType:(SKOneBoxAddPOIType)type {
    switch (type) {
        case SKOneBoxAddPOITypeFavorite: {
            return SKOneBoxLocalizedString(@"favorite_address_on_map_key", nil);
        }
            break;
        case SKOneBoxAddPOITypeHome: {
            return SKOneBoxLocalizedString(@"home_address_on_map_key", nil);
        }
            break;
        case SKOneBoxAddPOITypeOffice: {
            return SKOneBoxLocalizedString(@"office_address_on_map_key", nil);
        }
            break;
        default:
            return SKOneBoxLocalizedString(@"choose_on_map_key", nil);
            break;
    }
}

- (NSArray *)defaultSectionItems {
    NSMutableArray *returnSectionItems = [NSMutableArray array];
    
    //add select on map item
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
    NSMutableArray *items = [NSMutableArray array];
    
    __weak typeof(self) welfSelf = self;
    
    if (self.defaultItems) {
        [items addObjectsFromArray:self.defaultItems];
    }
    else {
        SKOneBoxDefaultTableItem *item = [SKOneBoxDefaultTableItem new];
        item.title = [self addOnMapTitleForType:self.poiType];
        item.subTitle = nil;
        item.itemHeight = kRowHeightOneLineResult;
        item.image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"add_location_icon" ofType:@"png"]];
        
        item.selectionBlock = ^() {
            typeof(self) strongSelf = welfSelf;
            //open map
            if ([strongSelf.abstractMapViewDataSource respondsToSelector:@selector(oneBoxMapView)]) {
                
                //localytics
                [strongSelf emptyChooseOnMap];
                
                UIView<SKOneBoxAbstractMapViewProtocol> *mapView = [strongSelf.abstractMapViewDataSource oneBoxMapView];
                [mapView setMapViewDidSelectResult:^(SKOneBoxSearchResult *result) {
                    if ([welfSelf.abstractMapViewDataSource  respondsToSelector:@selector(navigationControllerForMap)]) {
                        [[welfSelf.abstractMapViewDataSource navigationControllerForMap] popToRootViewControllerAnimated:YES];
                    }
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:result.additionalInformation];
                    [dict setObject:[NSNumber numberWithInt:strongSelf.poiType] forKey:@"SKOneBoxAddPOIType"];
                    result.additionalInformation = dict;
                    welfSelf.selectionBlock(result,@[result]);
                    
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
                SKOneBoxAbstractMapViewViewController *abstractMapCtrl = [[SKOneBoxAbstractMapViewViewController alloc] initWithMapView:mapView];
                abstractMapCtrl.uiConfigurator = self.uiConfigurator;
                
                UINavigationController *navController = self.navigationController;
                if ([strongSelf.abstractMapViewDataSource  respondsToSelector:@selector(navigationControllerForMap)]) {
                    navController = [strongSelf.abstractMapViewDataSource navigationControllerForMap];
                    [navController popToRootViewControllerAnimated:NO];
                }
                [navController pushViewController:abstractMapCtrl animated:YES];
            }
        };
        
        [items addObject:item];

    }
    
    SKOneBoxDefaultSectionItem *section = [[SKOneBoxDefaultSectionItem alloc] initSectionItems:items];
    section.showHeaderSection = NO;
    section.headerSectionHeight = 0.0f;
    section.showFooterSection = YES;
    
    [returnSectionItems addObject:section];
    
    //default datasource for each provider, providers are configured from outside the component
    for (id<SKSearchProviderProtocol> provider in self.defaultSearchProviders) {
        if ([provider shouldAppearInDefaultList]) {
            SKOneBoxDefaultSectionItem *sectionItemProvider = [[SKOneBoxDefaultSectionItem alloc] init];
            if (!provider.shouldShowSectionHeaderDefaultList) {
                sectionItemProvider.headerSectionHeight = 0.0f;
            }
            sectionItemProvider.showHeaderSection = provider.shouldShowSectionHeaderDefaultList;
            
            NSMutableArray *sectionItems = [NSMutableArray array];

            [sectionItems addObject:({
                typeof(self) strongSelf = welfSelf;
                SKOneBoxDefaultTableItem *tableItem = [[SKOneBoxDefaultTableItem alloc] init];
                tableItem.title = [provider localizedProviderName];
                tableItem.image = [provider providerIcon];
                tableItem.selectionBlock = [strongSelf searchBlockWithProvider:provider radius:provider.searchRadius searchTerm:nil searchCategory:nil];
                tableItem;
            })];
            [sectionItemProvider setSectionTableItems:sectionItems];
            [returnSectionItems addObject:sectionItemProvider];
        }
    }
    
    return returnSectionItems;
}

typedef void(^searchSelectionBlock)(void);
-(searchSelectionBlock)searchBlockWithProvider:(id<SKSearchProviderProtocol>)provider radius:(NSNumber*)radius searchTerm:(NSString*)searchTerm searchCategory:(id)searchcategory {
    __weak typeof(self) weakSelf = self;
    return ^(void) {
        typeof(self) strongSelf = weakSelf;
        NSLog(@"Provider selected : %@", provider.localizedProviderName);
        
        //localytics
        [weakSelf emptyAddPOIResultsWithProvider:provider category:searchcategory];
        
        SKOneBoxSearchService *service = [[SKOneBoxSearchService alloc] initWithSearchProviders:@[provider] withMinimumRelevancy:SKOneBoxSearchResultMediumRelevancy shouldUseFilter:YES];
        SKOneBoxResultsViewController *resultsViewController = [[SKOneBoxResultsViewController alloc] initWithSearchProviders:@[provider] searchService:service highlightSearchTerm:nil];
        resultsViewController.uiConfigurator = strongSelf.uiConfigurator;
        strongSelf.navigationItem.titleView = nil;
        [strongSelf.navigationController pushViewController:resultsViewController animated:YES];
        
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
        
        resultsViewController.delegate = strongSelf.delegate;
        resultsViewController.selectionBlock = strongSelf.selectionBlock;
        
        if ([[provider categories] count]) {
            resultsViewController.shouldShowFilteringFunction = NO;
            resultsViewController.shouldShowLocationSelection = NO;
            resultsViewController.abstractMapViewDataSource = strongSelf.abstractMapViewDataSource;
        }
        else {
            resultsViewController.shouldShowFilteringFunction = YES;
        }
        
        SKOneBoxSearchObject *searchObject = [SKOneBoxSearchObject oneBoxSearchObject];
        if ([self.dataSource respondsToSelector:@selector(searchLanguageCode)]) {
            searchObject.searchLanguage = [self.dataSource searchLanguageCode];
        }
        
        searchObject.coordinate = [SKOneBoxSearchPositionerService sharedInstance].currentSearchCoordinate;
        searchObject.radius = radius;
        searchObject.searchTerm = searchTerm;
        searchObject.searchCategory = searchcategory;
        searchObject.itemsPerPage = provider.searchNumberOfItemsPerPage;
        
        for (SKOneBoxSearchComparator *comparator in [provider sortingComparators]) {
            if (comparator.defaultSorting && comparator.sortingParameter) {
                searchObject.searchSort = comparator.sortingParameter;
                break;
            }
        }
        
        [service search:searchObject forProvider:provider];
    };
}

#pragma mark - SKOneBoxSearchServiceDelegate

- (void)searchService:(SKOneBoxSearchService *)searchService didReceiveResults:(NSArray *)results forProvider:(id<SKSearchProviderProtocol>)provider {
    if (![self.searchBar.textField.text length]) {
        return;
    }
    if ([self.tableView.dataSource isKindOfClass:[SKOneBoxDefaultTableViewDatasource class]] && [self.tableView.delegate isKindOfClass:[SKOneBoxDefaultTableViewDelegate class]]) {
        self.tableView.dataSource = self.tableViewDataSource;
        self.tableView.delegate = self.tableViewDelegate;
    }
    
    [self.tableViewDataSource.dataSource setObject:results forKey:[provider providerID]];
    [self.tableViewDelegate.dataSource setObject:results forKey:[provider providerID]];
    
    [self.tableViewDelegate stopAnimatingSectionViewForProvider:provider];
    
    [self.tableView reloadData];
}

#pragma mark - Analytics stubs

- (void)emptyAddPOIResultsWithProvider:(id<SKSearchProviderProtocol>)provider category:(id)category {
    //empty methods, will be used for aspects programming. Cannot capture blocks so we'll call these methods inside our blocks
}

- (void)emptyChooseOnMap {
    //empty methods, will be used for aspects programming. Cannot capture blocks so we'll call these methods inside our blocks
}

@end
