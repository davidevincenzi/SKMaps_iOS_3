//
//  SKTNavigationSettingsView.h
//  SDKTools
//

//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MPVolumeView.h>

#import "SKTNavigationConstants.h"
#import "SKTBaseView.h"

@protocol SKTNavigationSettingsViewDelegate;

/** Displays different options for customizing navigation.
 */
@interface SKTNavigationSettingsView : SKTBaseView

/** Settings view's delegate.
 */
@property (nonatomic, weak) id<SKTNavigationSettingsViewDelegate> delegate;

/** Used to exit settings.
 */
@property (nonatomic, strong) UIButton *backButton;

/** Container for volume slider and volume label.
 */
@property (nonatomic, strong) UIView *volumeContainer;

/** Volume slider.
 */
@property (nonatomic, strong) MPVolumeView *volumeView;

/** Dummy volume slider used to allow the user to mute the sound.
 */
@property (nonatomic, strong) UISlider *volumeSlider;

/** Volume label.
 */
@property (nonatomic, strong) UILabel *volumeLabel;

/** Settings buttons.
 */
@property (nonatomic, strong) NSArray *settingsButtons;

/** Number of rows to use for the buttons when displaying in portrait.
 */
@property (nonatomic, assign) NSUInteger portraitNumberOfColumns;

/** Number of rows to use for the buttons when displaying in landscape.
 */
@property (nonatomic, assign) NSUInteger landscapeNumberOfColumns;

@end

/** Receives notifications about user interaction.
 */
@protocol SKTNavigationSettingsViewDelegate <NSObject>

/** Called when the user has pressed the back button.
 @param view The view that contains the button.
 */
- (void)navigationSettingsViewDidClickBackButton:(SKTNavigationSettingsView *)view;

@end
