//
//  SKTNavigationSettings.h
//  FrameworkIOSDemo
//

//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <SKMaps/SKDefinitions.h>
#import <SKMaps/SKMapViewStyle.h>
#import <SKMaps/SKRouteInformation.h>

#import "SKTNavigationConstants.h"

/** Provides customization options for navigation and free drive.
 */
@interface SKTNavigationConfiguration : NSObject

/** Target navigation coordinate. Default is (0, 0).
 */
@property (nonatomic, assign) CLLocationCoordinate2D destination;

/** Pre calculated route to be used for navigation. If this property is not nil, the navigation will be made on this route.
 */
@property (nonatomic, strong) SKRouteInformation *routeInfo;

/** Desired route type. Default is SKRouteCarEfficient.
 */
@property (nonatomic, assign) SKRouteMode routeType;

/** A list of SKViaPoint. The route will be calculated so that it will pas through these points.
 */
@property (nonatomic, strong) NSArray *viaPoints;

/** Number of routes to calculate. Not all routes will not be shown if they are too similar. Default is 3.
 */
@property (nonatomic, assign) NSUInteger numberOfRoutes;

/** Desired distance format.
 */
@property (nonatomic, assign) SKDistanceFormat distanceFormat;

/** Desired speed difference at which to play audio warning for speed limit while inside a city. The measurement unit is given by the distanceFormat. For SKDistanceFormatMetric this is considered km/h, for SKDistanceFormatMilesFeet and SKDistanceFormatMilesYards is mph. Default is 20.
 */
@property (nonatomic, assign) double speedLimitWarningThresholdInCity;

/** Desired speed difference at which to play audio warning for speed limit while outside a city. The measurement unit is given by the distanceFormat. For SKDistanceFormatMetric this is considered km/h, for SKDistanceFormatMilesFeet and SKDistanceFormatMilesYards is mph. Default is 20.
 */
@property (nonatomic, assign) double speedWarningThresholdOutsideCity;

/** Allow or forbid audio playback and location updates while the app is in background. Default is YES.
 */
@property (nonatomic, assign) BOOL allowBackgroundNavigation;

/** Enables rendering of street names as pop-ups instead of flat strings on the ground. Default is YES.
 */
@property (nonatomic, assign) BOOL showStreetNamesAsPopUps;

/** Enables automatic style switching according to time of day. Default is YES.
 */
@property (nonatomic, assign) BOOL automaticDayNight;

/** Desired style to use during the day. Only used when automaticDayNight is enabled. Default is daystyle.json.
 */
@property (nonatomic, strong) SKMapViewStyle *dayStyle;

/** Desired style to use during the night. Only used when automaticDayNight is enabled. Default is nightstyle.json.
 */
@property (nonatomic, strong) SKMapViewStyle *nightStyle;

/** Desired language of audio advices. Default is en_us.
 */
@property (nonatomic, assign) SKAdvisorLanguage advisorLanguage;

/** Uses text to speech audio advices instead of sound files.
 */
@property (nonatomic, assign) BOOL useTTSAdvisor;

/** Enables audio playback during calls. Default is YES.
 */
@property (nonatomic, assign) BOOL playAudioDuringCall;

/** Prevents the device to go into standby after a long period of user inactivity. Default is YES.
 */
@property (nonatomic, assign) BOOL preventStandBy;

/** Avoid routes containing toll roads. Default is NO.
 */
@property (nonatomic, assign) BOOL avoidTollRoads;

/** Avoid routes containing highways. Default is NO.
 */
@property (nonatomic, assign) BOOL avoidHighways;

/** Avoid routes containing ferries. Default is NO.
 */
@property (nonatomic, assign) BOOL avoidFerries;

/** If this property is YES, free drive will be automatically started after reaching the destination. Default is YES.
 */
@property (nonatomic, assign) BOOL continueFreeDriveAfterNavigationEnd;

/** Desired navigation type. Useful for debugging. Default is SKTNavigationTypeReal.
 */
@property (nonatomic, assign) SKNavigationType navigationType;

/** Replays the path stored in the given log when navigationType is SKTNavigationTypeSimulationFromLogFile.
 */
@property (nonatomic, strong) NSString *simulationLogPath;

/** Desired start coordinate. Used when navigationType is SKTNavigationTypeSimulation. Default is current location.
 */
@property (nonatomic, assign) CLLocationCoordinate2D startCoordinate;

/** Returns an instance of SKTNavigationConfiguration with default values.
 */
+ (instancetype)defaultConfiguration;

/** Returns a copy of the configuration.
 */
- (instancetype)duplicate;

@end
