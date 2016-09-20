//
//  SKOneBoxSearchBar.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 25/03/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxSearchBar.h"
#import "UIColor+SKOneBoxColors.h"

static int kSearchDotWidth = 8;

@interface SKOneBoxSearchBar () <UITextFieldDelegate>

@property (nonatomic, strong) SKOneBoxUITextField *textField;

@property (nonatomic, strong) UIImage *normalClearImage;
@property (nonatomic, strong) UIImage *highlightedClearImage;

@property (nonatomic, strong) UIImage *inactiveSearchClearImage;

@property (nonatomic, strong) UIImageView *dotImageView;

@property (nonatomic, strong) UIButton *clearButton;

@property (nonatomic, assign) BOOL visible;

@end

@implementation SKOneBoxSearchBar

- (instancetype)initWithFrame:(CGRect)frame normalClearImage:(UIImage *)normalClearImage highlightedClearImage:(UIImage *)highlightedClearImage {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.accessibilityIdentifier = @"SKOneBoxSearchBarMain";
        _dotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height/2 - kSearchDotWidth/2, kSearchDotWidth, kSearchDotWidth)];
        _dotImageView.layer.cornerRadius = kSearchDotWidth/2;
        [self addSubview:_dotImageView];
        _searchBarTextColor = [UIColor whiteColor];
        _shouldHideClearButtonWhileNotEditing = NO;
        
        _textField = [[SKOneBoxUITextField alloc] initWithFrame:CGRectMake(2*kSearchDotWidth, 0, CGRectGetWidth(frame)-kSearchDotWidth-5, CGRectGetHeight(frame))];
        _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textField.backgroundColor = [UIColor clearColor];
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.font = [UIFont fontWithName:@"Avenir-Roman" size:16];
        _textField.textColor = self.searchBarTextColor;
        _textField.clearButtonMode = UITextFieldViewModeNever;
        [_textField setTintColor:[UIColor hexEDEDED]];
        _textField.delegate = self;
        _textField.accessibilityIdentifier = @"SKOneBoxSearchBarTextField";
        [_textField resignFirstResponder];

        self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.clearButton setImage:highlightedClearImage forState:UIControlStateNormal];
        [self.clearButton setImage:normalClearImage forState:UIControlStateDisabled];
        
        if (normalClearImage) {
            [self.clearButton setFrame:CGRectMake(0,0, normalClearImage.size.width, normalClearImage.size.height)];
        } else {
            [self.clearButton setFrame:CGRectMake(0,0, highlightedClearImage.size.width, highlightedClearImage.size.height)];
        }
        
        [self.clearButton addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
        [self.clearButton setEnabled:NO];
        self.clearButton.accessibilityIdentifier = @"SKOneBoxSearchBarClearButton";
        
        _textField.rightViewMode = UITextFieldViewModeAlways;
        [_textField setRightView:self.clearButton];
        
        self.normalClearImage = normalClearImage;
        self.highlightedClearImage = highlightedClearImage;
        
        [self updateSearchDot:NO];
        [self updateClearButton:YES];
        [self addSubview:_textField];
        [self addConstraintsForDot];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame normalClearImage:(UIImage *)normalClearImage highlightedClearImage:(UIImage *)highlightedClearImage searchImage:(UIImage*)searchImage {
    self = [self initWithFrame:frame normalClearImage:normalClearImage highlightedClearImage:highlightedClearImage];
    if (self) {
        //set left view mode, search image
        UIImageView *imageView = [[UIImageView alloc] initWithImage:searchImage];
        imageView.backgroundColor = [UIColor clearColor];
        
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.leftView = imageView;
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame normalClearImage:(UIImage *)normalClear highlightedClearImage:(UIImage *)highlightedClear inactiveSearchClearImage:(UIImage *)inactiveClear searchImage:(UIImage*)searchImage {
    self = [self initWithFrame:frame normalClearImage:normalClear highlightedClearImage:highlightedClear searchImage:searchImage];
    if (self) {
        //set left view mode, search image
        [self.clearButton setImage:highlightedClear forState:UIControlStateNormal];
        [self.clearButton setImage:normalClear forState:UIControlStateDisabled];
        [self.clearButton setImage:inactiveClear forState:UIControlStateSelected];
    }
    
    return self;
}

- (void)awakeFromNib {
    
    CGRect frame = self.frame;
    self.accessibilityIdentifier = @"SKOneBoxSearchBarMain";
    _dotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height/2 - kSearchDotWidth/2, kSearchDotWidth, kSearchDotWidth)];
    _dotImageView.layer.cornerRadius = kSearchDotWidth/2;
    [self addSubview:_dotImageView];
    
    _textField = [[SKOneBoxUITextField alloc] initWithFrame:CGRectMake(2*kSearchDotWidth, 0, CGRectGetWidth(frame)-kSearchDotWidth-5, CGRectGetHeight(frame))];
    _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textField.backgroundColor = [UIColor clearColor];
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.returnKeyType = UIReturnKeySearch;
    _textField.font = [UIFont fontWithName:@"Avenir-Roman" size:16];
    _textField.textColor = self.searchBarTextColor;
    _textField.clearButtonMode = UITextFieldViewModeNever;
    [_textField setTintColor:[UIColor hexEDEDED]];
    _textField.delegate = self;
    _textField.accessibilityIdentifier = @"SKOneBoxSearchBarTextField";
    [_textField resignFirstResponder];
    
    self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.clearButton setImage:self.highlightedClearImage forState:UIControlStateNormal];
    [self.clearButton setImage:self.normalClearImage forState:UIControlStateDisabled];
    [self.clearButton setFrame:CGRectMake(0,0, self.normalClearImage.size.width, self.normalClearImage.size.height)];
    [self.clearButton addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearButton setEnabled:NO];
    self.clearButton.accessibilityIdentifier = @"SKOneBoxSearchBarClearButton";
    
    _textField.rightViewMode = UITextFieldViewModeAlways;
    [_textField setRightView:self.clearButton];
    
    [self updateSearchDot:NO];
    [self updateClearButton:YES];
    [self addSubview:_textField];
    [self addConstraintsForDot];
}

