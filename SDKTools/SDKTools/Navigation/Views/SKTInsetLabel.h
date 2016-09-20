//
//  SKTInsetLabel.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>

/** Custom label to be used when displayed under the status bar.
 */
@interface SKTInsetLabel : UILabel

/** Value by which to vertically offset the text.
 */
@property (nonatomic, assign) CGFloat contentYOffset;

@end
