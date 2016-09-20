//
//  SKOneBoxResultsViewController.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 03/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SKOneBoxResultsViewController.h"
#import <SKOSearchLib/SKOneBoxSearchService.h>
#import <SKOSearchLib/SKOneBoxSearchResultMetaData.h>
#import "SKOneBoxDropdownController.h"
#import "SKOneBoxResultsTableViewDatasource.h"

#import <SKOSearchLib/SKOneBoxSearchComparator.h>
#import "SKOneBoxSearchBar.h"

#import "UIColor+SKOneBoxColors.h"
#import "UIViewController+SKOneBoxNavigationTitle.h"
#import "NSMutableAttributedString+OneBoxSearch.h"

#import <SKOSearchLib/SKSearchProviderCategory.h>

#import "SKOneBoxResultsTableViewDelegate.h"
#import "SKOneBoxLocationView.h"
#import "SKOneBoxAddPOIViewController.h"
#import "SKOneBoxSearchConstants.h"
#import "SKOneBoxAbstractMapViewViewController.h"
#import "SKOneBoxSearchPositionerService.h"
#import <SKOSearchLib/SKOneBoxSearchResult+TableViewCellHelper.h>

@interface SKOneBoxResultsViewController () <SKOneBoxSearchServiceDelegate,UITextFieldDelegate,SKOneBoxTableViewDatasourceProtocol,SKOneBoxLocationViewProtocol>

@property (nonatomic, strong) SKOneBoxSearchService *searchService;
@property (nonatomic, strong) NSArray *searchProviders;

@property (nonatomic, strong) NSMutableDictionary *originalDataSource;

@property (nonatomic, strong) SKOneBoxDropdownController *dropDownController;

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) SKOneBoxSearchBar *oneBoxSearchBar;

@property (nonatomic, strong) UILabel *noResultsLabel;

@property (nonatomic, strong) NSString *highlightSearchTerm;

@property (nonatomic, assign) CLLocationCoordinate2D currentSearchCoordinate;
@property (nonatomic, assign) BOOL useCurrentLocation;

@property (nonatomic, strong) SKOneBoxLocationView *locationView;
@end

@implementation SKOneBoxResultsViewController
@dynamic searchProviders;

#pragma mark - Init

