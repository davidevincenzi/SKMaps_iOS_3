//
//  FMRecentsTableViewCell.m
//  ForeverMapNGX
//
//  Created by Mihai Babici on 2/7/13.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SKOneBoxRecentsTableViewCell.h"
#import "UIColor+SKOneBoxColors.h"
#import <tgmath.h>

const CGFloat kFMRecentsCellHorizMargin         = 0.0;
const CGFloat kFMRecentsCellVertMargin          = 0.0;
const CGFloat kFMRecentsCellInnerSpacing        = 2.0;
const CGFloat kFMRecentsCellDropShadowHeight    = 2.0;
const CGFloat kFMRecentsCellImageSize           = 50.0;
const CGFloat kFMRecentsCellAccessoryViewWidth  = 40.0;
const CGFloat kFMRecentsCellButtonsHeight       = 20.0;

const int kFMRecentsCellMarginColor             = 0xd3d3d3;

static UIFont *mainFont = nil;
static UIFont *detailsFont = nil;
static UIFont *secondDetailsFont = nil;
static UIFont *infoFont = nil;
static UIFont *secondInfoFont = nil;

@interface SKOneBoxRecentsTableViewCell ()

@property (nonatomic, strong) UIView                *containerView;
@property (nonatomic, copy)   void (^mainTextFieldDidStartEditingBlock)(void);
@property (nonatomic, copy)   void (^mainTextFieldDidEndEditingBlock)(NSString *newName);
@property (nonatomic, strong) UIButton              *accessoryButton;

@end

@implementation SKOneBoxRecentsTableViewCell

#pragma mark - Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    
    [self loadFonts];
    
    [self addContainerView];
    [self addMainImageView];
    [self addMainLabel];
    [self addMainTextField];
    [self addDetailLabel];
    [self addInfoLabel];
    [self addAccessoryButtonView];
    [self addAccessoryImageView];
    [self addSeparatorView];
    [self addNavigateImageView];
    [self addVerticalSeparatorView];
    [self addSecondInfoLabel];
    
#ifdef ENABLED_DEBUG
    [self addAutomationDebugLabel];
#endif
    
    return self;
}

#pragma mark - Overriden

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self layoutLabelsAndButtons];
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.mainTextFieldDidStartEditingBlock();
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text && [self isEmptyOrWhiteSpaceString:textField.text]) {
        [textField resignFirstResponder];
        return YES;
    }
    
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.text && [self isEmptyOrWhiteSpaceString:textField.text]) {
        [textField resignFirstResponder];
    } else {
        _mainTextField.text = _mainLabel.text;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _mainTextField.hidden = YES;
    _mainLabel.text = _mainTextField.text;
    _mainLabel.hidden = NO;
    
    self.mainTextFieldDidEndEditingBlock(textField.text);
}

#pragma mark - Public methods

- (void)editMainLabelWithStartBlock:(void (^)(void))startBlock completionBlock:(void (^)(NSString *newName))completionBlock {
    self.mainTextFieldDidStartEditingBlock = startBlock;
    self.mainTextFieldDidEndEditingBlock = completionBlock;
    
    _mainLabel.hidden = YES;
    _mainTextField.hidden = NO;
    _mainTextField.text = _mainLabel.text;

    [_mainTextField becomeFirstResponder];
}

- (void)cellTextFieldResignFirstResponder {
    [_mainTextField resignFirstResponder];
}

#pragma mark - Private methods

- (void)loadFonts {
    if (!mainFont) {
        mainFont = [UIFont fontWithName:@"Avenir" size:16.0];
        detailsFont = [UIFont fontWithName:@"Avenir" size:13.0];
        secondDetailsFont = [UIFont fontWithName:@"Avenir" size:13.0];
        infoFont = [UIFont fontWithName:@"Avenir" size:13.0];
        secondInfoFont = [UIFont fontWithName:@"Avenir" size:12.0];
    }
}

