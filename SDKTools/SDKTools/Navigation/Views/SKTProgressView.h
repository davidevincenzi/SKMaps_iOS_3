//
//  SKTProgressView.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>

/** Display a round progress view.
 */
@interface SKTProgressView : UIView

/** Percent of progress.
 */
@property (nonatomic, assign) CGFloat percent;

/** Sets the width of the circle line.
 */
@property (nonatomic, assign) CGFloat lineWidth;

/** Sets the color of the track of the progress view.
 */
@property (nonatomic, strong) UIColor *trackColor;

/** Sets the progress color of the progress view.
 */
@property (nonatomic, strong) UIColor *progressColor;

/** Sets the color for the inside of the progress view.
 */
@property (nonatomic, strong) UIColor *circleColor;

/** Factory method
 @param frame Frame of the view.
 @param trackColor Color of the remaining progress outline.
 @param progressColor Color of the progress outline.
 @param lineWidth Progress outline width.
 */
+ (SKTProgressView *)progressViewWithFrame:(CGRect)frame trackColor:(UIColor *)trackColor progressColor:(UIColor *)progressColor lineWidth:(CGFloat)lineWidth;

@end