- (instancetype)initWithSearchProviders:(NSArray *)searchProviders searchService:(SKOneBoxSearchService *)searchService highlightSearchTerm:(NSString*)highlightSearchTerm {
    self = [super initWithSearchBar:nil searchProviders:searchProviders];
    
    if (self) {
        self.highlightSearchTerm = highlightSearchTerm;
        self.searchService = searchService;
        [self.searchService addDelegate:self];
        self.useCurrentLocation = YES;
    }
    
    return self;
}

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentSearchCoordinate = [SKOneBoxSearchPositionerService sharedInstance].currentCoordinate;
    
    //results data source/delegate
    self.tableViewDelegate = [[SKOneBoxResultsTableViewDelegate alloc] init];
    self.tableViewDelegate.sections = self.searchProviders;
    
    self.tableViewDataSource = [[SKOneBoxResultsTableViewDatasource alloc] init];
    self.tableViewDataSource.oneBoxDataSource = self;
    self.tableViewDataSource.sections = self.searchProviders;
    self.tableViewDataSource.searchString = self.highlightSearchTerm;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    for (id<SKSearchProviderProtocol> searchProvider in self.searchProviders) {
        NSArray *results = [self.searchService.dataController resultsForProvider:searchProvider];
        
        //for searches which use local comparators instead of api comparators do local sort
        SKOneBoxSearchComparator *comparator = [self currentSortingComparator];
        if (comparator && comparator.comparator) {
            results = [results sortedArrayUsingComparator:comparator.comparator];
        }
        
        [self.tableViewDataSource.dataSource setObject:results forKey:[searchProvider providerID]];
        [self.tableViewDelegate.dataSource setObject:results forKey:[searchProvider providerID]];
        
        ((SKOneBoxResultsTableViewDatasource *)self.tableViewDataSource).shouldShowLoadingCell = searchProvider.allowsPagination;
        
        SKOneBoxSearchResultMetaData *currentMetaData = [self.searchService currentMetaDataForProvider:searchProvider];
        if (currentMetaData) {
            ((SKOneBoxResultsTableViewDatasource *)self.tableViewDataSource).reachedLastPage = ![currentMetaData hasMoreResults];
        }
    }
    
    __weak typeof(self) welf = self;
    
    self.tableViewDelegate.requestNextPageBlock = ^(id<SKSearchProviderProtocol> provider) {
        if ([welf.oneBoxSearchBar.textField.text length]) { //return in case of filter text, we dont want to trigger next page
            return;
        }
        
        SKOneBoxSearchResultMetaData *currentMetaData = [welf.searchService currentMetaDataForProvider:provider];
        SKOneBoxSearchObject *currentSearchObject = [welf.searchService currentSearchObjectForProvider:provider];
        if (currentMetaData && [currentMetaData hasMoreResults]) {
            NSLog(@"Requesting next page for provider: %@", provider.localizedProviderName);
            SKOneBoxSearchObject *searchObject = currentSearchObject;
            
            searchObject.pageIndex = @(currentMetaData.page + 1);
            searchObject.pageToLoad = currentMetaData.nextPage;
            
            [welf.searchService search:searchObject forProvider:provider];
        } else {
            ((SKOneBoxResultsTableViewDatasource *)welf.tableViewDataSource).reachedLastPage = YES;
            [welf.tableView reloadData];
        }
    };
    
    if (!self.selectionBlock) {
        self.selectionBlock = ^(SKOneBoxSearchResult *searchResult, NSArray *resultList) {
            if ([welf.delegate respondsToSelector:@selector(oneBoxViewController:didSelectSearchResult:fromResultList:)]) {
                [welf.delegate oneBoxViewController:welf didSelectSearchResult:searchResult fromResultList:resultList];
            }
        };
    }
    self.tableViewDelegate.selectionBlock = self.selectionBlock;
    self.tableViewDelegate.dismissKeyboardBlock = ^{
        [welf.oneBoxSearchBar dismissKeyboard];
    };
    
    if (self.shouldShowFilteringFunction) {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
        UIImage *closeImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_clear_grey" ofType:@"png"]];
        UIImage *searchImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"searchbar_icon_magnifier" ofType:@"png"]];
        
        self.oneBoxSearchBar = [[SKOneBoxSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.frame), 44) normalClearImage:closeImage highlightedClearImage:closeImage inactiveSearchClearImage:closeImage searchImage:searchImage];
        [self.oneBoxSearchBar updateSearchBarStyle:NO];
        
        [self.oneBoxSearchBar setSearchBarTextColor:[UIColor hex3A3A3A]];
        self.oneBoxSearchBar.backgroundColor = [UIColor hexC9C9C9];
        self.oneBoxSearchBar.shouldShowSearchDot = NO;
        self.oneBoxSearchBar.delegate = self;
        self.oneBoxSearchBar.searchBarFont = [UIFont fontWithName:@"Avenir-Roman" size:13];
        
        self.tableView.tableHeaderView = self.oneBoxSearchBar;
        
        __weak typeof(self) welf= self;
        self.tableViewDelegate.scrollViewDidEndDragging = ^{
            CGPoint offset = welf.tableView.contentOffset;
            
            CGFloat barHeight = welf.oneBoxSearchBar.frame.size.height;
            if (offset.y <= barHeight/2.0f) {
                welf.tableView.contentInset = UIEdgeInsetsZero;
            } else {
                welf.tableView.contentInset = UIEdgeInsetsMake(-barHeight, 0, 0, 0);
            }
            
            welf.tableView.contentOffset = offset;
        };
        
        [self.oneBoxSearchBar updateTextFieldInsetText:CGPointMake(34, 0)];
    }
    else if (self.shouldShowLocationSelection) {
        //show location search view
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* libraryBundlePath = [mainBundlePath stringByAppendingPathComponent:@"SKOneBoxSearchBundle.bundle"];
        
        NSBundle *oneBoxBundle = [NSBundle bundleWithPath:libraryBundlePath];
        NSArray *nib = [oneBoxBundle loadNibNamed:@"SKOneBoxLocationView" owner:self options:nil];
        self.locationView = nib[0];
        self.locationView.delegate = self;
        self.locationView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.locationView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
        [view setBackgroundColor:[UIColor clearColor]];
        [view addSubview:self.locationView];
        
        self.tableView.tableHeaderView = view;
        [self updateLocationView:YES searchResult:nil];
    }
    
    self.tableView.dataSource = self.tableViewDataSource;
    self.tableView.delegate = self.tableViewDelegate;
    self.tableViewDelegate.shouldShowSectionHeaders = NO;

    self.tableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.oneBoxSearchBar.frame));
    
    [self.tableView reloadData];
    
    [self updateViewSearchingStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addBackButton];
    
    if (self.shouldShowFilteringFunction) {
        self.tableView.contentInset = UIEdgeInsetsMake(-self.oneBoxSearchBar.frame.size.height, 0, 0, 0);
    }
    
    if (self.highlightSearchTerm) {
        UIColor *blue = [UIColor hex0080FF];
        [self.navigationController.navigationBar setBarTintColor:blue];
        if (self.uiConfigurator.shouldChangeStatusBarStyle) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        }
    }
    else {
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
        if (self.uiConfigurator.shouldChangeStatusBarStyle) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        }
    }
    
    [self updateNavigationBarTitle];
}