- (void)layoutLabelsAndButtons {
   
    _mainImageView.frame = CGRectMake(0, 0, kFMRecentsCellImageSize, kFMRecentsCellImageSize);
    _mainImageView.center = CGPointMake(_mainImageView.center.x, _containerView.center.y);
    CGFloat mainImageViewMaxX = CGRectGetMaxX(_mainImageView.frame);
    
    CGFloat accessoryViewX = CGRectGetWidth(_containerView.frame) - kFMRecentsCellAccessoryViewWidth;
    
    CGFloat mainLabelWidth = accessoryViewX - mainImageViewMaxX - 2 * kFMRecentsCellInnerSpacing;
    
    NSString *formattedTextForSizing = [self formattedStringForSizingFromString:_mainLabel.text];
    CGFloat mainLabelHeight = [self defaultSizeForText:@"default" width:mainLabelWidth].height;
    
    formattedTextForSizing = [self formattedStringForSizingFromString:_infoLabel.text];
    CGSize infoLabelSize = [self sizeForText:formattedTextForSizing font:infoFont width:mainLabelWidth];
    
    formattedTextForSizing = [self formattedStringForSizingFromString:_secondInfoLabel.text];
    CGSize secondInfoLabelSize = [self sizeForText:formattedTextForSizing font:secondInfoFont width:mainLabelWidth];
    
    formattedTextForSizing = [self formattedStringForSizingFromString:_detailsLabel.text];
    CGFloat detailsLabelHeight = [self sizeForText:formattedTextForSizing font:detailsFont width:CGRectGetWidth(_mainLabel.frame)].height;
    
    CGFloat labelsHeight = ceilf(mainLabelHeight + detailsLabelHeight + MAX(infoLabelSize.height, secondInfoLabelSize.height));
    CGFloat contentHeight = CGRectGetHeight(_containerView.frame);

    // Layout the labels
    CGFloat mainLabelY = ceilf((contentHeight - labelsHeight) / 2.0);

    _mainLabel.frame = CGRectMake(mainImageViewMaxX + kFMRecentsCellInnerSpacing, mainLabelY, mainLabelWidth, mainLabelHeight);

    _mainTextField.frame = _mainLabel.frame;
    
    _detailsLabel.frame = CGRectMake(CGRectGetMinX(_mainLabel.frame), CGRectGetMaxY(_mainLabel.frame), mainLabelWidth, detailsLabelHeight);
    
    _infoLabel.frame = CGRectMake(CGRectGetMinX(_mainLabel.frame), CGRectGetMaxY(_detailsLabel.frame), infoLabelSize.width, infoLabelSize.height);
    
}

- (CGSize)sizeForText:(NSString *)text font:(UIFont *)font width:(CGFloat)width {
    if (text && [self isEmptyOrWhiteSpaceString:text]) {
        CGSize constrainedSize = CGSizeMake(width, 400.0);
        return [text boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                               attributes:@{NSFontAttributeName : font} context:nil].size;
    }
    
    return CGSizeZero;
}

- (CGSize)defaultSizeForText:(NSString *)text width:(CGFloat)width {
    if (!text || [self isEmptyOrWhiteSpaceString:text]) {
        text = @"Default p";
    }
    
    CGSize constrainedSize = CGSizeMake(width, 400.0);
    if (!mainFont) {
        [self loadFonts];
    }
    return [text boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                           attributes:@{NSFontAttributeName : mainFont} context:nil].size;
}

- (NSString *)formattedStringForSizingFromString:(NSString *)oldString {
    NSString *newString = [oldString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    return newString;
}

#pragma mark - Private UI creation methods

- (void)addContainerView {
    self.contentView.backgroundColor = [UIColor clearColor];
    _containerView = [[UIView alloc] initWithFrame:self.contentView.frame];
    _containerView.userInteractionEnabled = YES;
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.contentView addSubview:_containerView];
}

