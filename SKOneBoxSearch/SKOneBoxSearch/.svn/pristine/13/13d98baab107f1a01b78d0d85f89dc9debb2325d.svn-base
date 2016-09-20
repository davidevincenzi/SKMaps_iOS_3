//
//  SKOneBoxSearchBar.h
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 25/03/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKOneBoxUITextField.h"

@class SKOneBoxSearchBar;

@interface SKOneBoxSearchBar : UIView

@property (nonatomic, strong,readonly) SKOneBoxUITextField  *textField;
@property(nonatomic, weak) id<UITextFieldDelegate>  delegate;             // default is nil. weak reference
@property(nonatomic, assign) BOOL                   shouldShowSearchDot;
@property(nonatomic, strong) NSAttributedString     *placeHolder;
@property (nonatomic,strong) UIFont                 *searchBarFont;
@property (nonatomic, strong) UIColor               *searchBarTextColor;
@property (nonatomic, assign) BOOL                  shouldHideClearButtonWhileNotEditing;

- (instancetype)initWithFrame:(CGRect)frame normalClearImage:(UIImage *)normalClear highlightedClearImage:(UIImage *)highlightedClear;
- (instancetype)initWithFrame:(CGRect)frame normalClearImage:(UIImage *)normalClear highlightedClearImage:(UIImage *)highlightedClear searchImage:(UIImage*)searchImage;
- (instancetype)initWithFrame:(CGRect)frame normalClearImage:(UIImage *)normalClear highlightedClearImage:(UIImage *)highlightedClear inactiveSearchClearImage:(UIImage *)inactiveClear searchImage:(UIImage *)searchImage;

- (void)configureSearchBarWithHighlightedClearImage:(UIImage *)image normalClearImage:(UIImage *)normalImage andSearchImage:(UIImage *)searchImage;


- (void)updateSearchDot:(BOOL)isActive;
- (void)updateClearButton:(BOOL)isActive;
- (void)updateSearchBarStyle:(BOOL)isActive;
- (void)setClearImage:(UIImage*)image forState:(UIControlState)controlState;

- (void)presentAnimated:(BOOL)animated;
- (void)dissmisAnimated:(BOOL)animated;

- (void)showKeyboard;
- (void)dismissKeyboard;

- (void)updateTextFieldInsetText:(CGPoint)inset;

@end
