//
//  SKOneBoxDropdownItem.h
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 17/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SKOneBoxDropdownItem;

typedef void(^SKOneBoxDropdownItemSelectionBlock)(SKOneBoxDropdownItem *);

@interface SKOneBoxDropdownItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *activeImage;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, strong) SKOneBoxDropdownItemSelectionBlock selectionBlock;

+ (SKOneBoxDropdownItem *)dropdownItem;
+ (SKOneBoxDropdownItem *)dropdownItemWithTitle:(NSString *)title;

@end
