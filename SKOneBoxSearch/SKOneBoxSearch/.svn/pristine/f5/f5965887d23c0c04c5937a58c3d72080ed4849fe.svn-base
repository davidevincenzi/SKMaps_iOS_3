//
//  SKOneBoxCategoriesViewController.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxCategoriesViewController.h"
#import "SKOneBoxDefaultTableViewDatasource.h"
#import "SKOneBoxDefaultTableViewDelegate.h"

#import "SKOneBoxResultsViewController.h"

#import "SKOneBoxSearchPositionerService.h"

#import <SKOSearchLib/SKSearchProviderCategory.h>
#import <SKOSearchLib/SKOneBoxSearchComparator.h>

#import "NSMutableAttributedString+OneBoxSearch.h"
#import "UIColor+SKOneBoxColors.h"
#import "UIViewController+SKOneBoxNavigationTitle.h"

#import "SKOneBoxSearchConstants.h"

@interface SKOneBoxCategoriesViewController ()

@property (nonatomic, strong) id<SKSearchProviderProtocol> searchProvider;

@property (nonatomic, strong) SKOneBoxDefaultTableViewDatasource *defaultDatasource;
@property (nonatomic, strong) SKOneBoxDefaultTableViewDelegate *defaultDelegate;

@end

@implementation SKOneBoxCategoriesViewController

#pragma mark - Init

- (instancetype)initWithSearchProvider:(id<SKSearchProviderProtocol>)searchProvider {
    self = [super initWithSearchBar:nil searchProviders:nil];
    
    if (self) {
        self.searchProvider = searchProvider;
    }
    
    return self;
}

#pragma mark - View methods

-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *categoryItems = [self categoryItems];
    
    //default tableview
    self.defaultDatasource = [[SKOneBoxDefaultTableViewDatasource alloc] init];
    self.defaultDelegate = [[SKOneBoxDefaultTableViewDelegate alloc] init];
    
    self.defaultDatasource.sections = categoryItems;
    self.defaultDelegate.sections = categoryItems;
    
    self.tableView.delegate = self.defaultDelegate;
    self.tableView.dataSource = self.defaultDatasource;
    
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.uiConfigurator.shouldChangeStatusBarStyle) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    }
    
    [self updateNavigationBarTitle];
}

#pragma mark - Protected

- (void)updateLanguage {
    [self updateNavigationBarTitle];
    
    NSArray *categoryItems = [self categoryItems];
    
    self.defaultDatasource.sections = categoryItems;
    self.defaultDelegate.sections = categoryItems;
    
    [self.tableView reloadData];
}

#pragma mark - Private

-(void)updateNavigationBarTitle {
    UIColor *titleColor = [UIColor hex3A3A3A];
    NSMutableAttributedString *attributedString = [NSMutableAttributedString attributedText:[NSString stringWithFormat:@"%@ %@", self.searchProvider.localizedProviderName, SKOneBoxLocalizedString(@"categories_navigation_bar_title_key", nil)] highlightedText:SKOneBoxLocalizedString(@"categories_navigation_bar_title_key", nil) font:[UIFont fontWithName:@"Avenir-Roman" size:16] color:titleColor highlightedFont:[UIFont fontWithName:@"Avenir-Heavy" size:16] highlightedColor:titleColor];
    
    self.navigationItem.titleView = [self titleViewWithText:attributedString];
}

- (NSArray *)categoryItems {
    NSMutableArray *returnSectionItems = [NSMutableArray array];
    
    SKOneBoxDefaultSectionItem *sectionItemProvider = [[SKOneBoxDefaultSectionItem alloc] init];
    sectionItemProvider.showHeaderSection = NO;
    sectionItemProvider.headerSectionHeight = 0.0f;
    
    NSMutableArray *sectionItems = [NSMutableArray array];
    
    __weak typeof(self) welf = self;
    
    for (SKSearchProviderCategory *category in [self.searchProvider categories]) {
        if (!category.isMainCategory) {
            continue;
        }
        [sectionItems addObject:({
            SKOneBoxDefaultTableItem *tableItem = [[SKOneBoxDefaultTableItem alloc] init];
            tableItem.title = category.localizedCategoryName;
            tableItem.image = [category categoryImage];
            
            tableItem.selectionBlock = ^(void) {
                NSLog(@"Provider selected : %@", self.searchProvider.localizedProviderName);
                
                SKOneBoxSearchService *service = [[SKOneBoxSearchService alloc] initWithSearchProviders:@[self.searchProvider] withMinimumRelevancy:SKOneBoxSearchResultMediumRelevancy shouldUseFilter:YES];
                SKOneBoxResultsViewController *resultsViewController = [[SKOneBoxResultsViewController alloc] initWithSearchProviders:@[welf.searchProvider] searchService:service highlightSearchTerm:nil];
                resultsViewController.searchCategory = category;
                
                resultsViewController.uiConfigurator = welf.uiConfigurator;
                
                welf.navigationItem.titleView = nil;
                [welf.navigationController pushViewController:resultsViewController animated:YES];
                resultsViewController.delegate = welf.delegate;
                resultsViewController.dataSource = welf.dataSource;
                resultsViewController.abstractMapViewDataSource = welf.abstractMapViewDataSource;
                
                resultsViewController.shouldShowFilteringFunction = NO;
                resultsViewController.shouldShowLocationSelection = NO;
                
                SKOneBoxSearchObject *searchObject = [SKOneBoxSearchObject oneBoxSearchObject];
                if ([self.dataSource respondsToSelector:@selector(searchLanguageCode)]) {
                    searchObject.searchLanguage = [self.dataSource searchLanguageCode];
                }
                searchObject.coordinate = [SKOneBoxSearchPositionerService sharedInstance].currentSearchCoordinate;
                searchObject.radius = self.searchProvider.searchRadius;
                searchObject.searchCategory = category.categorySearchType;
                searchObject.searchTerm = nil;
                searchObject.itemsPerPage = self.searchProvider.searchNumberOfItemsPerPage;
                
                for (SKOneBoxSearchComparator *comparator in [self.searchProvider sortingComparators]) {
                    if (comparator.defaultSorting && comparator.sortingParameter) {
                        searchObject.searchSort = comparator.sortingParameter;
                        break;
                    }
                }
                [service search:searchObject forProvider:welf.searchProvider];
            };
            
            tableItem;
        })];
    }
    [sectionItemProvider setSectionTableItems:sectionItems];
    
    [returnSectionItems addObject:sectionItemProvider];
    
    return returnSectionItems;
}

#pragma mark - Protected

- (void)addBackButton {
    UIImage *backImage = [self.uiConfigurator resultsBackButtonImage];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    [button setImage:backImage forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    button.accessibilityIdentifier = @"SKOneBoxResultsBackButton";
}

- (void)backButtonPressed {
    if (self.uiConfigurator.shouldChangeStatusBarStyle) {
        [[UIApplication sharedApplication] setStatusBarStyle:self.previousOneBoxControllerStatusBarStyle animated:NO];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
