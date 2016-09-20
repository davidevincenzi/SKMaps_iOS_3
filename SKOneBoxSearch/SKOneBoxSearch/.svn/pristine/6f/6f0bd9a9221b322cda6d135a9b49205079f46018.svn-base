//
//  SKOneBoxViewController.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 21/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxViewController.h"

#import "SKOneBoxResultsViewController.h"
#import "SKOneBoxEditableResultsViewController.h"
#import "SKOneBoxTableHeaderView.h"

#import "SKOneBoxResultsTableViewDatasource.h"

#import "SKOneBoxHeaderButton.h"

#import "UIColor+SKOneBoxColors.h"

#import "SKOneBoxCategoriesViewController.h"

#import <SKOSearchLib/SKOSearchLib.h>

#import "SKOneBoxAddPOIViewController.h"
#import "SKOneBoxSearchConstants.h"

#import <SKOSearchLib/SKOneBoxSearchResult+TableViewCellHelper.h>

#import "SKOneBoxSearchDelayer.h"
#import "SKOneBoxDefaultTableViewDatasource.h"
#import "SKOneBoxDefaultTableViewDelegate.h"
#import "SKOneBoxCoreDataManager+SKOneBoxSearchObject.h"
#import "SKOneBoxTestCase.h"

#define kSKOneBoxViewControllerNumberOfVisibleResults 2

@interface SKOneBoxViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) SKOneBoxTableHeaderView *headerView;
@property (nonatomic, strong) SKOneBoxHeaderButton *workButton;
@property (nonatomic, strong) SKOneBoxHeaderButton *homeButton;

@property (nonatomic, strong) UIButton *reportButton;

@end

@implementation SKOneBoxViewController

#pragma mark - Init

- (instancetype)initWithSearchBar:(SKOneBoxSearchBar *)searchBar {
    return [self initWithSearchBar:searchBar searchProviders:nil];
}

- (instancetype)initWithSearchBar:(SKOneBoxSearchBar *)searchBar searchProviders:(NSArray *)searchProviders {
    self = [super initWithSearchBar:searchBar searchProviders:searchProviders];
    if (self) {

    }
    return self;
}

#pragma mark - View methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateSearchBar];
    
    self.defaultDatasource.sections = [self defaultSectionItems];
    self.defaultDelegate.sections = [self defaultSectionItems];
    
    [self.tableView reloadData];
    
    UIColor *blue = [UIColor hex0080FF];
    [self.navigationController.navigationBar setBarTintColor:blue];
    
    if (self.uiConfigurator.shouldChangeStatusBarStyle) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
    if ([self.delegate respondsToSelector:@selector(willShowOneBoxViewController:)]) {
        [self.delegate willShowOneBoxViewController:self];
    }

    if ([[SKOneBoxDebugManager sharedInstance] markBadResults]) {
        //debug button for reporting
        [self.reportButton removeFromSuperview];
        
        self.reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.reportButton.frame = CGRectMake(0, 0, 100, 50);
        
        [self.reportButton setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:0.2f]];
        [self.reportButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.reportButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:16.0];
        self.reportButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.reportButton setTitle:@"Report results" forState:UIControlStateNormal];
        [self.reportButton addTarget:self action:@selector(writeResultsToDisk) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.reportButton];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeCenterMap) name:kOneBoxDidChangeCenterMapLocationNotification object:nil];
    __weak typeof(self) welf = self;
    
    //default tableview
    self.defaultDatasource = [[SKOneBoxDefaultTableViewDatasource alloc] init];
    
    self.tableViewDataSource.oneBoxDataSource = self;
    
    self.defaultDelegate = [[SKOneBoxDefaultTableViewDelegate alloc] init];
    self.defaultDelegate.dismissKeyboardBlock = ^{
        [welf.searchBar dismissKeyboard];
    };
    self.tableView.accessibilityIdentifier = @"SKOneBoxTableView";
    
    //results data source/delegate
    NSArray *searchEnabledProviders = [self searchEnabledProviders];
    self.tableViewDataSource.sections = searchEnabledProviders;
    self.tableViewDelegate.sections = searchEnabledProviders;
    
    self.tableViewDelegate.seeAllBlock = ^(id<SKSearchProviderProtocol> provider) {
        NSLog(@"See all pressed and everything is awesome for provider: %@", provider.localizedProviderName);
        
        //localytics tracking
        [welf emptySeeAllBlockForProvider:provider];
        
        SKOneBoxResultsViewController *resultsViewController = [[SKOneBoxResultsViewController alloc] initWithSearchProviders:@[provider] searchService:welf.searchService highlightSearchTerm:welf.searchBar.textField.text];
        resultsViewController.uiConfigurator = welf.uiConfigurator;
        welf.navigationItem.titleView = nil;
        [welf.navigationController pushViewController:resultsViewController animated:YES];
        resultsViewController.delegate = welf.delegate;
        resultsViewController.dataSource = welf.dataSource;
        
    };
    self.tableViewDelegate.selectionBlock = ^(SKOneBoxSearchResult* result, NSArray *resultList) {
        //localytics tracking
        [welf emptyResultSelectionBlock:result];
        
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
            [welf.coreDataManager saveSearchResultObject:result];
            if ([welf.delegate respondsToSelector:@selector(oneBoxViewController:didSelectSearchResult:fromResultList:)]) {
                [welf.delegate oneBoxViewController:welf didSelectSearchResult:result fromResultList:resultList];
            }
        }
    };

