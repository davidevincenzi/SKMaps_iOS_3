//
//  UIButton+Additions.h
//  SDKTools
//

//

#import <UIKit/UIKit.h>

/** Helper category.
 */
@interface UIButton (Additions)

/** Factory method.
 @param frame Button's frame.
 @param iconName Name of thte icon image.
 @param bkImageName Name of the background image.
 @param hiBkImageName Name of the highligted background image.
 */
+ (UIButton *)buttonWithFrame:(CGRect)frame icon:(NSString *)iconName backgroundImageNamed:(NSString *)bkImageName highlightedBkImageNamed:(NSString *)hiBkImageName;

/** Factory method.
 @param frame Button's frame.
 @param iconName Name of thte icon image.
 @param backgroundColor Background color.
 */
+ (UIButton *)buttonWithFrame:(CGRect)frame icon:(NSString *)iconName backgroundColor:(UIColor *)backgroundColor;

/** Factory method.
 @param frame Button's frame.
 @param iconName Name of thte icon image.
 @param backgroundColor Background color.
 @param highligtedBackgroundColor Highligted state background color.
 */
+ (UIButton *)buttonWithFrame:(CGRect)frame icon:(NSString *)iconName backgroundColor:(UIColor *)backgroundColor highligtedBackgroundColor:(UIColor *)highligtedBackgroundColor;

/** Creates the default back button used in the navigation UI.
 */
+ (UIButton *)navigationBackButton;

@end
