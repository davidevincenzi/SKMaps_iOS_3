//
//  SKTNavigationManager+Styles.h
//  FrameworkIOSDemo
//

//

#import "SKTNavigationManager.h"

/** Styles category manages the map style switching and UI color update based on the time of day if automatic day night switching is enabled.
 */
@interface SKTNavigationManager (Styles)

/** Starts listening for day/night local notifications.
 */
- (void)listenForDayNightChange;

/** Stops listening for day/night local notifications.
 */
- (void)stopListeningForDayNightChange;

/** Changes the style based on whether is night or not if the auto day/night is enabled. Enables day style if audo day/night is disabled.
 */
- (void)updateStyle;

/** Loads the color dicionary for day style and updates the view colors and map style.
 */
- (void)enableDayStyle;

/** Loads the color dicionary for night style and updates the view colors and map style.
 */
- (void)enableNightStyle;

/** Loads the appropriate color.
 */
- (void)updateColorDictionary;

@end