#pragma mark - Protected

- (void)updateLanguage {
    [self updateNavigationBarTitle];
    _noResultsLabel.text = SKOneBoxLocalizedString(@"no_search_results_text_key", nil);
    if (self.useCurrentLocation) {
        self.locationView.locationLabel.text = SKOneBoxLocalizedString(@"current_location_key", nil);
    }
    
    [self.dropDownController dismiss];
    self.dropDownController = nil;
}

- (void)backButtonPressed {
    if (self.searchCategory) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"oneBoxSearchResultsBackPressed" object:nil];
    }
    
    if (self.uiConfigurator.shouldChangeStatusBarStyle) {
        [[UIApplication sharedApplication] setStatusBarStyle:self.previousOneBoxControllerStatusBarStyle animated:NO];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.searchService areProvidersSearching:self.searchProviders]) {
        [self.searchService cancelSearch];
    }
    [self removeLoadingIndicator];
    
    if ([self.delegate respondsToSelector:@selector(oneBoxViewControllerDidClearSearchResults:)]) {
        [self.delegate oneBoxViewControllerDidClearSearchResults:self];
    }
}

- (void)sortButtonPressed {
    if (!self.dropDownController) {
        self.dropDownController = [[SKOneBoxDropdownController alloc] init];
        
        if ([self.searchProviders count]) {
            id<SKSearchProviderProtocol> provider = [self.searchProviders objectAtIndex:0];
            for (SKOneBoxSearchComparator *comparator in [provider sortingComparators]) {
                SKOneBoxDropdownItem *item = [SKOneBoxDropdownItem dropdownItem];
                item.title = comparator.sortTitle;
                item.image = comparator.sortImage;
                item.activeImage = comparator.sortActiveImage;
                item.selected = comparator.defaultSorting;
                
                if (comparator.comparator) {
                    item.selectionBlock = ^void(SKOneBoxDropdownItem *item) {
                        NSArray *results = [self.searchService.dataController resultsForProvider:provider];
                        [self filterResults:results forProvider:provider usingComparator:comparator];
                    };
                }
                else if (comparator.sortingParameter){
                    item.selectionBlock = ^void(SKOneBoxDropdownItem *item) {
                        //no comparator we have sort parameter. search service must be called
                        NSLog(@"searching using sort : %@", comparator.sortTitle);
                        
                        SKOneBoxSearchObject *currentSearchObject = [self.searchService currentSearchObjectForProvider:provider];
                        currentSearchObject.searchSort = comparator.sortingParameter;
                        currentSearchObject.pageIndex = nil;
                        currentSearchObject.pageToLoad = nil;
                        
                        [self removeLoadingIndicator];
                        [self addLoadingIndicator];
                        
                        [self clearResults];
                        
                        [self.searchService search:currentSearchObject forProvider:provider];
                    };
                }
                
                [self.dropDownController addDropdownItem:item];
            }
        }
    }
    
    if (!self.dropDownController.visible) {
        [self.dropDownController presentInViewController:self];
    } else {
        [self.dropDownController dismiss];
    }
}

#pragma mark - Private

