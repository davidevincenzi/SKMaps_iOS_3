//
//  NoSignalView.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>

#import "SKTBaseView.h"

@protocol SKTWaitingGPSSignalViewDelegate;

/** STKWaitingGPSSignalView is displayed when attempting to start a navigation without having GPS signal. The user can wait for the signal or abort.
 */
@interface SKTWaitingGPSSignalView : SKTBaseView

/** Used to notify about user interaction.
 */
@property (nonatomic, weak) id<SKTWaitingGPSSignalViewDelegate> delegate;

/** The title of the view.
 */
@property (nonatomic, strong) UILabel *titleLabel;

/** A message for the user.
 */
@property (nonatomic, strong) UILabel *textLabel;

/** An image to be displayed as warning.
 */
@property (nonatomic, strong) UIImageView *imageView;

/** An activity indicator while the user waits.
 */
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

/** A button to be tapped if the user doesn't want to wait.
 */
@property (nonatomic, strong) UIButton *okButton;

@end

/** Receives notifications about user interaction.
 */
@protocol SKTWaitingGPSSignalViewDelegate <NSObject>

/** Called when the user has pressed the OK button.
 @param view The waiting view that contains this button.
 */
- (void)skWaitingGPSSignalDidClickOkButton:(SKTWaitingGPSSignalView *)view;

@end
