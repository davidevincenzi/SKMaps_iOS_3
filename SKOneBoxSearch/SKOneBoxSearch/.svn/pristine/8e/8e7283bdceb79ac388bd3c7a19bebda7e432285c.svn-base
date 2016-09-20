//
//  SKOneBoxUIConfigurator.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxUIConfigurator.h"
#import "UIColor+SKOneBoxColors.h"

@implementation SKOneBoxUIConfigurator

-(id)init {
    self = [super init];
    if (self) {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
        
        _searchBackButtonImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_back_white" ofType:@"png"]];
        _resultsBackButtonImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_back" ofType:@"png"]];
        _resultsSortButtonImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"icon_sort" ofType:@"png"]];
        _leftBarButtonMargins = UIEdgeInsetsMake(0, 0, 0, 0);
        _shouldChangeStatusBarStyle = YES;
    }
    return self;
}

@end