- (void)addMainImageView {
    // Customize the image view
    _mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kFMRecentsCellImageSize, kFMRecentsCellImageSize)];
    _mainImageView.contentMode = UIViewContentModeCenter;
    _mainImageView.center = CGPointMake(_mainImageView.center.x, _containerView.center.y);
    _mainImageView.clipsToBounds = YES;
    _mainImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMainImageView:)];
    [_mainImageView addGestureRecognizer:tapGesture];
    
    [_containerView addSubview:_mainImageView];
}

- (void)addMainLabel {
    // Customize the main label
    _mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_mainImageView.frame) + kFMRecentsCellInnerSpacing, 0.0,
                                                           CGRectGetWidth(_containerView.frame), CGRectGetHeight(_containerView.frame))];
    _mainLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _mainLabel.font = mainFont;
    _mainLabel.backgroundColor = [UIColor clearColor];
    _mainLabel.textColor = [UIColor hex343434];
    
    [_containerView addSubview:_mainLabel];
}

- (void)addMainTextField {
    _mainTextField = [[UITextField alloc] initWithFrame:_mainLabel.frame];
    _mainTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _mainTextField.delegate = self;
    _mainTextField.backgroundColor = [UIColor clearColor];
    _mainTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
    _mainTextField.hidden = YES;
    _mainTextField.textColor = [UIColor hex343434];
    _mainTextField.font = mainFont;

    [_containerView addSubview:_mainTextField];
}

- (void)addDetailLabel {
    // Customize the detail label
    _detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_mainLabel.frame), CGRectGetMaxY(_mainLabel.frame), CGRectGetWidth(_mainLabel.frame), CGRectGetHeight(_containerView.frame))];
    _detailsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _detailsLabel.font = detailsFont;
    _detailsLabel.backgroundColor = [UIColor clearColor];
    _detailsLabel.textColor = [UIColor hex343434];
    
    [_containerView addSubview:_detailsLabel];
}

- (void)addInfoLabel {
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_detailsLabel.frame), CGRectGetMaxY(_detailsLabel.frame), 20.0, CGRectGetHeight(_containerView.frame))];
    _infoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _infoLabel.font = infoFont;
    _infoLabel.backgroundColor = [UIColor clearColor];
    _infoLabel.textColor = [UIColor hex343434];
    _infoLabel.lineBreakMode = NSLineBreakByClipping;
    
    [_containerView addSubview:_infoLabel];
}

- (void)addSecondInfoLabel {
    _secondInfoLabel = [UILabel new];
    _secondInfoLabel.font = secondInfoFont;
    _secondInfoLabel.backgroundColor = [UIColor clearColor];
    _secondInfoLabel.textColor = [UIColor hex0080FF];
    _secondInfoLabel.lineBreakMode = NSLineBreakByClipping;
    _secondInfoLabel.textAlignment = NSTextAlignmentRight;
    
    [self.containerView addSubview:_secondInfoLabel];
    _secondInfoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[infoLabel]-8-[secondInfoLabel]-6-[verticalSeparatorView]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"secondInfoLabel":self.secondInfoLabel, @"verticalSeparatorView": self.verticalSeparatorView, @"infoLabel":self.infoLabel}];
    NSLayoutConstraint *equalHeightsConstraint = [NSLayoutConstraint constraintWithItem:self.secondInfoLabel
                                                                              attribute:NSLayoutAttributeHeight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.infoLabel
                                                                              attribute:NSLayoutAttributeHeight
                                                                             multiplier:1.0
                                                                               constant:0];
    NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:self.secondInfoLabel
                                                                          attribute:NSLayoutAttributeBaseline
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.infoLabel
                                                                          attribute:NSLayoutAttributeBaseline
                                                                         multiplier:1.0
                                                                           constant:0];
    [_secondInfoLabel setContentHuggingPriority:UILayoutPriorityDefaultLow
                                        forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.containerView addConstraints:horizontalConstraints];
    [self.containerView addConstraint:equalHeightsConstraint];
    [self.containerView addConstraint:verticalConstraint];
}