- (void)configureSearchBarWithHighlightedClearImage:(UIImage *)image normalClearImage:(UIImage *)normalImage andSearchImage:(UIImage *)searchImage {
    self.highlightedClearImage = image;
    self.normalClearImage = normalImage;
    
    [self.clearButton setImage:self.highlightedClearImage forState:UIControlStateNormal];
    [self.clearButton setImage:self.normalClearImage forState:UIControlStateDisabled];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:searchImage];
    imageView.backgroundColor = [UIColor clearColor];
    
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.leftView = imageView;
}

#pragma mark - Public

- (void)setClearImage:(UIImage*)image forState:(UIControlState)controlState {
    [self.clearButton setImage:image forState:controlState];
}

-(void)setSearchBarFont:(UIFont *)searchBarFont {
    _searchBarFont = searchBarFont;
    self.textField.font = searchBarFont;
}

- (void)updateSearchDot:(BOOL)isActive {
    if (isActive) {
        [_dotImageView setBackgroundColor:[UIColor hexFF5649]];
    } else {
        [_dotImageView setBackgroundColor:[UIColor hexC3C3C3FF]];
    }
}

- (void)updateClearButton:(BOOL)isActive {
    if (isActive) {
        if (self.shouldHideClearButtonWhileNotEditing) {
            self.clearButton.hidden = (self.textField.text && ![self.textField.text isEqualToString:@""]);
        } else {
            [self.clearButton setEnabled:(self.textField.text && ![self.textField.text isEqualToString:@""])];
            [self.clearButton setSelected:NO];
        }
    } else {
        if (self.shouldHideClearButtonWhileNotEditing) {
            self.clearButton.hidden = YES;
        } else {
            [self.clearButton setSelected:YES];
            [self.clearButton setEnabled:YES];
        }
    }
}

- (void)updateSearchBarStyle:(BOOL)isActive {
    if (!isActive) {
        self.textField.textColor = [UIColor hex3A3A3A];
        [_textField setTintColor:[UIColor hex0080FF]];
       
    } else {
        self.textField.textColor = self.searchBarTextColor;
        [_textField setTintColor:[UIColor hexEDEDED]];
    }

}

