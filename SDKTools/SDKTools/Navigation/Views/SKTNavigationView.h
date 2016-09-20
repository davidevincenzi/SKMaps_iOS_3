//
//  SKTNavigationView.h
//  SDKTools
//

//

#import <UIKit/UIKit.h>

#import "SKTBaseView.h"

@class SKTNavigationView;
@class SKTNavigationSpeedLimitView;
@class SKTNavigationVisualAdviceView;
@class SKTNavigationDoubleLabelView;
@class SKTNavigationShortVisualAdviceView;
@class SKTNavigationETAView;

/** Receives notifications about user interaction.
 */
@protocol SKTNavigationViewDelegate <NSObject>

@optional

/** Called when the user has pressed the positioner button.
 @param navigationView Navigation view where the press occured.
 @param positionerButton The button that has been pressed.
 */
- (void)navigationView:(SKTNavigationView *)navigationView didPressPositionerButton:(UIButton *)positionerButton;

@end

/** Displays visual advices and navigation state information.
 */
@interface SKTNavigationView : SKTBaseView

/** SKTNavigationView's delegate.
 */
@property (nonatomic, assign) id <SKTNavigationViewDelegate> delegate;

/** Used to configure the SKTNavigationView for pedestrian or car navigation.
 */
@property (nonatomic, assign) SKTNavigationViewType navigationViewType;

/** Displays the current speed limit.
 */
@property (nonatomic, strong) SKTNavigationSpeedLimitView *speedLimitView;

/** Displays the current visual advices (street to take next).
 */
@property (nonatomic, strong) SKTNavigationVisualAdviceView *visualAdviceView;

/** Displays the next visual advice (street to take second next).
 */
@property (nonatomic, strong) SKTNavigationShortVisualAdviceView *shortAdviceView;

/** Displays the current speed.
 */
@property (nonatomic, strong) SKTNavigationDoubleLabelView *speedView;

/** Displays current distance to arrival.
 */
@property (nonatomic, strong) SKTNavigationDoubleLabelView *dtaView;

/** Displayes current estimated time to arrival.
 */
@property (nonatomic, strong) SKTNavigationETAView *etaView;

/** Positions the user to the current location.
 */
@property (nonatomic, strong) UIButton *positionerButton;

@end
