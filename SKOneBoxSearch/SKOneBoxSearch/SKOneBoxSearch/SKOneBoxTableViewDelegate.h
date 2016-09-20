//
//  SKOneBoxTableViewDelegate.h
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 24/03/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SKOSearchLib/SKSearchProviderProtocol.h>

@interface SKOneBoxTableViewDelegate : NSObject <UITableViewDelegate>
{
    NSArray *sections;
}

@property (atomic, strong) NSArray               *sections;
@property (nonatomic, strong) NSMutableDictionary   *dataSource;
@property (nonatomic, assign) BOOL                  shouldShowSectionHeaders;

@property (nonatomic, strong) void (^seeAllBlock)(id<SKSearchProviderProtocol>);
@property (nonatomic, strong) void (^requestNextPageBlock)(id<SKSearchProviderProtocol>);
@property (nonatomic, strong) void (^selectionBlock)(SKOneBoxSearchResult *, NSArray *);
@property (nonatomic, strong) void (^dismissKeyboardBlock)();
@property (nonatomic, strong) void (^didScrollBlock)(CGPoint offset);
@property (nonatomic, strong) void (^scrollViewDidEndDragging)();

- (void)startAnimatingSectionViewForProvider:(id<SKSearchProviderProtocol>)provider;
- (void)stopAnimatingSectionViewForProvider:(id<SKSearchProviderProtocol>)provider;

@end
