//
//  SKTNavigationManager+Factories.h
//  FrameworkIOSDemo
//

//

#import <SKMaps/SKRouteSettings.h>
#import <SKMaps/SKAdvisorSettings.h>

#import "SKTNavigationManager.h"

@class SKTNavigationConfiguration;
@class SKVisualAdviceConfiguration;

@interface SKTNavigationManager (Factories)

/** Creates an SKRouteSettings object to be used when calculating routes for navigation.
  @param configuration The navigation settings.
 */
+ (SKRouteSettings *)routeSettingsForConfiguration:(SKTNavigationConfiguration *)configuration;

/** Returns a dictionary with colors for current country and day/night mode and country code.
 @param country Country code.
 @param night Tells if to load the night version.
 */
+ (NSDictionary *)colorConfigDictionaryForCountry:(NSString *)country night:(BOOL)night;

/** Creates a SKAdvisorSettings object configured for audio file playback the given language.
 @param language Desired language.
 */
+ (SKAdvisorSettings *)audioAdvisorSettingsForLanguage:(SKAdvisorLanguage)language;

/** Creates SKAdvisorSettings object configured for TTS playback with the given language.
 @param language Desired language.
 */
+ (SKAdvisorSettings *)ttsAudioAdvisorSettingsForLanguage:(SKAdvisorLanguage)language;

/** Loads the visual advice configuration from the color dictionary based on currentCountryCode and day/night mode.
 */
- (NSArray *)visualAdviceConfiguration;

/** Returns an SKVisualAdviceConfiguration configured with colors from the colorScheme for the given street type.
 @param streetType The street type
 */
- (SKVisualAdviceConfiguration *)configurationForStreetType:(SKStreetType)streetType;

@end
