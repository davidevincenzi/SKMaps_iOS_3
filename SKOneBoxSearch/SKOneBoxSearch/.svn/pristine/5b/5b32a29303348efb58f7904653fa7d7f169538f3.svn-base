//
//  SKOneBoxSearchBaseViewController.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxSearchBaseViewController.h"
#import "SKOneBoxSearchPositionerService.h"
#import "SKOneBoxSearchDelayer.h"
#import "SKOneBoxCoreDataManager+SKOneBoxSearchObject.h"

#import "SKOneBoxDefaultTableViewDatasource.h"
#import "SKOneBoxDefaultTableViewDelegate.h"

#import "SKOneBoxSearchLogger.h"

#import "SKOneBoxDebugManager.h"

#import <SKOSearchLib/SKOSearchLib.h>
#import <SKOSearchLib/NSString+SKOneBoxStringAdditions.h>

@interface SKOneBoxSearchBaseViewController () <SKOneBoxSearchDelayerProtocol>


@end

@implementation SKOneBoxSearchBaseViewController

#pragma mark - Init

- (instancetype)initWithSearchBar:(SKOneBoxSearchBar *)searchBar searchProviders:(NSArray *)searchProviders {
    self = [super initWithSearchBar:searchBar searchProviders:searchProviders];
    
    if (self) {
        _coreDataManager = [SKOneBoxCoreDataManager sharedInstance];
       
        _searchDelayer = [[SKOneBoxSearchDelayer alloc] init];
        _searchDelayer.delegate = self;
        
        self.uiConfigurator = [SKOneBoxUIConfigurator new];
        
        if (searchProviders) {
            _searchService = [[SKOneBoxSearchService alloc] initWithSearchProviders:searchProviders withMinimumRelevancy:SKOneBoxSearchResultMediumRelevancy shouldUseFilter:![[SKOneBoxDebugManager sharedInstance] markBadResults]];
            [_searchService addDelegate:self];
        }
    }
    
    return self;
}

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.searchBar.delegate = self;
}

#pragma mark - Public

-(NSArray*)searchEnabledProviders {
    NSMutableArray *array = [NSMutableArray array];
    for (id<SKSearchProviderProtocol> provider in self.searchProviders) {
        if ([provider shouldShowSearchProviderInSearchResults] && [provider isSearchProviderEnabled]) {
            [array addObject:provider];
        }
    }
    return array;
}

- (void)clearPreviousSearch {
    [super clearPreviousSearch];
    [self clearSearch];
}

-(void)clearSearch {
    [self.searchDelayer cancelDelayedSearch];
    self.tableViewDataSource.searchString = nil;
    if ([self.searchService areProvidersSearching:self.searchProviders]) {
        [self.searchService cancelSearch];
    }
    [self.searchService clearSearchData];
    self.tableView.delegate = self.defaultDelegate;
    self.tableView.dataSource = self.defaultDatasource;
    
    [self.tableView reloadData];
}

- (void)categorySearch:(SKSearchProviderCategory*)category {
    self.tableViewDataSource.searchString = nil;
    
    // Cancel any previous search before starting a new one
    [self.searchService cancelSearch];
    
    SKOneBoxSearchObject *searchObject = [SKOneBoxSearchObject oneBoxSearchObject];
    if ([self.dataSource respondsToSelector:@selector(searchLanguageCode)]) {
        searchObject.searchLanguage = [self.dataSource searchLanguageCode];
    }
    CLLocationCoordinate2D coordinate = [SKOneBoxSearchPositionerService sharedInstance].currentSearchCoordinate;
    
    searchObject.coordinate = coordinate;
    searchObject.searchCategory = category.categorySearchType;
    
    for (id<SKSearchProviderProtocol> provider in self.searchProviders) {
        if ([provider shouldShowSearchProviderInSearchResults]) {
            //delete old data
            [self.tableViewDataSource.dataSource setObject:@[] forKey:[provider providerID]];
            [self.tableViewDelegate.dataSource setObject:@[] forKey:[provider providerID]];
            [self.tableView reloadData];
            
            if ([[provider categories] containsObject:category]) {
                SKOneBoxSearchObject *sortEnabledSearchObject = [searchObject copy];
                sortEnabledSearchObject.radius = provider.searchRadius;
                
                for (SKOneBoxSearchComparator *comparator in [provider sortingComparators]) {
                    if (comparator.defaultSorting && comparator.sortingParameter) {
                        sortEnabledSearchObject.searchSort = comparator.sortingParameter;
                        break;
                    }
                }
                
                sortEnabledSearchObject.itemsPerPage = provider.searchNumberOfItemsPerPage;
                
                [self.tableViewDelegate startAnimatingSectionViewForProvider:provider];
                [self.searchService search:sortEnabledSearchObject forProvider:provider];
            }
        }
    }
}

