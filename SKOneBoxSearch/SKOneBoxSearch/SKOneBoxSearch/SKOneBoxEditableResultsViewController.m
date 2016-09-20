//
//  SKOneBoxRecentsFavoritesViewController.m
//  ForeverMapNGX
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxEditableResultsViewController.h"

#import "UIColor+SKOneBoxColors.h"
#import "UIViewController+SKOneBoxNavigationTitle.h"
#import "NSMutableAttributedString+OneBoxSearch.h"

#import "SKOneBoxSwipeTableCell.h"

#import <SKOneBoxSearch/SKOneBoxDropdownController.h>
#import <SKOneBoxSearch/SKOneBoxDropdownItem.h>
#import <SKOneboxSearch/SKOneBoxSearchBar.h>

#define kOneBoxSearchBarHeight 44

@interface SKOneBoxEditableResultsViewController () <UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView            *tableView;

@property (nonatomic, strong) UIButton                      *sortButton;
@property (nonatomic, strong) UIButton                      *editButton;

@property (nonatomic, strong) UIButton                      *cancelButton;
@property (nonatomic, strong) UIButton                      *selectAllButton;

@property (nonatomic, strong) UIButton                      *deleteSelectedButton;
@property (nonatomic, assign) BOOL                          isInEditMode;

@property (nonatomic, strong) NSArray                       *cachedLeft;
@property (nonatomic, strong) NSArray                       *cachedRight;

@property (nonatomic, strong) SKOneBoxDropdownController    *dropDownController;
@property (nonatomic, strong) UIButton                      *addNewElementButton;
@property (nonatomic, strong) SKOneBoxSearchBar             *searchBar;
@property (nonatomic, strong) UILabel                       *noResultsLabel;

@property (nonatomic, assign) CGPoint                       prevContentOffset;
@property (nonatomic, assign) BOOL                          tableViewIsFull;

@end

@implementation SKOneBoxEditableResultsViewController

#pragma mark - Init

- (instancetype)initWithDataSource:(id<SKOneBoxEditableResultsDatasourceProtocol>)delegate {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
    self = [super initWithNibName:@"SKOneBoxEditableResultsViewController" bundle:bundle];
    if (self) {
        self.dataSource = delegate;
        self.tableView.accessibilityIdentifier = @"SKOneBoxEditableResultsViewControllerTableView";
    }

    return self;
}

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLanguage) name:kSKOneBoxLanguageDidChangeNotification object:nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self.dataSource;
    self.tableView.rowHeight = 72;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor hexF3F3F3];
    self.tableViewIsFull = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.dataSource.tableView = self.tableView;
    self.dataSource.editableViewController = self;
    [self.dataSource reloadData];

    [self addSearchBar];
    [self addRightNavigationBarItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    self.editModeLeftNavigationBarView = self.selectAllButton;
    self.editModeRightNavigationBarView = self.cancelButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-kOneBoxSearchBarHeight, 0, 0, 0);
    
    if (self.shouldChangeStatusBarStyle) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    }
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    if (self.dataSource.didSelectAddNewElement && !self.addNewElementButton) {
        self.addNewElementButton = [self setupAddNewElementButton];
        [self.view addSubview:self.addNewElementButton];
    }
    
    [self smallTableViewAnimated:NO];
    
    [self.searchBar presentAnimated:NO];
}

- (void)controllerDidExit {
    //used for analytics tracking
}

-(void)sortWithComparator:(SKOneBoxSearchComparator*)comparator {
    [self.dataSource sortWithComparator:comparator];
}

#pragma mark - Private 

- (void)updateLanguage {
    [self setViewControllerTitle];
    [_deleteSelectedButton setTitle:SKOneBoxLocalizedString(@"delete_button_title_key", nil) forState:UIControlStateNormal];
    [_selectAllButton setTitle:SKOneBoxLocalizedString(@"select_all_button_title_key", nil) forState:UIControlStateNormal];
    [_selectAllButton setTitle:SKOneBoxLocalizedString(@"deselect_all_button_title_key", nil) forState:UIControlStateSelected];
    
    [_cancelButton setTitle:SKOneBoxLocalizedString(@"cancel_button_title_key", nil) forState:UIControlStateNormal];
    
    _noResultsLabel.text = SKOneBoxLocalizedString(@"no_search_results_text_key", nil);
}

#pragma mark - Other