//    [self createHeaderView];
    
    self.tableView.tableHeaderView.accessibilityIdentifier = @"SKOneBoxSearchTableHeader";
    
    self.tableView.delegate = self.defaultDelegate;
    self.tableView.dataSource = self.defaultDatasource;
    
    [self.tableView reloadData];
}

#pragma mark - Orientation changes

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self updateSearchBarFrame];
}

#pragma mark - Private

- (void)createHeaderView {
    //  Header view is shown at top of all search categories; currently configured for home, work and 2 others (recents and favorites).
    __weak typeof(self) welf = self;
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
    
    UIImage *homeActiveImg = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"onebox_shortcut_home_act" ofType:@"png"]];
    UIImage *homeInactiveImg = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"onebox_shortcut_home_inact" ofType:@"png"]];
    
    UIImage *workActiveImg = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"onebox_shortcut_work_act" ofType:@"png"]];
    UIImage *workInactiveImg = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"onebox_shortcut_work_inact" ofType:@"png"]];
    
    UIImage *recentsActiveImg = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"onebox_shortcut_recents_act" ofType:@"png"]];
    UIImage *recentsInactiveImg = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"onebox_shortcut_recents_inact" ofType:@"png"]];
    
    UIImage *favoritesActiveImg = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"onebox_shortcut_favorite_act" ofType:@"png"]];
    UIImage *favoritesInactiveImg = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"onebox_shortcut_favorite_inact" ofType:@"png"]];
    
    //Hardcoded
    id<SKSearchProviderProtocol> favoritesProvider = [self.searchService providerForProviderId:@(7)];
    id<SKSearchProviderProtocol> recentsProvider = [self.searchService providerForProviderId:@(8)];
    
    self.homeButton = [[SKOneBoxHeaderButton alloc] initWithTitle:SKOneBoxLocalizedString(@"home_button_title_key", nil) activeImage:homeActiveImg selectedImage:homeActiveImg inactiveImage:homeInactiveImg andSelectionBlock:^{
        typeof(self) strongSelf = welf;
        
        SKOneBoxSearchResult *homeResult = nil;
        if ([strongSelf.dataSource respondsToSelector:@selector(homeSearchResult)]) {
            homeResult = [strongSelf.dataSource homeSearchResult];
        }
        
        if (homeResult) {
            if ([welf.delegate respondsToSelector:@selector(oneBoxViewController:didSelectSearchResult:fromResultList:)]) {
                [welf.delegate oneBoxViewController:strongSelf didSelectSearchResult:homeResult fromResultList:@[homeResult]];
            }
        }
        else {
            [strongSelf.searchBar dismissKeyboard];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SKOneBoxLocalizedString(@"no_home_address_set_title_key", nil)
                                                                message:SKOneBoxLocalizedString(@"no_home_address_set_message_key", nil)
                                                               delegate:self
                                                      cancelButtonTitle:SKOneBoxLocalizedString(@"no_button_title_key", nil)
                                                      otherButtonTitles:SKOneBoxLocalizedString(@"yes_button_title_key", nil), nil];
            alertView.tag = SKOneBoxAddPOITypeHome;
            [alertView show];
        }
    }];
    
    self.workButton = [[SKOneBoxHeaderButton alloc] initWithTitle:SKOneBoxLocalizedString(@"work_button_title_key", nil) activeImage:workActiveImg selectedImage:workActiveImg inactiveImage:workInactiveImg andSelectionBlock:^{
        typeof(self) strongSelf = welf;
        
        SKOneBoxSearchResult *workResult = nil;
        if ([strongSelf.dataSource respondsToSelector:@selector(officeSearchResult)]) {
            workResult = [strongSelf.dataSource officeSearchResult];
        }
        
        if (workResult) {
            if ([welf.delegate respondsToSelector:@selector(oneBoxViewController:didSelectSearchResult:fromResultList:)]) {
                [welf.delegate oneBoxViewController:strongSelf didSelectSearchResult:workResult fromResultList:@[workResult]];
            }
        }
        else {
            [strongSelf.searchBar dismissKeyboard];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SKOneBoxLocalizedString(@"no_office_address_set_title_key", nil)
                                                                message:SKOneBoxLocalizedString(@"no_office_address_set_message_key", nil)
                                                               delegate:self
                                                      cancelButtonTitle:SKOneBoxLocalizedString(@"no_button_title_key", nil)
                                                      otherButtonTitles:SKOneBoxLocalizedString(@"yes_button_title_key", nil), nil];
            alertView.tag = SKOneBoxAddPOITypeOffice;
            [alertView show];
        }
    }];
    
    self.homeButton.accessibilityIdentifier = @"SKOneBoxSearchHome";
    self.workButton.accessibilityIdentifier = @"SKOneBoxSearchWork";
    
    SKOneBoxHeaderButton *recentsButton = [[SKOneBoxHeaderButton alloc] initWithTitle:[recentsProvider localizedProviderName] activeImage:recentsActiveImg selectedImage:recentsActiveImg inactiveImage:recentsInactiveImg andSelectionBlock:[self customBlockWithProvider:recentsProvider]];
    
    SKOneBoxHeaderButton *favoritesButton = [[SKOneBoxHeaderButton alloc] initWithTitle:[favoritesProvider localizedProviderName] activeImage:favoritesActiveImg selectedImage:favoritesActiveImg inactiveImage:favoritesInactiveImg andSelectionBlock:[self customBlockWithProvider:favoritesProvider]];
    
    self.headerView = [[SKOneBoxTableHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, kTableHeaderViewHeight) andButtonsArray:@[self.homeButton,self.workButton,recentsButton,favoritesButton]];
    
    if (![self.searchBar.textField.text length]) {
        self.tableView.tableHeaderView = self.headerView;
    }
}

