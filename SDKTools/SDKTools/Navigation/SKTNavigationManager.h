//
//  NavigationManager.h
//  FrameworkIOSDemo
//

//

#import <Foundation/Foundation.h>

#import <SKMaps/SKRoutingDelegate.h>
#import <SKMaps/SKNavigationSettings.h>
#import <SKMaps/SKMapViewStyle.h>
#import <SKMaps/SKMapView.h>

#import "SKTNavigationConstants.h"
#import "SKTMainView.h"
#import "SKTNavigationConfiguration.h"
#import "SKTNavigationView.h"
#import "SKTNavigationFreeDriveView.h"

@class SKTAudioManager;
@class SKTNavigationInfo;
@class SKRouteState;

@protocol SKTNavigationManagerDelegate;

/** Manages the entire navigation logic and triggers UI updates accordingly.
 */
@interface SKTNavigationManager : NSObject

#pragma mark - Public properties

/** Used to send navigation notification.
 */
@property (nonatomic, weak) id <SKTNavigationManagerDelegate> delegate;

/** Provides access to the navigation UI container. This should be used as an overlay for the SKMapView.
 */
@property (nonatomic, readonly) SKTMainView *mainView;

/** This is the map view that was provided at initialization.
 */
@property (nonatomic, readonly) SKMapView *mapView;

/** Retains the configuration that was used to start the current navigation session.
 */
@property (nonatomic, readonly) SKTNavigationConfiguration *configuration;

/** Retains a SKTNavigationSettings object created using the given SKTNavigationConfiguration.
 */
@property (nonatomic, readonly) SKNavigationSettings *navigationSettings;

/** Tells whether a navigation or free drive session is currently in progress.
*/
@property (nonatomic, readonly) BOOL navigationStarted;

/** Tells whether the current session is free drive or not. isFreeDrive is NO if no session is currently in progress.
 */
@property (nonatomic, readonly) BOOL isFreeDrive;

/** State of the navigation.
 */
@property (nonatomic, strong) SKTNavigationInfo *navigationInfo;

/** Retains the route that the user selected from the calculating route screen.
 */
@property (nonatomic, readonly) SKRouteInformation *selectedRoute;

/** Retains all the calculated routes.
 */
@property (nonatomic, readonly) NSMutableArray *calculatedRoutes;

/** Tells whether the app is currently in background. It's used internally and should not be assigned, ever.
 */
@property (nonatomic, assign) BOOL isInBackground;

/** Provides acces to a class that manages playing a queue of sounds. It should not be used directly to play sounds but the volume can be changed at any time.
 */
@property (nonatomic, strong) SKTAudioManager *audioManager;

/** This is used as a stack to advance and return from a navigation state to another. It is managed by the NavigationState category and should not be interfered with externally. More info in NavigationState category.
 */
@property (nonatomic, strong) NSMutableArray *navigationStates;

/** This dictionary ontains color information loaded from SKColorSignPostConfig.plist and is used to color the views based on the current street and day/nght mode.
 */
@property (nonatomic, strong) NSDictionary *colorScheme;

/** The current active style.
 */
@property (nonatomic, strong) SKMapViewStyle *currentStyle;

/** Current blocked distance.
 */
@property (nonatomic, assign) double blockedRoadsDistance;

/** Volume before muting.
 */
@property (nonatomic, assign) float previousVolume;

/** Tells whether we received a day/night notification while in background.
 */
@property (nonatomic, assign) BOOL receivedDayNightNotificationInBackground;

/** Fires periodically to check for day/night change.
 */
@property (nonatomic, strong) NSTimer *dayNightTimer;

#pragma mark - Public methods

/** Initialized the manager with a mapView. mapView is used to render the calculated routes and is configured appropriately for navigation and free drive.
 @param mapView The map view to be used.
 */
- (id)initWithMapView:(SKMapView *)mapView;

/** Begins a new navigation if navigation is not currently in progress. When the user reaches its destination will switch automatically to free drive mode using the given configuration. Please note that all routes besides the main navigation route will be cleared. If you need those routes, please consider using the route caching API provided by the SKMaps framework.
 @param configuration A configuration object. See SKTNavigationConfiguration for available options.
 */
- (void)startNavigationWithConfiguration:(SKTNavigationConfiguration *)configuration;

/** Begins a free drive session if navigation is not currently in progress. Please note that all routes besides the main navigation route will be cleared. If you need those routes, please consider using the route caching API provided by the SKMaps framework. 
 @param configuration A configuration object. See SKTNavigationConfiguration for available options.
 */
- (void)startFreeDriveWithConfiguration:(SKTNavigationConfiguration *)configuration;

/** Cancels the current navigation session and stops the audio playback.
 */
- (void)stopNavigation;

/** Asks the user to confirm stopping the navigation.
 */
- (void)confirmStopNavigation;

#pragma mark - Protected methods

/** Stops with user quit reason.
 */
- (void)stopAfterUserQuit;

@end

/** Receives notifications about navigation.
 */
@protocol SKTNavigationManagerDelegate <NSObject>

/** Called when the navigation has ended.
 @param manager The manager that finished the navigation.
 @param reason What caused the navigation to stop.
 */
- (void)navigationManagerDidStopNavigation:(SKTNavigationManager *)manager withReason:(SKTNavigationStopReason)reason;

@end
