//
//  NavigationView.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>
#import <SKMaps/SKMapView.h>

#import "SKTNavigationConstants.h"
#import "SKTBaseView.h"

@class SKTLostGPSSignalView;
@class SKTRouteProgressView;
@class SKTWaitingGPSSignalView;
@class SKTNavigationCalculatingRouteView;
@class SKTNavigationFreeDriveView;
@class SKTNavigationPanningView;
@class SKTReroutingInfoView;
@class SKTNavigationSettingsView;
@class SKTNavigationBlockRoadsView;
@class SKTNavigationOverviewView;
@class SKTNavigationInfoView;
@class SKTNavigationView;

/** This is the main view that contains all the navigation related UI elements and it's meant to be an overlay for the map view. SKTNavigationManager takes care of displaying the appropriate UI elements and updating them.
 */
@interface SKTMainView: SKTBaseView

/** View that is displayed while calculating the routes.
 */
@property (nonatomic, strong) SKTNavigationCalculatingRouteView *calculatingRouteView;

/** View that is displayd when navigation has not starte and GPS signal is bad.
 */
@property (nonatomic, strong) SKTWaitingGPSSignalView *waitingGPSView;

/** View that is displayed when navigation has started and GPS signal goes bad.
 */
@property (nonatomic, strong) SKTLostGPSSignalView *lostGPSSignalView;

/** Displays information while navigating.
 */
@property (nonatomic, strong) SKTNavigationView *navigationView;

/** View that is displayed when a rerouting occured.
 */
@property (nonatomic, strong) SKTReroutingInfoView *reroutingView;

/** Displays information while in free drive.
 */
@property (nonatomic, strong) SKTNavigationFreeDriveView *freeDriveView;

/** Contains controls used while in panning mode.
 */
@property (nonatomic, strong) SKTNavigationPanningView *panningView;

/** Contains various settings that the user can adjust while navigating.
 */
@property (nonatomic, strong) SKTNavigationSettingsView *settingsView;

/** Contains options to block roads for a certain distance or to unblock them. 
 */
@property (nonatomic, strong) SKTNavigationBlockRoadsView *blockRoadsView;

/** Contains information about navigation destination.
 */
@property (nonatomic, strong) SKTNavigationOverviewView *overviewView;

/** Contains information about current location and destination.
 */
@property (nonatomic, strong) SKTNavigationInfoView *routeInfoView;

@end
