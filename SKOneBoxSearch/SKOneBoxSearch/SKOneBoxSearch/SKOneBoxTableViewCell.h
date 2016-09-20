//
//  SKOneBoxTableViewCell.h
//  SKOneBoxSearch
//
//  Created by Mihai Costea on 25/03/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SKOneBoxTableViewCellType) {
    SKOneBoxTableViewCellTypeAccessoryLeftImageViewAndRightTextWithSubtitle,
    SKOneBoxTableViewCellTypeAccessoryLeftImageViewAndRightText,
    SKOneBoxTableViewCellTypeAccessoryLeftImageViewWithSubtitle,
    SKOneBoxTableViewCellTypeAccessoryLeftImageView,
    SKOneBoxTableViewCellTypeNoAccessory
};

@interface SKOneBoxTableViewCell : UITableViewCell

@property (nonatomic, assign) SKOneBoxTableViewCellType type;
@property (nonatomic, strong) UIImage *leftImage;
@property (nonatomic, strong) NSAttributedString *mainText;
@property (nonatomic, strong) NSAttributedString *subtitle;
@property (nonatomic, strong) UIImage *accessoryImage;
@property (nonatomic, strong) NSString *accessoryText;

@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIFont *highlightedTextFont;
@property (nonatomic, strong) UIFont *subtitleFont;
@property (nonatomic, strong) UIFont *highlightedSubtitleFont;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, strong) UIColor *subtitleColor;
@property (nonatomic, strong) UIColor *highlightedSubtitleColor;

@property (nonatomic, assign) BOOL shouldShowMiddleSeparatorView;
@property (nonatomic, assign) BOOL shouldShowTopSeparatorView;
@property (nonatomic, assign) BOOL shouldShowBottomSeparatorView;

- (instancetype)initWithType:(SKOneBoxTableViewCellType)type;
+ (NSString *)reuseIdentifierForType:(SKOneBoxTableViewCellType)type;

- (NSMutableAttributedString*)attributedMainText:(NSString*)mainText highlightedText:(NSString*)highlightedText;
- (NSMutableAttributedString*)attributedSubtitleText:(NSString*)subtitleText highlightedSubtitleText:(NSString*)highlightedSubtitleText;

- (void)updateSeparatorShowTop:(BOOL)showTop showMiddle:(BOOL)showMiddle showBottom:(BOOL)showBottom;

@end
