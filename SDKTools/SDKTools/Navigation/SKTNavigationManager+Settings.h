//
//  SKTNavigationManager+Settings.h
//  SDKTools
//.

//

#import "SKTNavigationManager.h"

@interface SKTNavigationManager (Settings)

/** Display mode chosen by the user.
 */
@property (nonatomic, assign) SKMapDisplayMode prefferedDisplayMode;

/** Follower mode chosen by the user.
 */
@property (nonatomic, assign) SKMapFollowerMode prefferedFollowerMode;

/** Returns the buttons used for free drive settings.
 */
- (NSArray *)buttonsForFreeDrive;

/** Returns the buttons used for navigation settings.
 */
- (NSArray *)buttonsForNavigation;

/** Updates the volume button and slider.
 */
- (void)updateVolumeUI;

@end
