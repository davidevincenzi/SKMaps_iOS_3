//
//  SKOneBoxTableViewCell.m
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 25/03/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxTableViewCell.h"
#import "UIColor+SKOneBoxColors.h"
#import "NSMutableAttributedString+OneBoxSearch.h"

#define kAccessoryViewWidth 60
#define kSeparatorHeight 1
#define kSeparatorInset 46
#define kImageInset 12

@interface SKOneBoxTableViewCell ()
@property (nonatomic, strong) UIView *middleSeparator;
@property (nonatomic, strong) UIView *topSeparator;
@property (nonatomic, strong) UIView *bottomSeparator;
@end

@implementation SKOneBoxTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public

- (instancetype)initWithType:(SKOneBoxTableViewCellType)type {
    switch (type) {
        case SKOneBoxTableViewCellTypeAccessoryLeftImageViewAndRightTextWithSubtitle:
            self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:[SKOneBoxTableViewCell reuseIdentifierForType:type]];
            
            break;
        case SKOneBoxTableViewCellTypeAccessoryLeftImageViewAndRightText:
            self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[SKOneBoxTableViewCell reuseIdentifierForType:type]];
            
            break;
        case SKOneBoxTableViewCellTypeAccessoryLeftImageViewWithSubtitle:
            self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[SKOneBoxTableViewCell reuseIdentifierForType:type]];

            break;
        case SKOneBoxTableViewCellTypeAccessoryLeftImageView:
            self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[SKOneBoxTableViewCell reuseIdentifierForType:type]];
            
            break;
        case SKOneBoxTableViewCellTypeNoAccessory:
            self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[SKOneBoxTableViewCell reuseIdentifierForType:type]];
            
            break;
        default:
            self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[SKOneBoxTableViewCell reuseIdentifierForType:type]];
            
            break;
    }
    
    self.textFont = [UIFont fontWithName:@"Avenir-Roman" size:16];
    self.highlightedTextFont = [UIFont fontWithName:@"Avenir-Heavy" size:16];
    self.subtitleFont = [UIFont fontWithName:@"Avenir-Roman" size:13];
    self.highlightedSubtitleFont = [UIFont fontWithName:@"Avenir-Heavy" size:13];
    
    self.textColor = [UIColor hex3A3A3A];
    self.highlightedTextColor = [UIColor hex3A3A3A];
    self.subtitleColor = [UIColor hex898989];
    self.highlightedSubtitleColor = [UIColor hex898989];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor hexF9F9F9];
    [self setSelectedBackgroundView:bgColorView];
    
    self.type = type;
    
    self.middleSeparator = [[UIView alloc] initWithFrame:CGRectMake(kSeparatorInset,self.frame.size.height-kSeparatorHeight,self.frame.size.width-kSeparatorInset,kSeparatorHeight)];
    self.middleSeparator.backgroundColor = [UIColor hexEDEDED];
    [self addSubview:self.middleSeparator];
    
    self.topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,kSeparatorHeight)];
    self.topSeparator.backgroundColor = [UIColor hexEDEDED];
    [self addSubview:self.topSeparator];
    
    self.bottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0,self.frame.size.height-kSeparatorHeight,self.frame.size.width,kSeparatorHeight)];
    self.bottomSeparator.backgroundColor = [UIColor hexEDEDED];
    [self addSubview:self.bottomSeparator];
    
    [self updateSeparatorShowTop:NO showMiddle:NO showBottom:NO];
    
    return self;
}

+ (NSString *)reuseIdentifierForType:(SKOneBoxTableViewCellType)type {
    switch (type) {
        case SKOneBoxTableViewCellTypeAccessoryLeftImageViewAndRightTextWithSubtitle:
            return @"kSKOneBoxTableViewCellTypeAccessoryLeftImageViewAndRightTextWithSubtitleIdentifier";
            break;
        case SKOneBoxTableViewCellTypeAccessoryLeftImageViewAndRightText:
            return @"kSKOneBoxTableViewCellTypeAccessoryLeftImageViewAndRightTextIdentifier";
            break;
        case SKOneBoxTableViewCellTypeAccessoryLeftImageViewWithSubtitle:
            return @"kSKOneBoxTableViewCellTypeAccessoryLeftImageViewWithSubtitleIdentifier";
            break;
        case SKOneBoxTableViewCellTypeAccessoryLeftImageView:
            return @"kSKOneBoxTableViewCellTypeAccessoryLeftImageViewIdentifier";
            break;
        case SKOneBoxTableViewCellTypeNoAccessory:
            return @"kSKOneBoxTableViewCellTypeNoAccessoryIdentifier";
            break;
        default:
            return @"kSKOneBoxTableViewCellTypeNoAccessoryIdentifier";
            break;
    }

    return nil;
}

- (NSMutableAttributedString*)attributedSubtitleText:(NSString*)subtitleText highlightedSubtitleText:(NSString*)highlightedSubtitleText {
    NSMutableAttributedString *attributedString = [NSMutableAttributedString attributedText:subtitleText highlightedText:highlightedSubtitleText font:self.subtitleFont color:self.subtitleColor highlightedFont:self.highlightedSubtitleFont highlightedColor:self.highlightedSubtitleColor];
    return attributedString;
}