-(void)updateViewSearchingStatus {
    [self removeNoResultsLabel];
    
    if ([self.searchService areProvidersSearching:self.searchProviders]) {
        self.navigationItem.rightBarButtonItem = nil;
        self.tableView.hidden = YES;
        [self addLoadingIndicator];
    }
    else {
        [self removeLoadingIndicator];
        
        if ([self.searchProviders count]) {
            id<SKSearchProviderProtocol> provider = [self.searchProviders objectAtIndex:0];
            NSInteger count = [(NSArray*)[self.searchService.dataController resultsForProvider:provider] count];
            if (count > 1 && [[provider sortingComparators] count]) {
                [self addSortButton];
            }
            if (!count) {
                //no results, and not loading
                self.tableView.hidden = YES;
                [self addNoResultsLabel];
            }
            else {
                self.tableView.hidden = NO;
            }
        }
    }
}

-(void)search:(BOOL)currentLocation searchResult:(SKOneBoxSearchResult*)result {
    [self updateLocationView:currentLocation searchResult:result];
    
    if (currentLocation) {
        self.currentSearchCoordinate = [SKOneBoxSearchPositionerService sharedInstance].currentCoordinate;
        self.useCurrentLocation = YES;
    }
    else {
        self.currentSearchCoordinate = result.coordinate;
        self.useCurrentLocation = NO;
    }
    
    if ([self.searchProviders count]) {
        
        for (id<SKSearchProviderProtocol> provider in self.searchProviders) {
            //delete old data
            [self.tableViewDataSource.dataSource setObject:@[] forKey:[provider providerID]];
            [self.tableViewDelegate.dataSource setObject:@[] forKey:[provider providerID]];
            [self.tableView reloadData];
        }
        
        //get last search object
        SKOneBoxSearchObject *lastSearchObject = [self.searchService currentSearchObjectForProvider:self.searchProviders[0]];
        lastSearchObject.coordinate = self.currentSearchCoordinate;
        lastSearchObject.pageIndex = 0;
        lastSearchObject.pageToLoad = nil;
        
        [self.searchService clearSearchData];
        [[self searchService] search:lastSearchObject];
        
        [self updateViewSearchingStatus];
    }

}

-(void)updateLocationView:(BOOL)currentLocation searchResult:(SKOneBoxSearchResult*)result {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
    
    if (currentLocation) {
        UIImage *addImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"current_location_icon" ofType:@"png"]];
        
        self.locationView.locationLabel.text = SKOneBoxLocalizedString(@"current_location_key", nil);
        self.locationView.locationImageView.image = addImage;
        self.locationView.locationButton.hidden = YES;
    }
    else if (result) {
        UIImage *addImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"different_location_icon" ofType:@"png"]];
        
        self.locationView.locationLabel.text = [result title];
        self.locationView.locationImageView.image = addImage;
        self.locationView.locationButton.hidden = NO;
    }
}

- (void)addNoResultsLabel {
    if (!_noResultsLabel) {
        _noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0, CGRectGetWidth(self.view.frame)-20, 80.0)];
        _noResultsLabel.center = self.view.center;
        _noResultsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _noResultsLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:20.0];
        _noResultsLabel.textAlignment = NSTextAlignmentCenter;
        _noResultsLabel.backgroundColor = [UIColor clearColor];
        _noResultsLabel.text = SKOneBoxLocalizedString(@"no_search_results_text_key", nil);
        _noResultsLabel.textColor = [UIColor hexC3C3C3FF];
        _noResultsLabel.numberOfLines = 0;
        _noResultsLabel.accessibilityIdentifier = @"SKOneBoxResultsNoResults";
    }
    
    UILabel *label = _noResultsLabel;
    [_noResultsLabel removeFromSuperview];
    [self.view addSubview:label];
}

-(void)removeNoResultsLabel {
    [_noResultsLabel removeFromSuperview];
    _noResultsLabel = nil;
}

-(void)clearResults {
    for (id<SKSearchProviderProtocol> searchProvider in self.searchProviders) {
        [self.tableViewDataSource.dataSource setObject:@[] forKey:[searchProvider providerID]];
        [self.tableViewDelegate.dataSource setObject:@[] forKey:[searchProvider providerID]];
    }
    [self.tableView reloadData];
}

