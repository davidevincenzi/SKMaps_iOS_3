//
//  UIColor+Additions.m
//  
//

//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)

+ (UIColor *) colorWithHex:(uint32_t)hex {
    if (hex <= 0xFFFFFF) {
        return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0
                               green:((float)((hex & 0xFF00) >> 8)) / 255.0
                                blue:((float)(hex & 0xFF)) / 255.0
                               alpha:255.0];
    } else {
        return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0
                               green:((float)((hex & 0xFF00) >> 8)) / 255.0
                                blue:((float)(hex & 0xFF)) / 255.0
                               alpha:((float)((hex & 0xFF000000) >> 24)) / 255.0];
    }
}

+ (UIColor *)colorWithHex:(uint32_t)hex alpha:(float)alpha {
    if (hex <= 0xFFFFFF) {
        return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0
                               green:((float)((hex & 0xFF00) >> 8)) / 255.0
                                blue:((float)(hex & 0xFF)) / 255.0
                               alpha:alpha];
    } else {
        return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0
                               green:((float)((hex & 0xFF00) >> 8)) / 255.0
                                blue:((float)(hex & 0xFF)) / 255.0
                               alpha:alpha];
    }
}

@end