- (void)dealloc {
    [self controllerDidExit];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGPoint offset = self.tableView.contentOffset;
    
    CGFloat barHeight = kOneBoxSearchBarHeight;
    if (offset.y <= barHeight/2.0f) {
        self.tableView.contentInset = UIEdgeInsetsZero;
    } else {
        self.tableView.contentInset = UIEdgeInsetsMake(-barHeight, 0, 0, 0);
    }
    
    self.tableView.contentOffset = offset;
}

#pragma mark - Actions

- (void)didTapSortButton:(UIButton *)button {
    if (!self.dropDownController) {
        self.dropDownController = [SKOneBoxDropdownController new];
        
        for (SKOneBoxSearchComparator *comparator in self.dataSource.sortingComparators) {
            SKOneBoxDropdownItem *item = [SKOneBoxDropdownItem dropdownItemWithTitle:comparator.sortTitle];
            item.image = comparator.sortImage;
            item.activeImage = comparator.sortActiveImage;
            
            if (comparator.defaultSorting) {
                item.selected = YES;
            }

            item.selectionBlock = ^(SKOneBoxDropdownItem *sender) {
                [self sortWithComparator:comparator];
            };
            [self.dropDownController addDropdownItem:item];
        }
    }
    
    if (!self.dropDownController.visible) {
        [self.dropDownController presentInViewController:self];
    } else {
        [self.dropDownController dismiss];
    }
}

- (void)didTapEditBarButton:(UIButton *)button {
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.cachedLeft = self.navigationItem.leftBarButtonItems;
    self.cachedRight = self.navigationItem.rightBarButtonItems;
    [self setNavigationBarLeftCustomView:self.editModeLeftNavigationBarView];
    [self setNavigationBarRightCustomView:self.editModeRightNavigationBarView];
    [self.view addSubview:self.deleteSelectedButton];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.frame = ({
            CGRect frame = self.view.frame;
            frame.origin.y = 0;
            frame.size.height = self.view.frame.size.height - self.addNewElementButton.frame.size.height;
            frame;
        });
        self.deleteSelectedButton.frame = ({
            CGRect frame = self.searchBar.frame;
            frame.origin.y = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.deleteSelectedButton.frame);
            frame;
        });
        [self.tableView setTableHeaderView:nil];
    }];
    self.isInEditMode = YES;
    [self setViewControllerTitle];
    [self.dataSource shouldDisplayInEditMode:YES];
    [self.dropDownController dismiss];
}

- (void)didTapSelectAllButton:(UIButton *)button {
    self.selectAllButton.selected = !self.selectAllButton.selected;
    [self.dataSource didToggleSelectAllItems];
}

- (void)didTapCancelButton:(UIButton *)button {
    [self dissmisEditMode];
}

- (void)didTapDeleteButton {
    [self dissmisEditMode];
    [self.dataSource didTapDeleteButton];
}

- (void)dissmisEditMode {
    self.tableView.contentInset = UIEdgeInsetsMake(-kOneBoxSearchBarHeight, 0, 0, 0);
    
    [self.navigationItem setLeftBarButtonItems:self.cachedLeft];
    [self.navigationItem setRightBarButtonItems:self.cachedRight];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.frame = ({
            CGRect frame = self.view.frame;
            frame.origin.y = 0;
            frame.size.height = self.view.frame.size.height - self.addNewElementButton.frame.size.height;
            frame;
        });
        self.deleteSelectedButton.frame = ({
            CGRect frame = self.deleteSelectedButton.frame;
            frame.origin.y = self.view.frame.size.height;
            frame;
        });
        [self.tableView setTableHeaderView:self.searchBar];
    }];
    self.isInEditMode = NO;
    [self setViewControllerTitle];
    [self.dataSource shouldDisplayInEditMode:NO];
}

#pragma mark - Overridden 

- (void)setDataSource:(id<SKOneBoxEditableResultsDatasourceProtocol>)dataSource {
    dataSource.tableView = self.tableView;
    _dataSource = dataSource;
    self.tableView.dataSource = dataSource;
    [self setViewControllerTitle];
}

