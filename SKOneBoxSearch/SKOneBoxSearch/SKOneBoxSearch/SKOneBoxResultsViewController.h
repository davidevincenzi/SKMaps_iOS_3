//
//  SKOneBoxResultsViewController.h
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 03/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxViewController.h"

@class SKOneBoxSearchService;

@interface SKOneBoxResultsViewController : SKOneBoxBaseViewController

@property (nonatomic, strong) void (^selectionBlock)(SKOneBoxSearchResult *, NSArray *);
@property (nonatomic, assign) BOOL shouldShowFilteringFunction;
@property (nonatomic, assign) BOOL shouldShowLocationSelection;

- (instancetype)initWithSearchProviders:(NSArray *)searchProviders searchService:(SKOneBoxSearchService *)searchService highlightSearchTerm:(NSString*)highlightSearchTerm;

@end
