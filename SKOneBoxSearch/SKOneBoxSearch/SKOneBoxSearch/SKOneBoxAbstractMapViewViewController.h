//
//  SKOneBoxAbstractMapViewViewController.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKOneBoxAbstractMapViewProtocol.h"
#import "SKOneBoxUIConfigurator.h"

@interface SKOneBoxAbstractMapViewViewController : UIViewController

@property (nonatomic, strong) SKOneBoxUIConfigurator *uiConfigurator;

-(id)initWithMapView:(UIView<SKOneBoxAbstractMapViewProtocol> *)mapView;

@end
