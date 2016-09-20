//
//  HYNSwipeTableCell.h
//  ForeverMapNGX
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SKOneBoxSwipeTableCell;

/** 
 * This is a convenience class to create HYNSwipeTableCell buttons
 * Using this class is optional because HYNSwipeTableCell is button agnostic and can use any UIView for that purpose
 */
@interface SKOneBoxSwipeButton : UIButton

/**
 * Convenience block callback for developers lazy to implement the HYNSwipeTableCellDelegate.
 * @return Return YES to autohide the swipe view
 */
typedef BOOL(^HYNSwipeButtonSelectionBlock)(SKOneBoxSwipeTableCell * sender);

@property (nonatomic, strong) HYNSwipeButtonSelectionBlock selectionBlock;

/** A width for the expanded buttons. Defaults to 0, which means sizeToFit will be called. */
@property (nonatomic, assign) CGFloat buttonWidth;

+ (instancetype)buttonWithIcon:(UIImage *)icon backgroundColor:(UIColor *)color;
+ (instancetype)buttonWithIcon:(UIImage *)icon backgroundColor:(UIColor *)color selectionBlock:(HYNSwipeButtonSelectionBlock)callback;
+ (instancetype)buttonWithTitle:(NSString *)title icon:(UIImage *)icon backgroundColor:(UIColor *)color;

- (void)setPadding:(CGFloat)padding;
- (void)setEdgeInsets:(UIEdgeInsets)insets;
- (void)centerIconOverText;

@end