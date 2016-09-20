//
//  SKTProgressView.m
//  FrameworkIOSDemo
//

//

#import "SKTProgressView.h"

@implementation SKTProgressView

+ (SKTProgressView *)progressViewWithFrame:(CGRect)frame trackColor:(UIColor *)trackColor
                            progressColor:(UIColor *)progressColor lineWidth:(CGFloat)lineWidth {
	return [[SKTProgressView alloc] initWithFrame:frame trackColor:trackColor progressColor:progressColor lineWidth:lineWidth];
}

- (id)initWithFrame:(CGRect)frame trackColor:(UIColor *)trackColor progressColor:(UIColor *)progressColor lineWidth:(CGFloat)lineWidth {
	self = [super initWithFrame:frame];
	if (!self) return nil;

	self.trackColor = trackColor;
	self.progressColor = progressColor;
	self.lineWidth = lineWidth;

	self.backgroundColor = [UIColor clearColor];
	self.circleColor = [UIColor whiteColor];

	return self;
}

#pragma mark - Properties

- (void)setPercent:(CGFloat)percent {
	_percent = percent;

	[self setNeedsDisplay];
}

#pragma mark - Protected methods

- (void)drawRect:(CGRect)rect {
	CGFloat startAngle = 3 * M_PI_2;
	CGFloat endAngle = startAngle - self.percent * 2 * M_PI;
	CGPoint center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
	CGFloat radius = roundf(self.frame.size.width / 2 - self.lineWidth / 2.0) - 2.0;

	UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0.0 endAngle:2 * M_PI clockwise:NO];
	path.lineCapStyle = kCGLineCapButt;
	path.lineWidth = self.lineWidth;
	[self.circleColor setFill];
	[self.trackColor setStroke];
	[path fill];
	[path stroke];

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);

	path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:NO];
	path.lineCapStyle = kCGLineCapButt;
	path.lineWidth = self.lineWidth;
	[self.progressColor setStroke];
	[path stroke];

	CGContextRestoreGState(context);
}

@end
