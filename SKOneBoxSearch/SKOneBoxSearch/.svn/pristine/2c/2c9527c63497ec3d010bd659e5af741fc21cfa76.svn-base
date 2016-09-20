//
//  SKOneBoxRecentsFavoritesViewController.h
//  ForeverMapNGX
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <SKOSearchLib/SKOneBoxSearchComparator.h>
#import "SKOneBoxEditableResultsDatasourceProtocol.h"

@class SKOneBoxDropdownItem;
@class SKOneBoxSearchResult;

@interface SKOneBoxEditableResultsViewController : UIViewController

@property (nonatomic, strong) UIView                *editModeLeftNavigationBarView;
@property (nonatomic, strong) UIView                *editModeRightNavigationBarView;

@property (nonatomic, strong) UIView                *leftNavigationBarView;
@property (nonatomic, strong) UIView                *rightNavigationBarView;

@property (nonatomic, strong, readonly) UIButton                *sortButton;
@property (nonatomic, strong, readonly) UIButton                *editButton;
@property (nonatomic, strong, readonly) UIButton                *cancelButton;
@property (nonatomic, strong, readonly) UIButton                *selectAllButton;

@property (nonatomic, strong) id<SKOneBoxEditableResultsDatasourceProtocol>     dataSource;

@property (nonatomic, assign) BOOL shouldChangeStatusBarStyle;

- (instancetype)initWithDataSource:(id<SKOneBoxEditableResultsDatasourceProtocol>)dataSource;

- (void)setTabelViewFullMode:(BOOL)isFullMode;
- (void)shouldDisplayNoResults:(BOOL)noResults;

@end


