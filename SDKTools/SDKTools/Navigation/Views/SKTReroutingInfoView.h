//
//  SKTReroutingInfoView.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>
#import "SKTBaseView.h"

@class SKTInsetLabel;

/** Warns the user that a rerouting is in progress.
 */
@interface SKTReroutingInfoView : SKTBaseView

/** A message for the user.
 */
@property (nonatomic, strong) SKTInsetLabel *messageLabel;

@end
