//
//  SKOneBoxAbstractMapViewViewController.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxAbstractMapViewViewController.h"

@interface SKOneBoxAbstractMapViewViewController ()
@property (nonatomic, strong) UIView<SKOneBoxAbstractMapViewProtocol> *mapView;
@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;

@end

@implementation SKOneBoxAbstractMapViewViewController

#pragma mark - Init

-(id)initWithMapView:(UIView<SKOneBoxAbstractMapViewProtocol> *)mapView {
    self = [super init];
    if (self) {
        _mapView = mapView;
    }
    return self;
}

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView.frame = self.view.frame;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.mapView];
    
    self.previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    if (self.uiConfigurator.shouldChangeStatusBarStyle) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    }
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    [self addBackButton];
}

#pragma mark - Private

- (void)addBackButton {
    UIImage *backImage = nil;
    backImage = [self.uiConfigurator resultsBackButtonImage];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    [button setImage:backImage forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    button.accessibilityIdentifier = @"SKOneBoxResultsBackButton";
}

- (void)backButtonPressed {
    if (self.uiConfigurator.shouldChangeStatusBarStyle) {
        [[UIApplication sharedApplication] setStatusBarStyle:self.previousStatusBarStyle animated:NO];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
