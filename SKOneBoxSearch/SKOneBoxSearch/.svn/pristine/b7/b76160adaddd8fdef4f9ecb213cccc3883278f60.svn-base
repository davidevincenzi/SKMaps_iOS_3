//
//  SKOneBoxBaseViewController.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKOneBoxSearchBar.h"
#import "SKOneBoxTableViewDatasource.h"
#import "SKOneBoxTableViewDelegate.h"
#import <SKOSearchLib/SKOneBoxSearchService.h>
#import "SKOneBoxUIConfigurator.h"
#import "SKOneBoxEditableResultsViewController.h"
#import "SKOneBoxAbstractMapViewDataSource.h"

@class SKOneBoxBaseViewController;
@class SKSearchProviderCategory;

@protocol SKOneBoxViewControllerDelegate <NSObject>

- (void)oneBoxViewController:(SKOneBoxBaseViewController *)viewController searchBarDidClear:(SKOneBoxSearchBar *)searchBar;
- (void)oneBoxViewController:(SKOneBoxBaseViewController *)viewController searchBarTextDidBeginEditing:(SKOneBoxSearchBar *)searchBar;
- (void)oneBoxViewController:(SKOneBoxBaseViewController *)viewController didSelectSearchResult:(SKOneBoxSearchResult *)searchResult fromResultList:(NSArray *)array;

- (void)didDismissOneBoxViewController:(SKOneBoxBaseViewController *)viewController;
- (void)willDismissOneBoxViewController:(SKOneBoxBaseViewController *)viewController;
- (void)willShowOneBoxViewController:(SKOneBoxBaseViewController *)viewController;

@optional

- (void)oneBoxViewController:(SKOneBoxBaseViewController *)viewController didReceiveSearchResults:(NSArray*)searchResults;
- (void)oneBoxViewControllerDidClearSearchResults:(SKOneBoxBaseViewController *)viewController;

- (NSString*)oneBoxViewController:(SKOneBoxBaseViewController *)viewController formatDistance:(double)distance; //distance in meters
- (id<SKOneBoxEditableResultsDatasourceProtocol>)editableDatasorceForSearchProvider:(SKSearchBaseProvider *)provider;

@end

@protocol SKOneBoxViewControllerDataSource <NSObject>

@optional
- (NSArray *)latestRecentsFavorites;
- (SKOneBoxSearchResult *)homeSearchResult;
- (SKOneBoxSearchResult *)officeSearchResult;
- (NSString *)searchLanguageCode;
- (NSArray *)locationSearchProviders;

@end


@interface SKOneBoxBaseViewController : UIViewController <UITextFieldDelegate,SKOneBoxTableViewDatasourceProtocol>

@property (nonatomic, weak) id<SKOneBoxAbstractMapViewDataSource>   abstractMapViewDataSource;

@property (nonatomic, weak) id<SKOneBoxViewControllerDelegate>      delegate;
@property (nonatomic, weak) id<SKOneBoxViewControllerDataSource>    dataSource;

@property (nonatomic, weak) IBOutlet UITableView            *tableView;

@property (nonatomic, strong) SKOneBoxTableViewDatasource   *tableViewDataSource;
@property (nonatomic, strong) SKOneBoxTableViewDelegate     *tableViewDelegate;

@property (nonatomic, strong, readonly) SKOneBoxSearchBar   *searchBar;
@property (nonatomic, strong) SKOneBoxUIConfigurator        *uiConfigurator;

@property (nonatomic, strong) void (^dismissCompletionBlock)();

@property (nonatomic, strong, readonly) NSArray *searchProviders;

@property (nonatomic, assign) UIStatusBarStyle previousOneBoxControllerStatusBarStyle;

@property (nonatomic, assign) CGFloat topInsetTableView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tableViewTopConstraint;

@property (nonatomic, strong) SKSearchProviderCategory *searchCategory;

- (instancetype)initWithSearchBar:(SKOneBoxSearchBar *)searchBar searchProviders:(NSArray *)searchProviders;

- (void)dismissViewController;
- (void)clearPreviousSearch;
- (void)updateSearchBar;
- (void)updateLanguage;

// Protected
- (void)backButtonPressed;
- (void)addBackButton;


- (void)updateTableViewInsets:(BOOL)keyboardPresent;

@end