- (void)addAccessoryImageView {
    // Add the accessory info image view
    _accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_containerView.frame) - kFMRecentsCellAccessoryViewWidth, 13.0,
                                                                        kFMRecentsCellAccessoryViewWidth - 10,
                                                                        CGRectGetHeight(_containerView.frame) - kFMRecentsCellButtonsHeight)];
    _accessoryImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _accessoryImageView.contentMode = UIViewContentModeRight;
    _accessoryImageView.backgroundColor = [UIColor clearColor];

    [_containerView addSubview:_accessoryImageView];
}

- (void)addAccessoryButtonView {
    _accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_containerView.frame) - kFMRecentsCellAccessoryViewWidth, 0.0,
                                                                  kFMRecentsCellAccessoryViewWidth,
                                                                  CGRectGetHeight(_containerView.frame))];
    _accessoryButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
    _accessoryButton.contentMode = UIViewContentModeRight;
    _accessoryButton.backgroundColor = [UIColor clearColor];
    [_accessoryButton addTarget:self action:@selector(didTapAccessoryRegion:) forControlEvents:UIControlEventTouchUpInside];
    _accessoryButton.accessibilityIdentifier = @"SKOneBoxRecentsTableViewCellOptionsButton";
    [_containerView addSubview:_accessoryButton];

}

- (void)addSeparatorView {
    _separatorView = [[UIImageView alloc] initWithFrame:CGRectMake(kFMRecentsCellImageSize, CGRectGetHeight(_containerView.frame) - 1.0, CGRectGetWidth(_containerView.frame) - 50, 1.0)];
    _separatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    _separatorView.backgroundColor = [UIColor hexEDEDED];
    
    [_containerView addSubview:_separatorView];
}

- (void)addVerticalSeparatorView {
    self.verticalSeparatorView = [UIImageView new];
    self.verticalSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    self.verticalSeparatorView.backgroundColor = [UIColor hexEDEDED];
    
    [self.containerView addSubview:self.verticalSeparatorView];
    self.verticalSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[verticalSeparatorView(1)]-6-[navigateImageView]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"navigateImageView":self.navigateImageView, @"verticalSeparatorView": self.verticalSeparatorView}];
    NSLayoutConstraint *equalHeightsConstraint = [NSLayoutConstraint constraintWithItem:self.verticalSeparatorView
                                                                              attribute:NSLayoutAttributeHeight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.navigateImageView
                                                                              attribute:NSLayoutAttributeHeight
                                                                             multiplier:1.0
                                                                               constant:0];
    NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:self.verticalSeparatorView
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.navigateImageView
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1.0
                                                                           constant:0];
    
    [self.containerView addConstraints:horizontalConstraints];
    [self.containerView addConstraint:equalHeightsConstraint];
    [self.containerView addConstraint:verticalConstraint];
}

- (void)addNavigateImageView {
    UIImage *image = [UIImage imageNamed:@"icon_location_navigate"];
    self.navigateImageView = [[UIImageView alloc] initWithImage:image];
    [self.containerView addSubview:self.navigateImageView];
    self.navigateImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[navigateImageView]-13-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"navigateImageView":self.navigateImageView}];
    NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:self.navigateImageView
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.infoLabel
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1.0
                                                                           constant:0];
    [self.navigateImageView setContentHuggingPriority:UILayoutPriorityRequired
                                              forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.containerView addConstraints:horizontalConstraints];
    [self.containerView addConstraint:verticalConstraint];
}

- (void)addAutomationDebugLabel {
    self.dateAutomationDebug = [[UILabel alloc] initWithFrame:CGRectMake(-123, -123, 60.0, 40)];
    [_containerView addSubview:self.dateAutomationDebug];
}

- (void)didTapAccessoryRegion:(id)button {
    if (self.didTapAccessoryRegion) {
        self.didTapAccessoryRegion();
    }
}

- (void)didTapMainImageView:(id)recognizer {
    if (self.didTapMainImageView) {
        self.didTapMainImageView();
    }
}

- (BOOL)isEmptyOrWhiteSpaceString:(NSString *)string {
    return ([string stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0);
}

@end

