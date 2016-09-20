//
//  SKTNavigationFreeDriveView.h
//  SDKTools
//

//

#import <UIKit/UIKit.h>

#import <SKMaps/SKDefinitions.h>

#import "SKTBaseView.h"

@class SKTAnimatedLabel;
@class SKTInsetLabel;
@class SKTNavigationSpeedLimitView;
@class SKTNavigationDoubleLabelView;
@class SKTNavigationFreeDriveView;

/** Receives notifications about user interaction.
 */
@protocol SKTNavigationFreeDriveViewDelegate <NSObject>

@optional

/** Called when the user has pressed the positioner button.
 @param navigationFreeDriveView Free drive view where the press occured.
 @param positionerButton The button that has been pressed.
 */
- (void)navigationFreeDriveView:(SKTNavigationFreeDriveView *)navigationFreeDriveView didPressPositionerButton:(UIButton *)positionerButton;

@end

/** Displays information about the current street.
 */
@interface SKTNavigationFreeDriveView : SKTBaseView

/** SKTNavigationFreeDriveView's delegate.
 */
@property (nonatomic, assign) id <SKTNavigationFreeDriveViewDelegate> delegate;

/** Used to configure the SKTNavigationFreeDriveView for pedestrian or car navigation.
 */
@property (nonatomic, assign) SKTNavigationFreeDriveViewType navigationFreeDriveViewType;

/** Contains the current street name.
 */
@property (nonatomic, strong) SKTInsetLabel *streetLabel;

/** Animated wrapper for streetLabel.
 */
@property (nonatomic, strong) SKTAnimatedLabel *animatedLabel;

/** Displays the current speed limit.
 */
@property (nonatomic, strong) SKTNavigationSpeedLimitView *speedLimitView;

/** Current street type. Used to configure the view's colors.
 */
@property (nonatomic, assign) SKStreetType streetType;

/** Displays the current speed.
 */
@property (nonatomic, strong) SKTNavigationDoubleLabelView *speedView;

/** Positions the user to the current location.
 */
@property (nonatomic, strong) UIButton *positionerButton;

@end