- (void)updateLanguage {
    [self createHeaderView];
    [self.tableView reloadData];
}

- (void)updateSearchBar {
    self.searchBar.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.searchBar.frame.size.height);
    UIView *someview = [[UIView alloc] initWithFrame:CGRectMake(self.searchBar.superview.frame.origin.x, self.searchBar.superview.frame.origin.y,
                                                                self.searchBar.frame.size.width, self.searchBar.frame.size.height)];
    someview.backgroundColor = [UIColor clearColor];
    // if the two lines bellow are switched (as it would seem correct), when setting the titleview, the search bar is resigned
    self.navigationItem.titleView = someview;
    [someview addSubview:self.searchBar];
}

- (void)updateSearchBarFrame {
    CGRect titleFrame = self.navigationItem.titleView.frame;
    titleFrame.size.width = self.view.frame.size.width;
    
    self.navigationItem.titleView.frame = titleFrame;
    [self.navigationController.navigationBar layoutIfNeeded];
}

- (void)categorySearch:(SKSearchProviderCategory*)category {
    [super categorySearch:category];
}

-(void)search:(NSString*)searchText location:(CLLocationCoordinate2D)coordinate {

    
    [super search:searchText location:coordinate];
}

- (NSArray *)defaultSectionItems {
    NSMutableArray *returnSectionItems = [NSMutableArray array];
    
    __weak typeof(self) welf = self;

    //latest recents favorites
    if ([self.dataSource respondsToSelector:@selector(latestRecentsFavorites)]) {
        NSArray *providedDefaultDataSource = [self.dataSource latestRecentsFavorites];
        NSMutableArray *items = [NSMutableArray array];
        
        for (SKOneBoxSearchResult *searchResult in providedDefaultDataSource) {
            NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];

            SKOneBoxDefaultTableItem *item = [SKOneBoxDefaultTableItem new];
            item.title = [searchResult title];
            item.subTitle = [searchResult subtitle];
            item.itemHeight = kRowHeightMultipleLineResult;
            
            if ([searchResult.additionalInformation[@"type"] isEqual:@"recent"]) {
                item.image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"onebox_recent_list_icon" ofType:@"png"]];
            } else if ([searchResult.additionalInformation[@"type"] isEqual:@"favorite"]) {
                item.image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"onebox_favorite_list_icon" ofType:@"png"]];
            }
            
            //calculate air distance
            CLLocationCoordinate2D coordinate = [SKOneBoxSearchPositionerService sharedInstance].currentCoordinate;
            if ((searchResult.coordinate.latitude == 0.0f && searchResult.coordinate.longitude == 0.0f) || (coordinate.latitude == 0.0f && coordinate.longitude == 0.0f)) {
                item.rightAccesoryText = nil;
            } else {
                double result = [SKOSearchLibUtils getAirDistancePointA:searchResult.coordinate pointB:coordinate];
                NSString *formattedDistance = nil;
                if ([self.delegate respondsToSelector:@selector(oneBoxViewController:formatDistance:)]) {
                    formattedDistance = [self.delegate oneBoxViewController:self formatDistance:result];
                }
                
                if (!formattedDistance) {
                    formattedDistance = [NSString stringWithFormat:@"%.0fm",result];
                }
                
                item.rightAccesoryText = formattedDistance;
            }
            
            item.selectionBlock = ^() {
                if ([welf.delegate respondsToSelector:@selector(oneBoxViewController:didSelectSearchResult:fromResultList:)]) {
                    [welf.delegate oneBoxViewController:welf didSelectSearchResult:searchResult fromResultList:providedDefaultDataSource];
                }
            };

            [items addObject:item];
        }

        if ([items count]) {
            SKOneBoxDefaultSectionItem *section = [[SKOneBoxDefaultSectionItem alloc] initSectionItems:items];
            section.showHeaderSection = NO;
            section.headerSectionHeight = 0.0f;
            section.showFooterSection = YES;
            
            [returnSectionItems addObject:section];
        }        
    }
    
    //default datasource for each provider, providers are configured from outside the component
    for (id<SKSearchProviderProtocol> provider in self.searchProviders) {
        if (![provider isSearchProviderEnabled]) {
            continue;
        }
        if ([provider shouldAppearInDefaultList]) {
            SKOneBoxDefaultSectionItem *sectionItemProvider = [[SKOneBoxDefaultSectionItem alloc] init];
            if (!provider.shouldShowSectionHeaderDefaultList) {
                sectionItemProvider.headerSectionHeight = 0.0f;
            }
            sectionItemProvider.showHeaderSection = provider.shouldShowSectionHeaderDefaultList;
            
            __weak typeof(self) welfSelf = self;
            
            NSMutableArray *sectionItems = [NSMutableArray array];
            if ([provider shouldShowCategories]) { //skmaps
                NSArray *categories = [provider categories];
                for (SKSearchProviderCategory *category in categories) {
                    if (!category.isMainCategory) {
                        continue;
                    }
                    if ([sectionItems count] < provider.numberOfCategoriesToShowDefaultList) {
                        [sectionItems addObject:({
                            typeof(self) strongSelf = welfSelf;
                            SKOneBoxDefaultTableItem *tableItem = [[SKOneBoxDefaultTableItem alloc] init];
                            tableItem.title = category.localizedCategoryName;
                            tableItem.image = [category categoryImage];
                            tableItem.selectionBlock = [strongSelf searchBlockWithProvider:provider radius:provider.searchRadius searchTerm:nil searchCategory:category];
                            tableItem;
                        })];
                    }
                    else {
                        //add see all item
                        [sectionItems addObject:({
                            typeof(self) strongSelf = welfSelf;
                            SKOneBoxDefaultTableItem *tableItem = [[SKOneBoxDefaultTableItem alloc] init];
                            tableItem.title = SKOneBoxLocalizedString(@"see_all_categories_key", nil);
                            tableItem.titleColor = [UIColor hex0080FF];
                            tableItem.showTopSeparator = YES;
                            tableItem.selectionBlock = [strongSelf categoryBlockWithProvider:provider];
                            
                            tableItem;
                        })];
                        break;
                    }
                }
            }
            else {
                [sectionItems addObject:({
                    typeof(self) strongSelf = welfSelf;
                    SKOneBoxDefaultTableItem *tableItem = [[SKOneBoxDefaultTableItem alloc] init];
                    tableItem.title = [provider localizedProviderName];
                    tableItem.image = [provider providerIcon];
                    if ([[provider categories] count]) {
                        //we have categories, show them
                        tableItem.selectionBlock = [strongSelf categoryBlockWithProvider:provider];
                    }
                    else {
                        tableItem.selectionBlock = [strongSelf customBlockWithProvider:provider];
                    }

                    tableItem;
                })];
            }
            [sectionItemProvider setSectionTableItems:sectionItems];
            [returnSectionItems addObject:sectionItemProvider];
        }
    }
    
    if ([returnSectionItems count]) {
        SKOneBoxDefaultSectionItem *firstSection = [returnSectionItems objectAtIndex:0];
        firstSection.showHeaderSection = NO;
        firstSection.headerSectionHeight = 0.0f;
    }
    
    return returnSectionItems;
}

