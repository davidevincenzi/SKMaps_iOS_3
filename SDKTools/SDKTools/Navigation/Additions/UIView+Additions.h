//
//  UIView+Additions.h
//  
//

//

#import <UIKit/UIKit.h>

/** Helper category to get and set various values of the view's frame.
 */
@interface UIView (Additions)

/** Get/set x position.
 */
@property (nonatomic, assign) CGFloat frameX;

/** Get/set y position.
 */
@property (nonatomic, assign) CGFloat frameY;

/** Get/set maximum coordinate that the view occupies horizontally (frameX + frameWidth).
 */
@property (nonatomic, assign) CGFloat frameMaxX;

/** Get/set maximum coordinate that the view occupies vertically (frameY + frameHeight).
 */
 @property (nonatomic, assign) CGFloat frameMaxY;

/** Get/set the view's frame width.
 */
@property (nonatomic, assign) CGFloat frameWidth;

/** Get/set the view's frame height.
 */
@property (nonatomic, assign) CGFloat frameHeight;

/** Get/set the view's bounds width.
 */
@property (nonatomic, assign) CGFloat boundsWidth;

/** Get/set the view's bounds height.
 */
@property (nonatomic, assign) CGFloat boundsHeight;

/** Get/set the x coordinate of center of the view.
 */
@property (nonatomic, assign) CGFloat centerX;

/** Get/set the y coordinate of center of the view.
 */
@property (nonatomic, assign) CGFloat centerY;

/** Get/set the view's frame size.
 */
@property (nonatomic, assign) CGSize  frameSize;

/** Get/set the view's frame origin.
 */
@property (nonatomic, assign) CGPoint frameOrigin;

@end