- (void)setViewControllerTitle {
    if (!self.isInEditMode) {
        if (self.dataSource.title) {
            NSString *text = [NSString stringWithFormat:@"%@ %@", self.dataSource.title,SKOneBoxLocalizedString(@"results_navigation_bar_title_key", nil)];
            NSString *highlightText = SKOneBoxLocalizedString(@"results_navigation_bar_title_key", nil);
            NSMutableAttributedString *attributedString = [NSMutableAttributedString attributedText:text highlightedText:highlightText font:[UIFont fontWithName:@"Avenir-Roman" size:16] color:[UIColor hex3A3A3A] highlightedFont:[UIFont fontWithName:@"Avenir-Heavy" size:16] highlightedColor:[UIColor hex3A3A3A]];
            self.navigationItem.titleView = [self titleViewWithText:attributedString];
        } else {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"";
            
            self.navigationItem.titleView = label;
        }
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"Avenir-Heavy" size:16.0];
        label.textColor = [UIColor hex3A3A3A];
        label.text = SKOneBoxLocalizedString(@"select_items_key", nil);
        
        self.navigationItem.titleView = label;
    }
}

- (void)setTabelViewFullMode:(BOOL)isFullMode {
    self.tableViewIsFull = isFullMode;
    if (!isFullMode) {
        [self smallTableViewAnimated:NO];
        self.addNewElementButton.frame = CGRectMake(0.0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
        [self.searchBar presentAnimated:NO];
    } else {
        [self largeTableViewAnimated:NO];
        self.addNewElementButton.frame = CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 44);
        [self.searchBar dissmisAnimated:NO];
    }
}

- (void)shouldDisplayNoResults:(BOOL)noResults {
    if (noResults) {
        [self addNoResultsLabel];
        [self.sortButton setHidden:YES];
        [self.editButton setHidden:YES];
        [self.searchBar setHidden:YES];
        
        if (self.isInEditMode) {
            [self dissmisEditMode];
        }
    } else {
        [self removeNoResultsLabel];
        [self.sortButton setHidden:NO];
        [self.editButton setHidden:NO];
        [self.searchBar setHidden:NO];
    }
}

#pragma mark - Tabel View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id poi = self.dataSource.datasource[indexPath.section][indexPath.row];

    if (self.isInEditMode) {
        [self.dataSource didSelectDatasourceItem:poi];
    } else if (self.dataSource.didSelectRowWithDatasourceItem) {
        self.dataSource.didSelectRowWithDatasourceItem(poi);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.dataSource.currentComparator == self.dataSource.sortingComparators[1]) {
        return 22.0;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
        return 1.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 22.0)];
    UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, CGRectGetWidth(sectionView.frame) - 10.0, CGRectGetHeight(sectionView.frame))];
    UIView *sectionLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(sectionView.frame) - 1.0, CGRectGetWidth(self.view.frame), 1.0)];
    
    sectionTitleLabel.text = self.dataSource.sectionTimeTitles[section];
    sectionTitleLabel.textColor = [UIColor hex898989];
    sectionTitleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:12.0];
    
    sectionView.backgroundColor = [UIColor hexF3F3F3];
    sectionLineView.backgroundColor = [UIColor hexEDEDED];
    
    [sectionView addSubview:sectionTitleLabel];
    [sectionView addSubview:sectionLineView];
    
    return sectionView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 1.0)];
    sectionView.backgroundColor = [UIColor hexEDEDED];
    
    return sectionView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.prevContentOffset = scrollView.contentOffset;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ((self.dataSource.cachedDatasource.count * self.tableView.rowHeight > self.tableView.frame.size.height || self.tableViewIsFull) && !self.isInEditMode) {
        if (velocity.y > 0 || self.prevContentOffset.y < scrollView.contentOffset.y){
            [UIView animateWithDuration:0.3 animations:^{
                self.addNewElementButton.frame = CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 44);
                
            }];
            [self.searchBar dissmisAnimated:YES];
            [self largeTableViewAnimated:YES];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
            self.addNewElementButton.frame = CGRectMake(0.0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
            }];

            [self.searchBar presentAnimated:YES];
            [self smallTableViewAnimated:YES];
        }
    }
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShowNotification:(NSNotification *)notif {
    // Set the table insets to be the keyboard height
    CGRect keyboardRect = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = keyboardRect.size.height;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) && ([[[UIDevice currentDevice] systemVersion] compare:@"8.0"] == NSOrderedAscending)) {
        height = keyboardRect.size.width;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat bottom = height;
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, bottom, 0.0);
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notif {
    // reset the table insets
    [UIView animateWithDuration:0.25 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    }];
}

#pragma mark - Action sheet methods

- (void)didSelectAddNewElementButton {
    self.dataSource.didSelectAddNewElement(self.addNewElementButton);
}

#pragma mark - UIBar buttons