typedef void(^searchSelectionBlock)(void);
- (searchSelectionBlock)searchBlockWithProvider:(id<SKSearchProviderProtocol>)provider radius:(NSNumber*)radius searchTerm:(NSString*)searchTerm searchCategory:(SKSearchProviderCategory*)searchCategory {
    __weak typeof(self) weakSelf = self;
    return ^(void) {
        typeof(self) strongSelf = weakSelf;
        
        //analytics tracking
        [strongSelf emptyResultsWithProvider:provider category:searchCategory];
        
        NSLog(@"Provider selected : %@", provider.localizedProviderName);
        
        NSString *highlightTerm = [strongSelf.searchBar.textField.text length] ? strongSelf.searchBar.textField.text : nil;
        SKOneBoxSearchService *service = [[SKOneBoxSearchService alloc] initWithSearchProviders:@[provider] withMinimumRelevancy:SKOneBoxSearchResultMediumRelevancy shouldUseFilter:YES];
        SKOneBoxResultsViewController *resultsViewController = [[SKOneBoxResultsViewController alloc] initWithSearchProviders:@[provider] searchService:service highlightSearchTerm:highlightTerm];
        resultsViewController.searchCategory = searchCategory;
        resultsViewController.uiConfigurator = strongSelf.uiConfigurator;
        strongSelf.navigationItem.titleView = nil;
        [strongSelf.navigationController pushViewController:resultsViewController animated:YES];
        
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
        
        resultsViewController.delegate = strongSelf.delegate;
        resultsViewController.dataSource = strongSelf.dataSource;

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
        searchObject.searchCategory = searchCategory.categorySearchType;
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

- (searchSelectionBlock)customBlockWithProvider:(id<SKSearchProviderProtocol>)provider {
    __weak typeof(self) weakSelf = self;

    if ([weakSelf.delegate respondsToSelector:@selector(editableDatasorceForSearchProvider:)]) {
        id<SKOneBoxEditableResultsDatasourceProtocol> datasource = [self.delegate editableDatasorceForSearchProvider:provider];
        if (datasource) {
            
            __weak typeof(datasource) weakDatasource = datasource;
            return ^(void) {
                typeof(self) strongSelf = weakSelf;
                NSLog(@"Provider selected : %@", provider.localizedProviderName);
                
                //localytics tracking
                [strongSelf emptyEditableResultsWithProvider:provider];
                
                SKOneBoxEditableResultsViewController *resultsViewController = [[SKOneBoxEditableResultsViewController alloc] initWithDataSource:datasource];
                resultsViewController.shouldChangeStatusBarStyle = self.uiConfigurator.shouldChangeStatusBarStyle;
                
                NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
                UIImage *backImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_back" ofType:@"png"]];
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
                [button setImage:backImage forState:UIControlStateNormal];
                
                [button addTarget:self action:@selector(didTouchBackButton) forControlEvents:UIControlEventTouchUpInside];
                button.accessibilityIdentifier = @"SKOneBoxResultsBackButton";
                
                resultsViewController.leftNavigationBarView = button;
                
                strongSelf.navigationItem.titleView = nil;
                [strongSelf.navigationController pushViewController:resultsViewController animated:YES];
                
                //TODO get rid of int values for providers
                if ([[provider providerID] intValue] == 7) {
                    __weak typeof(resultsViewController) weakResultsController = resultsViewController;
                    datasource.didSelectAddNewElement = ^(id element) {
                        SKOneBoxAddPOIViewController *controller = [weakSelf configuredAddPOIViewControllerWithAddPOIWithType:SKOneBoxAddPOITypeFavorite shouldRestrictBackAction:NO];
                        
                        [controller setSelectResultBlock:^(SKOneBoxSearchResult *result, NSArray *results) {
                            if ([weakDatasource respondsToSelector:@selector(addSearchResult:)]) {
                                [weakDatasource addSearchResult:result];
                            }
                            [weakSelf.navigationController popToViewController:weakResultsController animated:YES];
                        }];
                        
                        CATransition *transition = [CATransition animation];
                        transition.duration = 0.15;
                        transition.type = kCATransitionFade;
                        
                        [weakSelf.navigationController.view.layer addAnimation:transition forKey:kCATransition];
                        [weakSelf.navigationController pushViewController:controller animated:NO];
                    };
                }
            };
        }
    }
    
    return [self searchBlockWithProvider:provider radius:provider.searchRadius searchTerm:nil searchCategory:nil];
}

- (void)didTouchBackButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (searchSelectionBlock)categoryBlockWithProvider:(id<SKSearchProviderProtocol>)provider {
    __weak typeof(self) weakSelf = self;
    return ^(void) {
        typeof(self) strongSelf = weakSelf;
        NSLog(@"Provider selected : %@", provider.localizedProviderName);
        
        //lolcaytics tracking
        [strongSelf emptyCategoriesWithProvider:provider];
        
        SKOneBoxCategoriesViewController *categoriesViewController = [[SKOneBoxCategoriesViewController alloc] initWithSearchProvider:provider];
        categoriesViewController.delegate = strongSelf.delegate;
        categoriesViewController.dataSource = strongSelf.dataSource;
        categoriesViewController.abstractMapViewDataSource = strongSelf.abstractMapViewDataSource;
        categoriesViewController.uiConfigurator = strongSelf.uiConfigurator;
        self.navigationItem.titleView = nil;
        [self.navigationController pushViewController:categoriesViewController animated:YES];
        
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    };
}

-(void)clearSearch {
    [super clearSearch];
    self.tableView.tableHeaderView = self.headerView;
}

- (SKOneBoxSearchComparator *)currentSortingComparatorForProvider:(id<SKSearchProviderProtocol>)provider {
    NSArray *comparators = [provider sortingComparators];
    
    for (SKOneBoxSearchComparator *comparator in [provider sortingComparators]) {
        if (comparator.defaultSorting) {
            return comparator;
        }
    }
    if ([comparators count]) {
        return comparators[0];
    }
    return nil;
}

-(void)didChangeCenterMap {
    //results data source/delegate
    NSArray *searchEnabledProviders = [self searchEnabledProviders];
    self.tableViewDataSource.sections = searchEnabledProviders;
    self.tableViewDelegate.sections = searchEnabledProviders;
    
    self.defaultDatasource.sections = [self defaultSectionItems];
    self.defaultDelegate.sections = [self defaultSectionItems];
    
    [self.tableView reloadData];
}

//DEBUG
-(void)writeResultsToDisk {
    SKOneBoxSearchObject *search = [self.searchService currentSearchObjectForProvider:[self.searchEnabledProviders objectAtIndex:0]];
    
    if (!search.searchTerm) {
        return;
    }
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dD_MM_yyyy_HH:mm:ss"];
    NSDate *now = [NSDate date];
    NSString *nsstr = [format stringFromDate:now];
    
    NSString *searchTerm = search.searchTerm;
    NSString *fileName = [NSString stringWithFormat:@"searchCase_%@_%@.json",nsstr,searchTerm];
    NSString *imageFileName = [NSString stringWithFormat:@"searchCase_%@_%@.png",nsstr,searchTerm];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableJsonPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSString *writableImagePath = [documentsDirectory stringByAppendingPathComponent:imageFileName];
    
    
    // Create a dictionary that contains the provider name
    NSMutableDictionary *providerNames = [NSMutableDictionary new];
    
    for (NSNumber *providerId in [self.tableViewDataSource.dataSource allKeys]) {
        id<SKSearchProviderProtocol> provider = [self.searchService providerForProviderId:providerId];
        [providerNames setObject:[provider localizedProviderName] forKey:providerId];
    }

    // Create an test case convert it and write it to disk
    SKOneBoxTestCase *testObject = [[SKOneBoxTestCase alloc] initWithSearchResults:self.tableViewDataSource.dataSource searchObject:search andProvidersNames:providerNames];
    NSDictionary *json = [testObject toJSONDictionary];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&err];
    NSString *myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [myString writeToFile:writableJsonPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self saveBadResultsImageAtPath:writableImagePath];
    NSLog(@"wrote to file %@", writableJsonPath);
}

- (void)saveBadResultsImageAtPath:(NSString*)path {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
}

- (NSArray *)sortOneBoxSearchResultsArrayByRank:(NSArray *)array {
    NSArray *initialValues = [NSArray arrayWithArray:array];
    initialValues = [initialValues sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        SKOneBoxSearchResult *first = (SKOneBoxSearchResult *)obj1;
        SKOneBoxSearchResult *second = (SKOneBoxSearchResult *)obj2;
        
        NSNumber *firstRank = first.additionalInformation[@"ranking"];
        NSNumber *secondRank = second.additionalInformation[@"ranking"];
        
        return [secondRank compare:firstRank];
    }];
    
    return initialValues;
}

