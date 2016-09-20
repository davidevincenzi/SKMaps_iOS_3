//
//  SKOneBoxHeaderButton.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxHeaderButton.h"
#import "UIColor+SKOneBoxColors.h"

static float kTopMargin         = 15.0;
static float kIconHeight        = 36.0;

@interface SKOneBoxHeaderButton ()

@property (nonatomic, strong, readwrite) void (^selectionBlock)();
@property (nonatomic, strong, readwrite) UILabel *textLabel;
@property (nonatomic, strong, readwrite) UIImageView *iconView;

@property (nonatomic, strong, readwrite) UIImage *inactiveStateImage;
@property (nonatomic, strong, readwrite) UIImage *activeStateImage;
@property (nonatomic, strong, readwrite) UIImage *selectedStateImage;

@end

@implementation SKOneBoxHeaderButton

- (id)initWithTitle:(NSString*)title activeImage:(UIImage*)activeImage selectedImage:(UIImage*)selectedImage inactiveImage:(UIImage*)inactiveImage andSelectionBlock:(void (^)(void))selectionBlock {
    self = [super init];
    if (self) {
        self.selectionBlock = selectionBlock;
        
        self.inactiveStateImage = inactiveImage;
        self.activeStateImage = activeImage;
        self.selectedStateImage = selectedImage;
        
        self.iconView = [[UIImageView alloc] initWithImage:self.inactiveStateImage];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.iconView];
        
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor hex3A3A3A];
        self.textLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:13];
        self.textLabel.text = title;
        [self addSubview:self.textLabel];
        
        [self addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark - Private

- (void)buttonTapped:(UIButton*)button {
    self.selectionBlock();
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.iconView.image = self.activeStateImage;
        self.textLabel.textColor = [UIColor hex0080FF];
    } else {
        self.iconView.image = self.inactiveStateImage;
        self.textLabel.textColor = [UIColor hex3A3A3A];;
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    if (enabled) {
        self.textLabel.textColor = [UIColor hex3A3A3A];
    } else {
        self.textLabel.textColor = [UIColor hex858585];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.textLabel.text) {
        CGSize textSize = [self.textLabel.text sizeWithAttributes:@{NSFontAttributeName:self.textLabel.font}];
        CGFloat heightText = textSize.height;
        float textLabelY = self.frame.size.height - heightText - kTopMargin;
    	self.textLabel.frame = CGRectMake(0.0, textLabelY, self.frame.size.width, heightText);
	}
    self.iconView.frame = CGRectMake(0.0, kTopMargin, self.frame.size.width, kIconHeight);
}

@end
