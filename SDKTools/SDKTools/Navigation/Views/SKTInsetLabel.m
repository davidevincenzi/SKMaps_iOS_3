//
//  SKTInsetLabel.m
//  FrameworkIOSDemo
//

//

#import "SKTInsetLabel.h"

@implementation SKTInsetLabel

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.contentYOffset = 0;
	}
	return self;
}

- (void)setContentYOffset:(CGFloat)contentYOffset {
    _contentYOffset = contentYOffset;
    
    [self setNeedsDisplay];
}

#pragma mark - Overidden

- (void)drawTextInRect:(CGRect)rect {
	[super drawTextInRect:CGRectMake(rect.origin.x, rect.origin.y + _contentYOffset, rect.size.width, rect.size.height - _contentYOffset)];
}

@end