#pragma mark - Protected

-(void)dismissViewController {
    [super dismissViewController];
}

#pragma mark - Public 

- (id<SKSearchProviderProtocol>)searchProviderForId:(NSNumber*)providerId {
    return [self.searchService providerForProviderId:providerId];
}

-(void)navigateToProvider:(id<SKSearchProviderProtocol>)provider searchCategory:(SKSearchProviderCategory*)searchcategory {
    searchSelectionBlock block = nil;
    if (searchcategory) {
        block = [self searchBlockWithProvider:provider radius:provider.searchRadius searchTerm:nil searchCategory:searchcategory];
    }
    else {
        block = [self customBlockWithProvider:provider];
    }
    block();
}

#pragma mark - SKOneBoxSearchServiceDelegate

- (void)searchService:(SKOneBoxSearchService *)searchService didReceiveResults:(NSArray *)results forProvider:(id<SKSearchProviderProtocol>)provider {
    if (![self.searchBar.textField.text length]) {
        return;
    }
    
    //for searches which use local comparators instead of api comparators do local sort
    SKOneBoxSearchComparator *comparator = [self currentSortingComparatorForProvider:provider];
    if (comparator && comparator.comparator) {
        results = [results sortedArrayUsingComparator:comparator.comparator];
    }
    
//    int resultsToAdd = 2 - MIN([results count], 2) ;
//    if (resultsToAdd > 0) {
//        NSMutableArray *newRes = [NSMutableArray arrayWithArray:results];
//        
//        for (int i = 0; i < resultsToAdd; i++) {
//            [newRes addObject:[SKOneBoxSearchResult new]];
//        }
//        results = newRes;
//    }
    
    [self.tableViewDataSource.dataSource setObject:results forKey:[provider providerID]];
    [self.tableViewDelegate.dataSource setObject:results forKey:[provider providerID]];
    
    if ([self.tableView.dataSource isKindOfClass:[SKOneBoxDefaultTableViewDatasource class]] && [self.tableView.delegate isKindOfClass:[SKOneBoxDefaultTableViewDelegate class]]) {
        self.tableView.tableHeaderView = nil;
        [self.tableView setNeedsLayout];
        [self.tableView layoutIfNeeded];
        
        self.tableView.dataSource = self.tableViewDataSource;
        self.tableView.delegate = self.tableViewDelegate;
    }    
    
    [self.tableViewDelegate stopAnimatingSectionViewForProvider:provider];
    
    [self.tableView reloadData];
}

