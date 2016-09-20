//
//  SKOneBoxDropdownItem.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 17/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxDropdownItem.h"

@implementation SKOneBoxDropdownItem

+ (SKOneBoxDropdownItem *)dropdownItem {
    SKOneBoxDropdownItem *item = [[self alloc] init];
    
    item.title = @"";
    item.selected = NO;
    
    return item;
}

+ (SKOneBoxDropdownItem *)dropdownItemWithTitle:(NSString *)title {
    SKOneBoxDropdownItem *item = [self dropdownItem];
    item.title = title;
    
    return item;
}

@end