-(void)updateNavigationBarTitle {
    //title nav bar, place holder search bar
    if ([self.searchProviders count]) {
        id<SKSearchProviderProtocol> searchProvider = self.searchProviders[0];
        SKOneBoxSearchObject *searchObject = [self.searchService currentSearchObjectForProvider:searchProvider];
        
        UIColor *titleColor = nil;
        if (self.highlightSearchTerm) {
            titleColor = [UIColor whiteColor];
        }
        else {
            titleColor = [UIColor hex3A3A3A];
        }
        
        NSString *text = nil;
        NSString *highlightText = nil;
        NSString *placeholderSearchBarText = nil;
        UIImage *image = nil;
        
        if (searchObject.searchCategory) {
            //searching for categories, set appropiate title
            //match category id obj with category provider to get localized name
            for (SKSearchProviderCategory *category in [searchProvider categories]) {
                if ([category.categorySearchType isEqual:[searchObject searchCategory]]) {
                    placeholderSearchBarText = [NSString stringWithFormat:SKOneBoxLocalizedString(@"search_in_NAME_results_key", nil), category.localizedCategoryName];
                    image = category.categoryImage;
                    
                    text = [NSString stringWithFormat:@"%@ %@", category.localizedCategoryName, SKOneBoxLocalizedString(@"results_navigation_bar_title_key", nil)];
                    break;
                }
            }
            
            highlightText = SKOneBoxLocalizedString(@"results_navigation_bar_title_key", nil);
        }
        else {
            image = searchProvider.providerIcon;
            placeholderSearchBarText = [NSString stringWithFormat:SKOneBoxLocalizedString(@"search_in_NAME_results_key", nil), searchProvider.localizedProviderName];
            text = searchProvider.localizedProviderName;
            highlightText = nil;
        }
        
        NSMutableAttributedString *attributedString = [NSMutableAttributedString attributedText:text highlightedText:highlightText font:[UIFont fontWithName:@"Avenir-Roman" size:16] color:titleColor highlightedFont:[UIFont fontWithName:@"Avenir-Heavy" size:16] highlightedColor:titleColor];
        self.navigationItem.titleView = [self titleViewWithText:attributedString];
        self.tableViewDataSource.searchResultImage = image;
        
        self.oneBoxSearchBar.placeHolder = [[NSAttributedString alloc] initWithString:placeholderSearchBarText attributes:@{NSForegroundColorAttributeName:[UIColor hex898989]}];
    }
}

