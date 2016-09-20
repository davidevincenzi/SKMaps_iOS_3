//
//  HYNSwipeTableCell.m
//  ForeverMapNGX
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxSwipeButton.h"

@class SKOneBoxSwipeTableCell;

@implementation SKOneBoxSwipeButton

+ (instancetype)buttonWithIcon:(UIImage *)icon backgroundColor:(UIColor *)color {
    return [self buttonWithTitle:nil icon:icon backgroundColor:color selectionBlock:nil];
}

+ (instancetype)buttonWithIcon:(UIImage *)icon backgroundColor:(UIColor *)color selectionBlock:(HYNSwipeButtonSelectionBlock)callback {
    return [self buttonWithTitle:nil icon:icon backgroundColor:color selectionBlock:callback];
}

+ (instancetype)buttonWithTitle:(NSString *)title icon:(UIImage *)icon backgroundColor:(UIColor *)color {
    return [self buttonWithTitle:title icon:icon backgroundColor:color selectionBlock:nil];
}

+ (instancetype)buttonWithTitle:(NSString *)title icon:(UIImage *)icon backgroundColor:(UIColor *)color selectionBlock:(HYNSwipeButtonSelectionBlock)selectionBlock {
    return [self buttonWithTitle:title icon:icon backgroundColor:color padding:10 selectionBlock:selectionBlock];
}

+ (instancetype)buttonWithTitle:(NSString *)title icon:(UIImage *)icon backgroundColor:(UIColor *)color padding:(NSInteger)padding selectionBlock:(HYNSwipeButtonSelectionBlock)selectionBlock {
    return [self buttonWithTitle:title icon:icon backgroundColor:color insets:UIEdgeInsetsMake(0, padding, 0, padding) selectionBlock:selectionBlock];
}

+ (instancetype)buttonWithTitle:(NSString *) title icon:(UIImage*) icon backgroundColor:(UIColor *)color insets:(UIEdgeInsets)insets selectionBlock:(HYNSwipeButtonSelectionBlock)selectionBlock {
    SKOneBoxSwipeButton * button = [self buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setImage:icon forState:UIControlStateNormal];
    button.selectionBlock = selectionBlock;
    [button setEdgeInsets:insets];
    return button;
}

- (BOOL)callSwipeConvenienceCallback:(SKOneBoxSwipeTableCell *)sender {
    if (_selectionBlock) {
        return _selectionBlock(sender);
    }
    
    return NO;
}

- (void)centerIconOverText {
	const CGFloat spacing = 3.0;
	
    CGSize size = self.imageView.image.size;
	self.titleEdgeInsets = UIEdgeInsetsMake(0.0, -size.width, -(size.height + spacing), 0.0);
    
	size = [self.titleLabel.text sizeWithAttributes:@{ NSFontAttributeName: self.titleLabel.font }];
	self.imageEdgeInsets = UIEdgeInsetsMake(-(size.height + spacing), 0.0, 0.0, -size.width);
}

- (void)setPadding:(CGFloat) padding {
    self.contentEdgeInsets = UIEdgeInsetsMake(0, padding, 0, padding);
    [self sizeToFit];
}

- (void)setButtonWidth:(CGFloat)buttonWidth {
    _buttonWidth = buttonWidth;
    if (_buttonWidth > 0) {
        CGRect frame = self.frame;
        frame.size.width = _buttonWidth;
        self.frame = frame;
    } else {
        [self sizeToFit];
    }
}

- (void)setEdgeInsets:(UIEdgeInsets)insets {
    self.contentEdgeInsets = insets;
    [self sizeToFit];
}

@end