- (void)searchService:(SKOneBoxSearchService *)searchService didMarkTopHitResults:(NSDictionary *)results {
    // we should reload the results which are markd as top hit
    for (int index = 0; index < self.searchProviders.count; index++) {
        id<SKSearchProviderProtocol> value = self.searchProviders[index];
        NSNumber *key = [value providerID];
        NSArray *values = [results objectForKey:key];
        
        // Sort the valyes by the rank
        values = [self sortOneBoxSearchResultsArrayByRank:values];
        
        NSArray *initialValues = [self sortOneBoxSearchResultsArrayByRank:[self.tableViewDataSource.dataSource objectForKey:key]];
        
        // Unmark the previously marked displayed results if needed
        for (int i = 0; i < initialValues.count && i < kSKOneBoxViewControllerNumberOfVisibleResults; i++) {
            SKOneBoxSearchResult *result = initialValues[i];
            
            SKOneBoxSearchResult *newResult = nil;
            if (values.count > 0 && i < values.count) {
                newResult = values[i];
            }
            
            if (result.topResult && newResult &&!newResult.topResult) {
                result.topResult = NO;
                if ([self.tableView numberOfRowsInSection:index] > 0 && [self.tableView numberOfRowsInSection:index] <= i) {
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:i inSection:index]] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }
        
        // Iterate the first *two values and reload the tableview if they are marked
        for (int i = 0; i < values.count && i < kSKOneBoxViewControllerNumberOfVisibleResults; i++) {
            SKOneBoxSearchResult *result = values[i];
            
            if (result.topResult) {
                if ([self.tableView numberOfRowsInSection:index] > 0 && [self.tableView numberOfRowsInSection:index] <= i) {
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:i inSection:index]] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }
        
    }
}

