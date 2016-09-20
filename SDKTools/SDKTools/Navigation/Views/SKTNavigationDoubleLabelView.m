//
//  SKTNavigationSpeedView.m
//  FrameworkIOSDemo
//

//

#import "SKTNavigationDoubleLabelView.h"
#import "UIDevice+Additions.h"
#import "SKTNavigationConstants.h"

#define kTopFontSize ([UIDevice isiPad] ? 40.0 : 20.0)
#define kBottomFontSize ([UIDevice isiPad] ? 24.0 : 12.0)
#define kYSpacingAdjustment ([UIDevice isiPad] ? 4.0 : 2.0)

@implementation SKTNavigationDoubleLabelView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		[self addTopLabel];
		[self addBottomLabel];
        
        self.backgroundColor = [UIColor colorWithHex:kSKTBlackBackgroundColor alpha:kSKTBackgroundOpacity];
	}

	return self;
}

#pragma mark - Overidden

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat topHeight = [self.topLabel.text sizeWithFont:self.topLabel.font].height;
    if ([_topLabel.text isEmptyOrWhiteSpace]) {
        topHeight = 0.0;
    }
    _topLabel.frameHeight = topHeight;
    
    CGFloat bottomHeight = [_bottomLabel.text sizeWithFont:_bottomLabel.font].height;
    if ([_bottomLabel.text isEmptyOrWhiteSpace]) {
        bottomHeight = 0.0;
    }
    _bottomLabel.frameHeight = bottomHeight;
    
    CGFloat totalHeight = topHeight + bottomHeight;
    
    _topLabel.frameY = roundf((self.frameHeight - totalHeight) / 2.0);
    _bottomLabel.frameY = _topLabel.frameMaxY;
    
    //reduce the gap between the labels
    if ([_bottomLabel.text isNotEmptyOrWhiteSpace] && [_topLabel.text isNotEmptyOrWhiteSpace]) {
        _topLabel.frameY += kYSpacingAdjustment;
        _bottomLabel.frameY -= kYSpacingAdjustment;
    }
}

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }
    
    return hitView;
}

#pragma mark - UI creation

- (void)addTopLabel {
	_topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, roundf(self.frameHeight / 2))];
	_topLabel.font = [UIFont mediumNavigationFontWithSize:kTopFontSize];
    _topLabel.textColor = [UIColor whiteColor];
	_topLabel.textAlignment = NSTextAlignmentCenter;
	_topLabel.text = @"0";
	_topLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_topLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:_topLabel];
}

- (void)addBottomLabel {
	_bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, _topLabel.frameMaxY, self.frameWidth, roundf(self.frameHeight / 2))];
	_bottomLabel.font = [UIFont lightNavigationFontWithSize:kBottomFontSize];
    _bottomLabel.textColor = [UIColor whiteColor];
	_bottomLabel.textAlignment = NSTextAlignmentCenter;
	_bottomLabel.text = @"km/h";
	_bottomLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_bottomLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:_bottomLabel];
}

@end
