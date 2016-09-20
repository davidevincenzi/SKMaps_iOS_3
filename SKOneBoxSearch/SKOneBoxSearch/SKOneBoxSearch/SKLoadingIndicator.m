//
//  SKLoadingIndicator.m
//  animation
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKLoadingIndicator.h"

@interface SKLoadingIndicator()

@property (nonatomic, assign) NSInteger circleWidth;
@property (nonatomic, strong) NSArray   *circles;
@property (nonatomic, strong) NSArray   *circlesTraiectory;
@property (nonatomic, strong) NSArray   *circlesAlpha;
@property (nonatomic, strong) NSArray   *circlesAlpha1;

@property (nonatomic, assign) BOOL      isAnimationInProgress;

@end

@implementation SKLoadingIndicator

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWithFrame:frame];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupWithFrame:self.frame];
}

#pragma mark - Public

- (void)setCircleColor:(UIColor *)circleColor {
    _circleColor = circleColor;
    for (int i = 0; i < self.circles.count; i++) {
        ((UIView *)self.circles[i]).backgroundColor = circleColor;
    }
}

- (void)startAnimating {
    if (!self.isAnimationInProgress) {
        [self setupCircles];
        NSInteger numberOfKeyFrames = [self.circlesTraiectory[0] count];
        self.isAnimationInProgress = YES;
        [UIView animateKeyframesWithDuration:self.duration delay:0
                                     options:UIViewKeyframeAnimationOptionRepeat|UIViewKeyframeAnimationOptionCalculationModeCubicPaced| UIViewKeyframeAnimationOptionAllowUserInteraction
                                  animations:^{
                                      
                                      for (int i = 1; i < numberOfKeyFrames; i++) {
                                          [UIView addKeyframeWithRelativeStartTime:i*(self.duration/numberOfKeyFrames) relativeDuration:self.duration/numberOfKeyFrames animations:^{
                                              UIView *aview = self.circles[0];
                                              aview.frame = CGRectMake([self.circlesTraiectory[0][i] floatValue] * self.circleWidth, 0, self.circleWidth, self.circleWidth);
                                              aview.alpha = [self.circlesAlpha[0][i] floatValue];
                                              
                                              aview = self.circles[1];
                                              aview.frame = CGRectMake([self.circlesTraiectory[1][i] floatValue] * self.circleWidth, 0, self.circleWidth, self.circleWidth);
                                              
                                              aview = self.circles[2];
                                              aview.frame = CGRectMake([self.circlesTraiectory[2][i] floatValue] * self.circleWidth, 0, self.circleWidth, self.circleWidth);
                                              aview.alpha = [self.circlesAlpha[1][numberOfKeyFrames - i -1] floatValue];
                                          }];
                                      }
                                  } completion:^(BOOL finished) {}];
    }
}

- (void)stopAnimating {
    for (int i = 0; i < self.circles.count; i++) {
        UIView *circle = (UIView *)self.circles[i];
        [circle.layer removeAllAnimations];
    }
    [self.layer removeAllAnimations];
    self.isAnimationInProgress = NO;
}

- (BOOL)isAnimating {
    return self.isAnimationInProgress;
}

#pragma mark - Private

-(void)setupWithFrame:(CGRect)frame {
    self.isAnimationInProgress = NO;
    self.circleWidth = MIN(frame.size.width, frame.size.height);
    self.circles = @[[[UIView alloc] init], [[UIView alloc] init], [[UIView alloc] init]];
    
    self.circlesTraiectory = @[
                               @[@0.000, @0.230, @0.461, @0.692, @0.846, @1.076, @1.15, @1.23, @1.307, @1.380, @1.46, @1.46, @1.538, @1.615, @1.690, @1.769],
                               @[@1.769, @1.846, @1.846, @1.920, @2.000, @2.070, @2.15, @2.23, @2.307, @2.380, @2.46, @2.46, @2.530, @2.610, @2.690, @2.769],
                               @[@2.769, @2.846, @2.846, @2.920, @3.000, @3.070, @3.15, @3.23, @3.307, @3.380, @3.38, @3.53, @3.690, @3.846, @4.076, @4.307]];
    
    self.circlesAlpha = @[
                          @[@0.25, @0.3, @0.40, @0.5, @0.65, @0.70, @0.85, @0.90, @0.95, @1.0, @1.0, @1, @1, @1, @1, @1],
                          @[@0.15, @0.2, @0.25, @0.3, @0.35, @0.45, @0.50, @0.55, @0.65, @0.7, @0.8, @1, @1, @1, @1, @1]];
    
    self.circleColor = [UIColor blueColor];
    self.duration = 0.45;
    
    for (int i = 0; i < self.circles.count; i++) {
        UIView *aCircle = ((UIView *)self.circles[i]);
        [self addSubview:aCircle];
    }
}

- (void)setupCircles {
    for (int i = 0; i < self.circles.count; i++) {
        CGFloat relativPosition = [self.circlesTraiectory[i][0] floatValue];
        UIView *aCircle = ((UIView *)self.circles[i]);
        aCircle.frame = CGRectMake(relativPosition * self.circleWidth, 0.0, self.circleWidth, self.circleWidth);
        aCircle.layer.cornerRadius = self.circleWidth / 2.0;
        aCircle.backgroundColor = self.circleColor;
        aCircle.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    ((UIView *)self.circles[0]).alpha = 0.2;
    ((UIView *)self.circles[1]).alpha = 1;
    ((UIView *)self.circles[2]).alpha = 1;
}

@end