#pragma mark - UIAlertViewDelegate

-(SKOneBoxAddPOIViewController *)configuredAddPOIViewControllerWithAddPOIWithType:(SKOneBoxAddPOIType)type shouldRestrictBackAction:(BOOL)shouldRestrictBackAction {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
    
    id<SKSearchProviderProtocol> favoritesProvider = [self.searchService providerForProviderId:@(7)];
    id<SKSearchProviderProtocol> recentsProvider = [self.searchService providerForProviderId:@(8)];
    id<SKSearchProviderProtocol> contactsProvider = [self.searchService providerForProviderId:@(9)];
    
    UIImage *closeImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_clear_white" ofType:@"png"]];
    closeImage.accessibilityIdentifier = @"SKOneBoxCloseImage";
    UIImage *clearImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_clear_grey" ofType:@"png"]];
    clearImage.accessibilityIdentifier = @"SKOneBoxClearImage";
    UIImage *closeImageAlpha = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_clear_white_alpha" ofType:@"png"]];
    
    SKOneBoxSearchBar *searchBar = [[SKOneBoxSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 32.0) normalClearImage:closeImageAlpha highlightedClearImage:closeImage inactiveSearchClearImage:clearImage searchImage:nil];
    [searchBar setShouldShowSearchDot:NO];
    
    SKOneBoxAddPOIViewController *addPOICtrl = [[SKOneBoxAddPOIViewController alloc] initWithSearchBar:searchBar searchProviders:self.searchProviders poiType:type];
    addPOICtrl.abstractMapViewDataSource = self.abstractMapViewDataSource;
    
    addPOICtrl.shouldRestrictBackAction = shouldRestrictBackAction;
    
    addPOICtrl.uiConfigurator = self.uiConfigurator;
    
    addPOICtrl.delegate = self.delegate;
    
    switch (type) {
        case SKOneBoxAddPOITypeFavorite: {
            searchBar.placeHolder = [[NSAttributedString alloc] initWithString:SKOneBoxLocalizedString(@"address_or_favorite_name_search_bar_place_holder_key", nil) attributes:@{NSForegroundColorAttributeName:[UIColor hexC3C3C34C]}];
            addPOICtrl.defaultSearchProviders = @[recentsProvider,contactsProvider];
            
        }
            break;
        case SKOneBoxAddPOITypeHome: {
            searchBar.placeHolder = [[NSAttributedString alloc] initWithString:SKOneBoxLocalizedString(@"enter_home_address_search_bar_place_holder_key", nil) attributes:@{NSForegroundColorAttributeName:[UIColor hexC3C3C34C]}];
            addPOICtrl.defaultSearchProviders = @[recentsProvider,favoritesProvider,contactsProvider];
        }
            break;
        case SKOneBoxAddPOITypeOffice: {
            searchBar.placeHolder = [[NSAttributedString alloc] initWithString:SKOneBoxLocalizedString(@"enter_office_address_search_bar_place_holder_key", nil) attributes:@{NSForegroundColorAttributeName:[UIColor hexC3C3C34C]}];
            addPOICtrl.defaultSearchProviders = @[recentsProvider,favoritesProvider,contactsProvider];
        }
            break;
        case SKOneBoxAddPOITypeOther: {
            searchBar.placeHolder = [[NSAttributedString alloc] initWithString:SKOneBoxLocalizedString(@"address_or_destination_key", nil) attributes:@{NSForegroundColorAttributeName:[UIColor hexC3C3C34C]}];
            addPOICtrl.defaultSearchProviders = @[recentsProvider,favoritesProvider,contactsProvider];
        }
            break;
        default:
            break;
    }
    return addPOICtrl;
}

