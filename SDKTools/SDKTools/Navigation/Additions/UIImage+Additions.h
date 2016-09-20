//
//  UIImage+Additions.h
//  SDKTools
//

//

#import <UIKit/UIKit.h>

/** Provides helper methods
 */
@interface UIImage (Additions)

/** Loads an image from SKTNavigationResources.bundle
 @param name Image name.
 */
+ (UIImage *)navigationImageNamed:(NSString *)name;

/** Creates a plain image that has the given color.
 @param color Desired color.
 */
+ (UIImage *)imageFromColor:(UIColor *)color;

@end