- (NSMutableAttributedString*)attributedMainText:(NSString*)mainText highlightedText:(NSString*)highlightedText {
    NSMutableAttributedString *attributedString = [NSMutableAttributedString attributedText:mainText highlightedText:highlightedText font:self.textFont color:self.textColor highlightedFont:self.highlightedTextFont highlightedColor:self.highlightedTextColor];
    
    return attributedString;
}

- (void)updateSeparatorShowTop:(BOOL)showTop showMiddle:(BOOL)showMiddle showBottom:(BOOL)showBottom {
    self.shouldShowMiddleSeparatorView = showMiddle;
    self.shouldShowTopSeparatorView = showTop;
    self.shouldShowBottomSeparatorView = showBottom;
}

#pragma mark - Overriden methods

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [self.middleSeparator setFrame:CGRectMake(kSeparatorInset,self.frame.size.height-kSeparatorHeight,self.frame.size.width-kSeparatorInset,kSeparatorHeight)];
    [self.topSeparator setFrame:CGRectMake(0,0,self.frame.size.width,kSeparatorHeight)];
    [self.bottomSeparator setFrame:CGRectMake(0,self.frame.size.height-kSeparatorHeight,self.frame.size.width,kSeparatorHeight)];
    
    CGFloat labelStartInset = kSeparatorInset;
    if (!self.imageView.image) {
        labelStartInset = kImageInset;
    }
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = labelStartInset;
    self.textLabel.frame = textLabelFrame;
    
    CGRect subtitleLabelFrame = self.detailTextLabel.frame;
    subtitleLabelFrame.origin.x = labelStartInset;
    self.detailTextLabel.frame = subtitleLabelFrame;
    
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.x = kImageInset;
    self.imageView.frame = imageFrame;
    
    if (self.accessoryView) {
        //we have accessoryView text, move it with the first line, and let second line all the way to the end
        CGRect accessoryFrame = self.accessoryView.frame;
        accessoryFrame.origin.y = CGRectGetMinY(self.textLabel.frame);
        accessoryFrame.size.height = CGRectGetHeight(self.textLabel.frame);
        self.accessoryView.frame = accessoryFrame;
        
        subtitleLabelFrame.size.width = CGRectGetMaxX(accessoryFrame) - subtitleLabelFrame.origin.x;
        
        self.detailTextLabel.frame = subtitleLabelFrame;
    }
}
- (void)setLeftImage:(UIImage *)leftImage {
    _leftImage = leftImage;
    self.imageView.image = leftImage;
}

- (void)setMainText:(NSAttributedString *)mainText {
    _mainText = mainText;
    self.textLabel.attributedText = self.mainText;
}

- (void)setSubtitle:(NSAttributedString *)subtitle {
    _subtitle = subtitle;
    self.detailTextLabel.attributedText = self.subtitle;
}

- (void)setAccessoryImage:(UIImage *)accessoryImage {
    _accessoryImage = accessoryImage;
    self.accessoryView = [self rightAccessoryViewWithImage:self.accessoryImage];
}

- (void)setAccessoryText:(NSString *)accessoryText {
    _accessoryText = accessoryText;
    if (accessoryText) {
        self.accessoryView = [self rightAccessoryViewWithText:self.accessoryText];
    }
    else {
        self.accessoryView = nil;
    }
}

-(void)setShouldShowMiddleSeparatorView:(BOOL)shouldShowMiddleSeparatorView {
    _shouldShowMiddleSeparatorView = shouldShowMiddleSeparatorView;
    self.middleSeparator.hidden = !shouldShowMiddleSeparatorView;
}

-(void)setShouldShowTopSeparatorView:(BOOL)shouldShowTopSeparatorView {
    _shouldShowTopSeparatorView = shouldShowTopSeparatorView;
    self.topSeparator.hidden = !shouldShowTopSeparatorView;
}

-(void)setShouldShowBottomSeparatorView:(BOOL)shouldShowBottomSeparatorView {
    _shouldShowBottomSeparatorView = shouldShowBottomSeparatorView;
    self.bottomSeparator.hidden = !shouldShowBottomSeparatorView;
}

#pragma mark - Private methods
                         
- (UIView *)rightAccessoryViewWithText:(NSString *)text {
    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-kAccessoryViewWidth, 0.0, kAccessoryViewWidth, self.frame.size.height)];
    UILabel *accessoryTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, accessoryView.frame.size.width, accessoryView.frame.size.height)];
    accessoryTextLabel.text = text;
    accessoryTextLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:12];
    accessoryTextLabel.textAlignment = NSTextAlignmentRight;
    accessoryTextLabel.textColor = [UIColor hex0080FF];
    accessoryTextLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [accessoryView addSubview:accessoryTextLabel];

    return accessoryView;
}

- (UIView *)rightAccessoryViewWithImage:(UIImage *)image {
    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kAccessoryViewWidth, self.frame.size.height)];
    [accessoryView addSubview:[[UIImageView alloc] initWithImage:image]];
    return accessoryView;
}

@end
