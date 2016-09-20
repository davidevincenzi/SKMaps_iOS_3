//
//  UIColor+Additions.h
//  
//

//

#import <UIKit/UIKit.h>

/** This category provides factory methods for UIColor.
 */
@interface UIColor (Additions)

/** Returns a UIColor equivalent of the given hex value.
 @param hex The color value in HTML hex notation.
 */
+ (UIColor *)colorWithHex:(uint32_t)hex;

/** Returns a UIColor equivalent of the given hex value with desired alpha. Ignores the alpha contained in the hex value.
 @param hex The color value in HTML hex notation.
 @param alpha Desired alpha value.
 */
+ (UIColor *)colorWithHex:(uint32_t)hex alpha:(float)alpha;

@end