-(void)search:(NSString*)searchText location:(CLLocationCoordinate2D)coordinate {
    NSString *trimmedSearchTerm = [NSString removeSearchSpecialCharacters:searchText];
    if (![trimmedSearchTerm length]) {
        return;
    }
    
    // Cancel any previous search before starting a new one
    [self.searchService cancelSearch];

    [SKOneBoxSearchLogger logSearchQuery:searchText location:coordinate];
    
    self.tableViewDataSource.searchString = searchText;
    
    SKOneBoxSearchObject *searchObject = [SKOneBoxSearchObject oneBoxSearchObject];
    if ([self.dataSource respondsToSelector:@selector(searchLanguageCode)]) {
        searchObject.searchLanguage = [self.dataSource searchLanguageCode];
    }
    
    searchObject.coordinate = coordinate;
    searchObject.searchTerm = searchText;
    
    [self.coreDataManager saveSearchObject:searchObject];
    
    for (id<SKSearchProviderProtocol> provider in self.searchProviders) {
        if ([provider shouldShowSearchProviderInSearchResults]) {
            //delete old data
            [self.tableViewDataSource.dataSource setObject:@[] forKey:[provider providerID]];
            [self.tableViewDelegate.dataSource setObject:@[] forKey:[provider providerID]];
            [self.tableView reloadData];
        }
    }
    
    for (id<SKSearchProviderProtocol> provider in self.searchProviders) {
        if ([provider shouldShowSearchProviderInSearchResults]) {
            
            SKOneBoxSearchObject *sortEnabledSearchObject = [searchObject copy];
            sortEnabledSearchObject.radius = provider.searchRadius;
            
            for (SKOneBoxSearchComparator *comparator in [provider sortingComparators]) {
                if (comparator.defaultSorting && comparator.sortingParameter) {
                    sortEnabledSearchObject.searchSort = comparator.sortingParameter;
                    break;
                }
            }
            
            sortEnabledSearchObject.itemsPerPage = provider.searchNumberOfItemsPerPage;
            
            [self.tableViewDelegate startAnimatingSectionViewForProvider:provider];
            [self.searchService search:sortEnabledSearchObject forProvider:provider];
        }
    }
}

#pragma mark - SKOneBoxSeachDelayerDelegate

- (void)shouldStartSearchWithText:(NSString *)searchText {
    CLLocationCoordinate2D coordinate = [SKOneBoxSearchPositionerService sharedInstance].currentSearchCoordinate;
    [self search:searchText location:coordinate];
}

#pragma mark - SKOneBoxSearchServiceDelegate

- (void)searchService:(SKOneBoxSearchService *)searchService didReceiveResults:(NSArray *)results forProvider:(id<SKSearchProviderProtocol>)provider {

}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
    
    NSString *searchText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (searchText.length == 0) {
        [self clearSearch];
    } else {
        [self.searchDelayer delaySearchWithText:searchText];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [super textFieldShouldClear:textField];
    [self clearSearch];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [super textFieldShouldReturn:textField];
    [textField resignFirstResponder];
    [self.searchDelayer cancelDelayedSearch];
    CLLocationCoordinate2D coordinate = [SKOneBoxSearchPositionerService sharedInstance].currentSearchCoordinate;
    [self search:textField.text location:coordinate];
    return YES;
}

#pragma mark - Other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