- (void)navigateToAddPOIWithType:(SKOneBoxAddPOIType)type shouldRestrictBackAction:(BOOL)shouldRestrictBackAction {
    SKOneBoxAddPOIViewController *controller = [self configuredAddPOIViewControllerWithAddPOIWithType:type shouldRestrictBackAction:shouldRestrictBackAction];
    
    if (shouldRestrictBackAction) {
        controller.previousOneBoxControllerStatusBarStyle = self.previousOneBoxControllerStatusBarStyle;
    }
    self.navigationItem.titleView = nil;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.15;
    transition.type = kCATransitionFade;
    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:controller animated:NO];
    
    UIColor *blue = [UIColor hex0080FF];
    [self.navigationController.navigationBar setBarTintColor:blue];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }

    SKOneBoxAddPOIType type = (SKOneBoxAddPOIType)alertView.tag;
    [self setHomeWorkWithPOIType:type];
}

- (void)setHomeWorkWithPOIType:(SKOneBoxAddPOIType)type {
    [self navigateToAddPOIWithType:type shouldRestrictBackAction:NO];
}

#pragma mark - Analytics stubs

- (void)emptyEditableResultsWithProvider:(id<SKSearchProviderProtocol>)provider {
    //empty methods, will be used for aspects programming. Cannot capture blocks so we'll call these methods inside our blocks
}

- (void)emptyCategoriesWithProvider:(id<SKSearchProviderProtocol>)provider {
    //empty methods, will be used for aspects programming. Cannot capture blocks so we'll call these methods inside our blocks
}

- (void)emptyResultsWithProvider:(id<SKSearchProviderProtocol>)provider category:(id)category {
    //empty methods, will be used for aspects programming. Cannot capture blocks so we'll call these methods inside our blocks
}

- (void)emptyResultSelectionBlock:(SKOneBoxSearchResult*)result {
    //empty methods, will be used for aspects programming. Cannot capture blocks so we'll call these methods inside our blocks
}

- (void)emptySeeAllBlockForProvider:(id<SKSearchProviderProtocol>)provider {
    //empty methods, will be used for aspects programming. Cannot capture blocks so we'll call these methods inside our blocks
}

#pragma mark - Other

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