- (void)addRightNavigationBarItems {
    if (self.rightNavigationBarView) {
        [self setNavigationBarRightCustomView:self.rightNavigationBarView];
    } else {
        UIView *buttonsView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.editButton.frame) + CGRectGetWidth(self.sortButton.frame), 30.0)];
        [buttonsView addSubview:self.editButton];
        [buttonsView addSubview:self.sortButton];
        self.sortButton.frame = CGRectMake(CGRectGetMaxX(self.editButton.frame), CGRectGetMinY(self.editButton.frame), CGRectGetWidth(self.editButton.frame), CGRectGetHeight(self.editButton.frame));
        [self setNavigationBarRightCustomView:buttonsView];
    }
}

- (void)setRightNavigationBarView:(UIView *)rightNavigationBarView {
    _rightNavigationBarView = rightNavigationBarView;
    [self addRightNavigationBarItems];
}

- (void)setLeftNavigationBarView:(UIView *)leftNavigationBarView {
    _leftNavigationBarView = leftNavigationBarView;
    [self setNavigationBarLeftCustomView:leftNavigationBarView];
}

- (UIButton *)editButton {
    if (!_editButton) {
        UIImage *image = [UIImage imageNamed:@"select_icon"];
        UIImage *bkimage = [UIImage imageNamed:@"button_normal_inact"];
        UIImage *hbkimage = [UIImage imageNamed:@"button_normal_act"];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 30.0)];
        [button setImage:image forState:UIControlStateNormal];
        [button setBackgroundImage:bkimage forState:UIControlStateNormal];
        [button setBackgroundImage:hbkimage forState:UIControlStateHighlighted];
        [button setBackgroundImage:hbkimage forState:UIControlStateSelected];
        [button setBackgroundImage:hbkimage forState:UIControlStateHighlighted | UIControlStateSelected];
        
        [button addTarget:self action:@selector(didTapEditBarButton:) forControlEvents:UIControlEventTouchUpInside];
        button.accessibilityIdentifier = @"SKOneBoxEditModeBarButtonItem";
        
        _editButton = button;
    }
    
    return _editButton;
}

- (UIButton *)sortButton {
    if (!_sortButton) {
        UIImage *image = [UIImage imageNamed:@"icon_sort"];
        UIImage *bkimage = [UIImage imageNamed:@"button_normal_inact"];
        UIImage *hbkimage = [UIImage imageNamed:@"button_normal_act"];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 30.0)];
        [button setImage:image forState:UIControlStateNormal];
        [button setBackgroundImage:bkimage forState:UIControlStateNormal];
        [button setBackgroundImage:hbkimage forState:UIControlStateHighlighted];
        [button setBackgroundImage:hbkimage forState:UIControlStateSelected];
        [button setBackgroundImage:hbkimage forState:UIControlStateHighlighted | UIControlStateSelected];
        
        [button addTarget:self action:@selector(didTapSortButton:) forControlEvents:UIControlEventTouchUpInside];
        button.accessibilityIdentifier = @"SKOneBoxSortBarButtonItem";

        _sortButton = button;
    }
    
    return _sortButton;
}

- (UIButton *)deleteSelectedButton {
    if (!_deleteSelectedButton) {
        _deleteSelectedButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 44)];
        [_deleteSelectedButton setTitle:SKOneBoxLocalizedString(@"delete_button_title_key", nil) forState:UIControlStateNormal];
        _deleteSelectedButton.backgroundColor = [UIColor hexFF5649];
        [_deleteSelectedButton addTarget:self action:@selector(didTapDeleteButton) forControlEvents:UIControlEventTouchUpInside];
        _deleteSelectedButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:18.0];
        _deleteSelectedButton.titleLabel.textColor = [UIColor hex3A3A3A];
    }
    
    return _deleteSelectedButton;
}

- (UIButton *)selectAllButton {
    if (!_selectAllButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 90.0, 30.0)];
        [button setTitle:SKOneBoxLocalizedString(@"select_all_button_title_key", nil) forState:UIControlStateNormal];
        [button setTitle:SKOneBoxLocalizedString(@"deselect_all_button_title_key", nil) forState:UIControlStateSelected];
        [button addTarget:self action:@selector(didTapSelectAllButton:) forControlEvents:UIControlEventTouchUpInside];
        button.accessibilityIdentifier = @"SKOneBoxSelectAllBarButtonItem";
        [button setTitleColor:[UIColor hex0080FF] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont fontWithName:@"Avenir" size:16]];
        _selectAllButton = button;
    }
    
    return _selectAllButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 80.0, 30.0)];
        [button setTitle:SKOneBoxLocalizedString(@"cancel_button_title_key", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didTapCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        button.accessibilityIdentifier = @"SKOneBoxCancelBarButtonItem";
        [button setTitleColor:[UIColor hex0080FF] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont fontWithName:@"Avenir" size:16]];
        _cancelButton = button;
    }
    
    return _cancelButton;
}

