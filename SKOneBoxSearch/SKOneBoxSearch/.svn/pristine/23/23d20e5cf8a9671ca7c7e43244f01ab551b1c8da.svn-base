//
//  SKOneBoxDropdownController.h
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 17/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKOneBoxDropdownItem.h"

@interface SKOneBoxDropdownController : UITableViewController {
    BOOL _visible;
}

@property (nonatomic, strong, readonly) NSArray *items;
@property (nonatomic, assign, readonly) NSInteger indexForCurrentSelectedItem;

@property (nonatomic, weak, readonly) UIViewController *parentController;
@property (nonatomic, strong, readonly) UIView *containerView;

@property (nonatomic, assign) BOOL singleSelection;
@property (nonatomic, assign, readonly) BOOL visible;

- (void)presentInViewController:(UIViewController *)viewController;
- (void)dismiss;

// Manage items
- (void)addDropdownItem:(SKOneBoxDropdownItem *)item;
- (void)insertDropdownItem:(SKOneBoxDropdownItem *)item atIndex:(NSUInteger)index;
- (void)removeDropdownItem:(SKOneBoxDropdownItem *)item;
- (void)removeDropdownItemAtIndex:(NSUInteger)index;

@end