-(void)addLoadingIndicator {
    [self removeLoadingIndicator];
    if (!self.loadingIndicator) {
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.loadingIndicator.center = self.view.center;
        self.loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    
    [self.view addSubview:self.loadingIndicator];
    [self.loadingIndicator startAnimating];
}

-(void)removeLoadingIndicator {
    [self.loadingIndicator stopAnimating];
    [self.loadingIndicator removeFromSuperview];
    self.loadingIndicator = nil;
}

- (void)addSortButton {
    UIImage *sortImage = nil;
    if (self.highlightSearchTerm) {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
        sortImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_sort_white" ofType:@"png"]];
    }
    else {
        sortImage = [self.uiConfigurator resultsSortButtonImage];
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, sortImage.size.width, sortImage.size.height)];
    [button setImage:sortImage forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(sortButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)addBackButton {
    UIImage *backImage = nil;
    
    if (self.highlightSearchTerm) {
        backImage = [self.uiConfigurator searchBackButtonImage];
    }
    else {
        backImage = [self.uiConfigurator resultsBackButtonImage];
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    [button setImage:backImage forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    button.accessibilityIdentifier = @"SKOneBoxResultsBackButton";
}

- (void)filterSearch:(NSString*)filterText {
    if ([self.searchProviders count]) {
        id<SKSearchProviderProtocol> provider = [self.searchProviders objectAtIndex:0];
        
        NSArray *results = [self.searchService.dataController resultsForProvider:provider];
        
        if ([filterText length]) {
            NSPredicate *predicate   = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@)",
                                        filterText];
            results = [results filteredArrayUsingPredicate:predicate];
        }
        
        ((SKOneBoxResultsTableViewDatasource *)self.tableViewDataSource).shouldShowLoadingCell = !filterText.length && provider.allowsPagination;
        
        [self.tableViewDataSource.dataSource setObject:results forKey:[provider providerID]];
        [self.tableViewDelegate.dataSource setObject:results forKey:[provider providerID]];
        [self.tableView reloadData];
    }
}

- (void)filterResults:(NSArray *)results forProvider:(id<SKSearchProviderProtocol>)provider usingComparator:(SKOneBoxSearchComparator *)comparator {
    if (comparator.comparator) {
        results = [results sortedArrayUsingComparator:comparator.comparator];
    }
    
    //check to see if we have pagination
    SKOneBoxSearchResultMetaData *metaData = [self.searchService currentMetaDataForProvider:provider];
    ((SKOneBoxResultsTableViewDatasource *)self.tableViewDataSource).shouldShowLoadingCell = [metaData hasMoreResults] && provider.allowsPagination;
    
    [self.tableViewDataSource.dataSource setObject:results forKey:[provider providerID]];
    [self.tableViewDelegate.dataSource setObject:results forKey:[provider providerID]];
    [self.tableView reloadData];
}

- (SKOneBoxSearchComparator *)currentSortingComparator {
    if ([self.searchProviders count]) {
        id<SKSearchProviderProtocol> provider = [self.searchProviders objectAtIndex:0];
        NSArray *comparators = [provider sortingComparators];
        
        if (self.dropDownController && self.dropDownController.indexForCurrentSelectedItem != NSNotFound) {
            return comparators[self.dropDownController.indexForCurrentSelectedItem];
        }
        
        for (SKOneBoxSearchComparator *comparator in [provider sortingComparators]) {
            if (comparator.defaultSorting) {
                return comparator;
            }
        }
    }
    
    return nil;
}

#pragma mark - SKOneBoxSearchServiceDelegate

- (void)searchService:(SKOneBoxSearchService *)searchService didReceiveResults:(NSArray *)results forProvider:(id<SKSearchProviderProtocol>)provider {
    [self filterResults:results forProvider:provider usingComparator:[self currentSortingComparator]];
    
    [self updateViewSearchingStatus];
    
    if ([self.delegate respondsToSelector:@selector(oneBoxViewController:didReceiveSearchResults:)]) {
        [self.delegate oneBoxViewController:self didReceiveSearchResults:results];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
    
    NSString *searchText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self filterSearch:searchText];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self filterSearch:textField.text];
    [self.oneBoxSearchBar updateClearButton:NO];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self filterSearch:textField.text];
    
    return YES;
}

#pragma mark - SKOneBoxTableViewDatasourceProtocol

- (NSString *)formatDistance:(double)distance {
    if ([self.delegate respondsToSelector:@selector(oneBoxViewController:formatDistance:)]) {
        return [self.delegate oneBoxViewController:self formatDistance:distance];
    }
    
    return nil;
}

#pragma mark - SKOneBoxLocationView

-(void)didTapClearLocation:(SKOneBoxLocationView*)locationView {
    [self search:YES searchResult:nil];
}

-(void)didTapLocationView:(SKOneBoxLocationView*)locationView {
    //push location search
    SKOneBoxAddPOIViewController *locationSearch = [self configuredLocationSearchViewController];
    
    self.navigationItem.titleView = nil;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.15;
    transition.type = kCATransitionFade;
    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:locationSearch animated:NO];
    
    UIColor *blue = [UIColor hex0080FF];
    [self.navigationController.navigationBar setBarTintColor:blue];
    if (self.uiConfigurator.shouldChangeStatusBarStyle) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
}