- (void)presentAnimated:(BOOL)animated {
    if (self.visible) {
        return;
    }
    
    self.frame = ({
        CGRect frame = self.frame;
        frame.origin.y = -self.frame.size.height;
        frame;
    });
    
    self.alpha = 0.0;
    double duration = 0.2;
    if (!animated) {
        duration = 0.0;
    }
    
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView animateWithDuration:2*duration animations:^{
        self.frame = CGRectOffset(self.frame, 0.0, self.frame.size.height);
    } completion:^(BOOL finished) {
        self.visible = YES;
    }];
}

- (void)dissmisAnimated:(BOOL)animated {
    if (!self.visible) {
        return;
    }
    [self dismissKeyboard];
    
    double duration = 0.2;
    if (!animated) {
        duration = 0.0;
    }
    
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView animateWithDuration:2*duration animations:^{
        self.frame = CGRectOffset(self.frame, 0, -self.frame.size.height);
    } completion:^(BOOL finished) {
        self.visible = NO;
    }];
}

- (void)dismissKeyboard {
    [self.textField resignFirstResponder];
}

- (void)showKeyboard {
    [self.textField becomeFirstResponder];
}

- (void)updateTextFieldInsetText:(CGPoint)inset {
    [self.textField setInsetText:inset];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL returnValue = YES;
    
    if ([self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        returnValue = [self.delegate textFieldShouldBeginEditing:textField];
    }

    return returnValue;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.delegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    BOOL returnValue = YES;
    if ([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        returnValue = [self.delegate textFieldShouldEndEditing:textField];
    }
  
    return returnValue;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.shouldHideClearButtonWhileNotEditing) {
        self.clearButton.hidden = YES;
    }

    if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.delegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *searchText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (searchText.length == 0) {
        if (self.shouldHideClearButtonWhileNotEditing) {
            self.clearButton.hidden = YES;
        } else {
            [self.clearButton setEnabled:NO];
        }
    } else {
        [self.clearButton setEnabled:YES];
        
        if (self.shouldHideClearButtonWhileNotEditing) {
            self.clearButton.hidden = NO;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
   
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [self.delegate textFieldShouldClear:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [self.delegate textFieldShouldReturn:textField];
    }
    
    return YES;
}

#pragma mark - Private

- (void)clearTextField:(UIButton*)button {
    if (self.shouldHideClearButtonWhileNotEditing) {
        self.clearButton.hidden = YES;
    } else {
        [self.clearButton setEnabled:NO];
    }
    _textField.text = @"";
    [_textField.delegate textFieldShouldClear:_textField];
}

- (void)addConstraintsForDot {
    self.dotImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.dotImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.dotImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:kSearchDotWidth]];
    [self.dotImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.dotImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:kSearchDotWidth]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dotImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    NSArray *positionHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[dot]" options:0 metrics:nil views:@{@"dot":self.dotImageView}];
    [self addConstraints:positionHorizontalConstraints];
    
    [self layoutSubviews];
}

#pragma mark - Override

-(void)setShouldShowSearchDot:(BOOL)shouldShowSearchDot {
    _shouldShowSearchDot = shouldShowSearchDot;
    self.dotImageView.hidden = !shouldShowSearchDot;
    
    if (shouldShowSearchDot) {
        [_textField setFrame:CGRectMake(2*kSearchDotWidth, 0, CGRectGetWidth(self.frame)-kSearchDotWidth, CGRectGetHeight(self.frame))];
    }
    else {
        CGFloat margin = 12.0f;
        [_textField setFrame:CGRectMake(margin, 0, CGRectGetWidth(self.frame)-(2*margin), CGRectGetHeight(self.frame))];
    }
    
}

-(void)setPlaceHolder:(NSAttributedString *)placeHolder {
    _textField.attributedPlaceholder = placeHolder;
}

- (void)setSearchBarTextColor:(UIColor *)searchBarTextColor {
    _searchBarTextColor = searchBarTextColor;
    [self updateSearchBarStyle:YES];
}

- (void)setShouldHideClearButtonWhileNotEditing:(BOOL)shouldHideClearButtonWhileNotEditing {
    _shouldHideClearButtonWhileNotEditing = shouldHideClearButtonWhileNotEditing;
    self.clearButton.hidden = shouldHideClearButtonWhileNotEditing;
}

@end
