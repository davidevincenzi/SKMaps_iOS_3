//
//  UIImage+Additions.m
//  SDKTools
//

//

#import "UIImage+Additions.h"
#import "SKTNavigationUtils.h"

@implementation UIImage (Additions)

+ (UIImage *)navigationImageNamed:(NSString *)name {
    NSBundle *navBundle = [SKTNavigationUtils navigationBundle];
    NSString *path = [navBundle pathForResource:name ofType:nil];
    
    return [UIImage imageWithContentsOfFile:path];
}

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect imageRect = CGRectMake(0.0, 0.0, 1.0, 1.0);
    
    UIGraphicsBeginImageContext(imageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, imageRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
