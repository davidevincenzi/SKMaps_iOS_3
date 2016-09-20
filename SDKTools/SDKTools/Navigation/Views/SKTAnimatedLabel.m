//
//  HYNAnimatedLabel.m
//  ForeverMapNGX
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKTAnimatedLabel.h"

@interface SKTAnimatedLabel ()

@property (atomic, assign) BOOL isAnimating;

@end

@interface SKTAnimatedLabel (PrivateUICreation)

- (void)addLabel;

@end

@implementation SKTAnimatedLabel

#pragma mark - Lifecycle

+ (SKTAnimatedLabel *)animatedLabelWithFrame:(CGRect)frame label:(UILabel *)label {
    return [[SKTAnimatedLabel alloc] initWithFrame:frame label:label];
}

- (id)initWithFrame:(CGRect)frame label:(UILabel *)label {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    self.label = label;
    self.label.frame = self.bounds;
    [self addSubview:self.label];
    self.clipsToBounds = YES;
    
    [self addObserver:self forKeyPath:@"label.text" options:0 context:NULL];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self addLabel];
    
    self.clipsToBounds = YES;
    
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"label.text" context:NULL];
}

- (void)restartAnimation {
    [self stopAnimatingLabel];
    [self tryStartingAnimationOfLabel];
}

#pragma mark - Private methods

- (void)startAnimatingLabel {
    CGFloat velocity = 12.0; // Velocity in pixels/second
    CGFloat distance = fabsf(self.label.frameWidth - self.frameWidth);
    NSTimeInterval duration = distance / velocity;
    
    if (!self.isAnimating) {
        self.isAnimating = YES;
        self.label.frameX = 0.0;
        [UIView animateWithDuration:duration delay:0 options:0 animations:^{
            self.label.frameX = self.frameWidth - self.label.frameWidth - 10.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration delay:0 options:0 animations:^{
                self.label.frameX = 0.0;
            } completion:^(BOOL finished) {
                if (self.isAnimating) {
                    self.isAnimating = NO;
                    [self performSelector:@selector(startAnimatingLabel) withObject:nil afterDelay:1.0];
                }
            }];
        }];
    }
}

- (void)stopAnimatingLabel {
    self.label.frameX = 0.0;
    self.isAnimating = NO;
}

- (void)updateLabelSize {
    CGSize constrainedSize = CGSizeMake(10000.0, self.frameHeight);
    CGSize size =[self.label sizeThatFits:constrainedSize];
    self.label.frameWidth = size.width;
}

- (void)tryStartingAnimationOfLabel {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAnimatingLabel) object:nil];
    
    [self stopAnimatingLabel];
    [self updateLabelSize];
    

    if (self.label.frameWidth > self.frameWidth) {
        [self startAnimatingLabel];
    } else if (self.label.textAlignment == NSTextAlignmentCenter) {
        self.label.frameX = roundf((self.frameWidth - self.label.frameWidth) / 2.0);
    }
}

- (void)layoutSubviews {
    if (!self.isAnimating) {
        [self tryStartingAnimationOfLabel];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"label.text"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self tryStartingAnimationOfLabel];
        });
    }
}

@end

@implementation SKTAnimatedLabel (PrivateUICreation)

- (void)addLabel {
    CGRect frame = self.bounds;
    self.label = [[UILabel alloc] initWithFrame:frame];
    self.label.autoresizingMask = UIViewAutoresizingNone;
    self.label.font = [UIFont fontWithName:@"Avenir" size:23.0];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.textColor = [UIColor colorWithHex:0x000000];
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.text = @"";
    [self addObserver:self forKeyPath:@"label.text" options:0 context:NULL];
    
    [self addSubview:self.label];
}

@end