- (UIButton *)setupAddNewElementButton {
    UIButton *presenter = [[UIButton alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];

    [presenter addTarget:self action:@selector(didSelectAddNewElementButton) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat margin = 15.0f;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(margin, 0, CGRectGetWidth(presenter.frame)- margin, CGRectGetHeight(presenter.frame))];
    title.font = [UIFont fontWithName:@"Avenir" size:18.0];
    title.textColor = [UIColor hex3A3A3A];
    title.text = SKOneBoxLocalizedString(@"add_new_favorite_btn_title_key", nil);
    title.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [presenter addSubview:title];
    
    UIImage *addIcon = [UIImage imageNamed:@"icon_add"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:addIcon];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.frame = CGRectMake(presenter.frame.size.width - addIcon.size.width - margin, 0, addIcon.size.width, title.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    imageView.contentMode = UIViewContentModeCenter;
    [presenter addSubview:imageView];
    
    presenter.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    return presenter;
}

- (void)setNavigationBarLeftCustomView:(UIView *)view {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
    
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem, buttonItem]];
}


- (void)setNavigationBarRightCustomView:(UIView *)view {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
    
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButtonItem.width = -11.0;
    [self.navigationItem setRightBarButtonItems:@[spaceButtonItem, buttonItem]];
}

#pragma mark - UIViews

- (void)addSearchBar {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
    UIImage *closeImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_clear_grey" ofType:@"png"]];
    UIImage *searchImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"searchbar_icon_magnifier" ofType:@"png"]];
    
    self.searchBar = [[SKOneBoxSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.frame), kOneBoxSearchBarHeight) normalClearImage:closeImage highlightedClearImage:closeImage inactiveSearchClearImage:closeImage searchImage:searchImage];
    [self.searchBar setSearchBarTextColor:[UIColor hex3A3A3A]];
    self.searchBar.backgroundColor = [UIColor hexC9C9C9];
    [self.searchBar updateSearchBarStyle:NO];
    self.searchBar.placeHolder = [[NSAttributedString alloc] initWithString:self.dataSource.searchPlaceholder attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Avenir-Roman" size:13],
                                                                                                   NSForegroundColorAttributeName : [UIColor hex898989]}];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.shouldShowSearchDot = NO;
    self.searchBar.delegate = self;
    self.searchBar.searchBarFont = [UIFont fontWithName:@"Avenir-Roman" size:13];
    [self.searchBar updateSearchBarStyle:YES];
    [self.searchBar presentAnimated:NO];
    
    [self.tableView setTableHeaderView:self.searchBar];
    
    [self.searchBar updateTextFieldInsetText:CGPointMake(40, 0)];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *searchText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self.dataSource filterSearch:searchText];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self.dataSource filterSearch:textField.text];
    [self.searchBar updateClearButton:NO];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.dataSource filterSearch:textField.text];
    
    return YES;
}

- (void)addNoResultsLabel {
    if (!_noResultsLabel) {
        _noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0, CGRectGetWidth(self.view.frame)-20, 80.0)];
        _noResultsLabel.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
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

- (void)removeNoResultsLabel {
    [_noResultsLabel removeFromSuperview];
    _noResultsLabel = nil;
}

#pragma mark - Animations

- (void)smallTableViewAnimated:(BOOL)animated {
    [UIView animateWithDuration:animated?0.4:0 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        self.tableView.frame = ({
            CGRect frame = self.view.frame;
            frame.origin.y = 0;
            frame.size.height = self.view.frame.size.height - self.addNewElementButton.frame.size.height;
            frame;
        });
    } completion:^(BOOL finished) {
        self.tableViewIsFull = NO;
    }];
}

- (void)largeTableViewAnimated:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.4 : 0 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        self.tableView.frame = ({
            CGRect frame = self.view.frame;
            frame.origin.y = 0;
            frame.size.height = self.view.frame.size.height;
            frame;
        });
    } completion:^(BOOL finished) {
        self.tableViewIsFull = YES;
    }];
}

@end
