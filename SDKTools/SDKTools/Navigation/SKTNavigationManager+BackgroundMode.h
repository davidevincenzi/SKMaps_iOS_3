//
//  SKTNavigationManager+BackgroundMode.h
//  FrameworkIOSDemo
//

//

#import "SKTNavigationManager.h"

/** BackgroundMode category manages stopping and resuming navigation and audio playback when entering background. This can be enabled or disabled in SKTNavigationConfiguration object.
 */
@interface SKTNavigationManager (BackgroundMode)

/** Begins listening for background notification.
 */
- (void)listenForBackgroundChanges;

/** Stops listening for background notification.
 */
- (void)stopListeningForBackgroundChanges;

@end