-(SKOneBoxAddPOIViewController *)configuredLocationSearchViewController {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
    
    NSArray *providersLocation = nil;
    if ([self.dataSource respondsToSelector:@selector(locationSearchProviders)]) {
        providersLocation = [self.dataSource locationSearchProviders];
    }
    
    UIImage *closeImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_clear_white" ofType:@"png"]];
    closeImage.accessibilityIdentifier = @"SKOneBoxCloseImage";
    UIImage *clearImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_clear_grey" ofType:@"png"]];
    clearImage.accessibilityIdentifier = @"SKOneBoxClearImage";
    UIImage *closeImageAlpha = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_clear_white_alpha" ofType:@"png"]];
    
    SKOneBoxSearchBar *searchBar = [[SKOneBoxSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 32.0) normalClearImage:closeImageAlpha highlightedClearImage:closeImage inactiveSearchClearImage:clearImage searchImage:nil];
    [searchBar setShouldShowSearchDot:NO];
    
    SKOneBoxAddPOIViewController *ctrl = [[SKOneBoxAddPOIViewController alloc] initWithSearchBar:searchBar searchProviders:providersLocation];
    
    searchBar.placeHolder = [[NSAttributedString alloc] initWithString:SKOneBoxLocalizedString(@"enter_home_address_search_bar_place_holder_key", nil) attributes:@{NSForegroundColorAttributeName:[UIColor hexC3C3C34C]}];
    
    __weak typeof(self) welfSelf = self;
    [ctrl setSelectResultBlock:^(SKOneBoxSearchResult *result, NSArray *results) {
        [welfSelf.navigationController popToViewController:welfSelf animated:YES];
        [welfSelf search:NO searchResult:result];
    }];
    
    ctrl.abstractMapViewDataSource = self.abstractMapViewDataSource;
    ctrl.defaultItems = [self defaultLocationSearchItems];
    ctrl.uiConfigurator = self.uiConfigurator;
    
    ctrl.delegate = self.delegate;
    
    return ctrl;
}

- (NSArray *)defaultLocationSearchItems {
    //add select on map item
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
    NSMutableArray *items = [NSMutableArray array];
    
    SKOneBoxDefaultTableItem *item = [SKOneBoxDefaultTableItem new];
    item.title = SKOneBoxLocalizedString(@"current_location_key", nil);
    item.subTitle = nil;
    item.itemHeight = kRowHeightOneLineResult;
    item.image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"current_location_icon_grey" ofType:@"png"]];
    
    __weak typeof(self) welfSelf = self;
    
    item.selectionBlock = ^() {
        //pop to self and search using current location
        [welfSelf.navigationController popToViewController:welfSelf animated:YES];
        CLLocationCoordinate2D coordinate = [SKOneBoxSearchPositionerService sharedInstance].currentCoordinate;
        if (welfSelf.currentSearchCoordinate.latitude != coordinate.latitude && welfSelf.currentSearchCoordinate.longitude != coordinate.longitude) {
            //search with new coordinate
            [welfSelf search:YES searchResult:nil];
        }
    };
    
    [items addObject:item];
    
    SKOneBoxDefaultTableItem *item2 = [SKOneBoxDefaultTableItem new];
    item2.title = SKOneBoxLocalizedString(@"choose_on_map_key", nil);
    item2.subTitle = nil;
    item2.itemHeight = kRowHeightOneLineResult;
    item2.image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"add_location_icon" ofType:@"png"]];
    
    item2.selectionBlock = ^() {
        typeof(self) strongSelf = welfSelf;
        //open map
        if ([strongSelf.abstractMapViewDataSource respondsToSelector:@selector(oneBoxMapView)]) {
            UIView<SKOneBoxAbstractMapViewProtocol> *mapView = [strongSelf.abstractMapViewDataSource oneBoxMapView];
            [mapView setMapViewDidSelectResult:^(SKOneBoxSearchResult *result) {
                if ([welfSelf.abstractMapViewDataSource  respondsToSelector:@selector(navigationControllerForMap)]) {
                    [[welfSelf.abstractMapViewDataSource navigationControllerForMap] popToRootViewControllerAnimated:YES];
                }
                
                [welfSelf.navigationController popToViewController:welfSelf animated:YES];
                [welfSelf search:NO searchResult:result];
            }];
            SKOneBoxAbstractMapViewViewController *abstractMapCtrl = [[SKOneBoxAbstractMapViewViewController alloc] initWithMapView:mapView];
            abstractMapCtrl.uiConfigurator = self.uiConfigurator;
            
            UINavigationController *navController = welfSelf.navigationController;
            if ([strongSelf.abstractMapViewDataSource  respondsToSelector:@selector(navigationControllerForMap)]) {
                navController = [strongSelf.abstractMapViewDataSource navigationControllerForMap];
                [navController popToRootViewControllerAnimated:NO];
            }
            
            [navController pushViewController:abstractMapCtrl animated:YES];
        }
    };
    
    [items addObject:item2];
    
    return items;
}


@end
