//
//  SKOneBoxLocationView.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxLocationView.h"

@interface SKOneBoxLocationView () <UIGestureRecognizerDelegate>

@end

@implementation SKOneBoxLocationView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOccured:)];
    [self addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;
    
    tapRecognizer.cancelsTouchesInView = NO;
}

-(void)tapOccured:(UITapGestureRecognizer*)recognizer {
    if ([self.delegate respondsToSelector:@selector(didTapLocationView:)]) {
        [self.delegate didTapLocationView:self];
    }
}

-(IBAction)clearLocation:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didTapClearLocation:)]) {
        [self.delegate didTapClearLocation:self];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // test if our control subview is on-screen
    if (self.locationButton.superview != nil) {
        if ([touch.view isDescendantOfView:self.locationButton]) {
            // we touched our control surface
            return NO; // ignore the touch
        }
    }
    return YES; // handle the touch
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
