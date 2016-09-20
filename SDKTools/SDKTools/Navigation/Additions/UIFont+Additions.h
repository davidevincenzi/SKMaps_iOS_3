//
//  UIFont+Additions.h
//  SDKTools
//

//

#import <UIKit/UIKit.h>

/** Provides helper methods.
 */
@interface UIFont (Additions)

/** Creates a light font used across all the UI with a given size.
@param size The size of the font.
 */
+ (UIFont *)lightNavigationFontWithSize:(CGFloat)size;

/** Creates a medium font used across all the UI with a given size.
 @param size The size of the font.
 */
 + (UIFont *)mediumNavigationFontWithSize:(CGFloat)size;

@end
