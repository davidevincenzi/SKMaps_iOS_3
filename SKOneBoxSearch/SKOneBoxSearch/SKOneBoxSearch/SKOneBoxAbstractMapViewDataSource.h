//
//  SKOneBoxAbstractMapViewDataSource.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKOneBoxAbstractMapViewProtocol.h"

@protocol SKOneBoxAbstractMapViewDataSource <NSObject>

-(UIView<SKOneBoxAbstractMapViewProtocol> *)oneBoxMapView;

@optional
//navigation controller on which the map controller should be presented
-(UINavigationController*)navigationControllerForMap;

@end
