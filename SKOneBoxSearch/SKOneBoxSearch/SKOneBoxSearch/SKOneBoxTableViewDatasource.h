//
//  SKOneBoxTableViewDatasource.h
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 24/03/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SKOneBoxTableViewDatasourceProtocol <NSObject>

@optional

-(NSString *)formatDistance:(double)distance; //distance in meters

@end

@interface SKOneBoxTableViewDatasource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSString              *searchString;

@property (atomic, strong) NSArray               *sections;
@property (nonatomic, strong) NSMutableDictionary   *dataSource;

@property (nonatomic, strong) UIImage *searchResultImage;

@property (nonatomic, weak) id<SKOneBoxTableViewDatasourceProtocol> oneBoxDataSource;

@end
