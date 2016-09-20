//
//  SKTLostGPSSignalView.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>

#import "SKTBaseView.h"

@class SKTInsetLabel;

/** SKTLostGPSSignalView is used as a warning when the GPS signal is lost during navigation
 */
@interface SKTLostGPSSignalView : SKTBaseView

/** Contains the warning image.
 */
@property (nonatomic, strong) UIImageView *imageView;

/** Message for the user.
 */
@property (nonatomic, strong) SKTInsetLabel *messageLabel;

@end
