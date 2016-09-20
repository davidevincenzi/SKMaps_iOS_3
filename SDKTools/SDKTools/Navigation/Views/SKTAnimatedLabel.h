//
//  SKTAnimatedLabel.h
//  
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Wrapper around UILabel that animates the label floating moving left to right. Used to display long strings.
 */
@interface SKTAnimatedLabel : UIView

/** The label that is animated.
 */
@property (nonatomic, strong) UILabel *label;

/** Initializer method.
 @param frame Frame of the view.
 @param label Label to animate.
 */
- (id)initWithFrame:(CGRect)frame label:(UILabel *)label;

/** Stops the animation and restarts from 0 if needed.
 */
- (void)restartAnimation;

@end
