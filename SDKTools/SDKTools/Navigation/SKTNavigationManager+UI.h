//
//  SKTNavigationManager+UI.h
//  FrameworkIOSDemo
//

//

#import "SKTNavigationManager.h"

@class SKTNavigationDoubleLabelView;
@class SKTNavigationSpeedLimitView;

/** ID of the flag annotation used for the destination
 */
extern const int kFlagAnnotationIdentifier;

/**SKTNavigationManager+UI contains helpers for managing UI operations like hiding/showing views and updating the info in them
 */
@interface SKTNavigationManager (UI)

/** Returns the free drive speed view if in free drive else returns navigation speed view.
 */
@property (nonatomic, readonly) SKTNavigationDoubleLabelView *currentSpeedView;

/** Returns the free drive speed limit view if in free drive else returns navigation speed limit view.
 */
@property (nonatomic, readonly) SKTNavigationSpeedLimitView *currentSpeedLimitView;

/** Shows waiting GPS signal view.
 */
- (void)showWaitingGPSSignalUI;

/** Shows calculating route view.
 */
- (void)showCalculatingRouteUI;

/** Shows navigation views.
 */
- (void)showNavigationUI;

/** Shows free drive views.
 */
- (void)showFreeDriveUI;

/** Shows rerouting view.
 */
- (void)showReroutingUI;

/** Shows GPS dropped view.
 */
- (void)showGPSDroppedUI;

/** Shows panning mode UI elements.
 */
- (void)showPanningUI;

/** Shows settings view.
 */
- (void)showSettingsUI;

/** Shows block roads view.
 */
- (void)showBlockRoadsUI;

/** Shows overview view.
 */
- (void)showOverviewUI;

/** Shows route info UI.
 */
- (void)showRouteInfoUI;

/** Hides waiting GPS signal view.
 */
- (void)hideWaitingGPSSignalUI;

/** Hides calculating route view.
 */
- (void)hideCalculatingRouteUI;

/** Hidess navigation views.
 */
- (void)hideNavigationUI;

/** Hides free drive views.
 */
- (void)hideFreeDriveUI;

/** Hides rerouting view.
 */
- (void)hideReroutingUI;

/** Hides GPS dropped view.
 */
- (void)hideGPSDroppedUI;

/** Hides panning mode UI elements.
 */
- (void)hidePanningUI;

/** Hides settings view.
 */
- (void)hideSettingsUI;

/** Hides block roads view.
 */
- (void)hideBlockRoadsUI;

/** Hides overview.
 */
- (void)hideOverviewUI;

/** Hides route info UI.
 */
- (void)hideRouteInfoUI;

/** Updates speed view with current speed.
 */
- (void)updateSpeed;

/** Update speed limit view with current speed limit. If speed limit is less than 1 it will be hidden.
 */
- (void)updateSpeedLimit;

/** Updates speed unit label based on the current configuration.
 */
- (void)updateSpeedUnit;

/** Updates DTA view with current DTA.
 */
- (void)updateDTA;

/** Updates ETA view with current ETA.
 */
- (void)updateETA;

/** Updates sign for the visual advice.
 */
- (void)updateVisualAdviceSign;

/** Updates sign for the short visual advices.
 */
- (void)updateShortVisualAdviceSign;

/** Updates the route calculation views with the currently calculated route information.
 */
- (void)updateCalculatedRouteInformation;

/** Updates the info for the given route index.
  @param index Index of the route info view to be updated.
 */
- (void)updateCalculatedRouteInformationAtIndex:(NSInteger)index;

/** Shows waiting GPS signal view
 */
- (void)stopRouteCalculationProgress;

/** Zooms on the currently selected route to fit into the calculating route view.
 */
- (void)zoomOnSelectedRoute;

/** Adds a flag at the destination coordinate.
 */
- (void)addDestinationFlag;

/** Removes the flag from the destination coordinate.
 */
- (void)removeDestinationFlag;

/** Changes mapView display settings to be suitable for navigation. 
 */
- (void)setupNavigationDisplayMode;

/** Changes the positioner button image according to the follower mode.
 */
- (void)updatePositionerButtonImage;

/** Updates the map followUserPosition & headingMode for the followerMode option.
 */
- (void)configureMapFollowerMode;

@end
