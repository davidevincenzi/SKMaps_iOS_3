//
//  SKOneBoxBaseViewController.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxBaseViewController.h"
#import "SKOneBoxSectionView.h"
#import "SKOneBoxTableHeaderView.h"
#import "UIColor+SKOneBoxColors.h"
#import "SKOneBoxLocalizationManager.h"

@interface SKOneBoxBaseViewController ()
@property (nonatomic, assign) CGSize keyboardSize;

@end

@implementation SKOneBoxBaseViewController

- (instancetype)initWithSearchBar:(SKOneBoxSearchBar *)searchBar searchProviders:(NSArray *)searchProviders {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
    self = [super initWithNibName:@"SKOneBoxBaseViewController" bundle:bundle];
    
    if (self) {
        
        self.previousOneBoxControllerStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backButtonPressedResults:)
                                                     name:@"oneBoxSearchResultsBackPressed"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLanguage) name:kSKOneBoxLanguageDidChangeNotification object:nil];
        
        _searchBar = searchBar;
        _searchBar.delegate = self;
        _searchProviders = searchProviders;
        _topInsetTableView = 0.0f;
    }
    
    return self;
}

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor hexF3F3F3]];
    [self.tableView setBackgroundColor:[UIColor hexF3F3F3]];
    self.tableView.delaysContentTouches = NO;
    
    SKOneBoxTableViewDatasource *tableDataSource = [[SKOneBoxTableViewDatasource alloc] init];
    self.tableViewDataSource = tableDataSource;
    
    SKOneBoxTableViewDelegate *tableViewDelegate = [[SKOneBoxTableViewDelegate alloc] init];
    self.tableViewDelegate = tableViewDelegate;
    __weak typeof(self) welf = self;
    self.tableViewDelegate.dismissKeyboardBlock = ^{
        [welf.searchBar dismissKeyboard];
    };
    [self.tableView setSeparatorColor:[UIColor hexEDEDED]];
    
    [self.tableView reloadData];
    
    [self updateTableViewInsets:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addBackButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.titleView = nil;
}

#pragma mark - Public

- (void)updateLanguage {

}

- (void)updateSearchBar {
    
}

- (void)clearPreviousSearch {
    if (![[self.navigationController topViewController] isEqual:self]) {
        //not first controller, we are in results, we need to pop to root.
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    self.searchBar.textField.text = nil;
    [self.searchBar updateClearButton:YES];
}

-(void)dismissViewController {
    if ([self.delegate respondsToSelector:@selector(willDismissOneBoxViewController:)]) {
        [self.delegate willDismissOneBoxViewController:self];
    }
    
    if (!self.presentingViewController) {
        if (self.dismissCompletionBlock) {
            self.dismissCompletionBlock();
        }
        if ([self.delegate respondsToSelector:@selector(didDismissOneBoxViewController:)]) {
            [self.delegate didDismissOneBoxViewController:self];
        }
    }
    else {
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.dismissCompletionBlock) {
                self.dismissCompletionBlock();
            }
            if ([self.delegate respondsToSelector:@selector(didDismissOneBoxViewController:)]) {
                [self.delegate didDismissOneBoxViewController:self];
            }
        }];
    }
}

#pragma mark - Properties

-(void)setTopInsetTableView:(CGFloat)topInsetTableView {
    _topInsetTableView = topInsetTableView;
    [self updateTableViewInsets:[self.searchBar.textField isFirstResponder]];
}

- (void)setTableViewDataSource:(id<UITableViewDataSource>)tableViewDataSource {
    _tableViewDataSource = tableViewDataSource;
    self.tableView.dataSource = tableViewDataSource;
}

- (void)setTableViewDelegate:(id<UITableViewDelegate>)tableViewDelegate {
    _tableViewDelegate = tableViewDelegate;
    self.tableView.delegate = tableViewDelegate;
}

#pragma mark - SKOneBoxSearchBarDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (![[self.navigationController topViewController] isEqual:self]) {
        //not first controller, we are in results, we need to pop to root.
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    if ([self.delegate respondsToSelector:@selector(oneBoxViewController:searchBarDidClear:)]) {
        [self.delegate oneBoxViewController:self searchBarDidClear:self.searchBar];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (![self.navigationController presentingViewController]) {
        if ([self.delegate respondsToSelector:@selector(oneBoxViewController:searchBarTextDidBeginEditing:)]) {
            [self.delegate oneBoxViewController:self searchBarTextDidBeginEditing:self.searchBar];
        }
    }

    return YES;
}

#pragma mark - SKOneBoxTableViewDatasourceProtocol

-(NSString*)formatDistance:(double)distance {
    if ([self.delegate respondsToSelector:@selector(oneBoxViewController:formatDistance:)]) {
        return [self.delegate oneBoxViewController:self formatDistance:distance];
    }
    return nil;
}

#pragma mark - Private

- (void)addBackButton {
    UIImage *backImage = [self.uiConfigurator searchBackButtonImage];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    [button setImage:backImage forState:UIControlStateNormal];
    button.accessibilityIdentifier = @"SKOneBoxBackButton";
    [button addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)backButtonPressed {
    self.navigationItem.titleView = nil;
    [self.searchBar updateSearchDot:NO];
    [self.searchBar updateClearButton:YES];
    [self dismissViewController];
}

- (void)updateTableViewInsets:(BOOL)keyboardPresent {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
 
    contentInsets = UIEdgeInsetsMake(self.topInsetTableView, 0.0, keyboardPresent ? (self.keyboardSize.height) : 0.0, 0.0);
    
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}


#pragma mark - Notifications

- (void)backButtonPressedResults:(NSNotification *)notification {
    [self.searchBar.textField setText:nil];
    [self.searchBar updateClearButton:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.keyboardSize = keyboardSize;
    [self updateTableViewInsets:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.keyboardSize = CGSizeZero;
    [self updateTableViewInsets:NO];
}

#pragma mark - Other

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateTableViewInsets:[self.searchBar.textField isFirstResponder]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
