//
//  SKTNavigationCalculatingRouteView.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>

#import "SKTRouteProgressView.h"
#import "SKTRouteInfoView.h"
#import "SKTBaseView.h"

@protocol SKTNavigationCalculatingRouteViewDelegate;

/** Contains information about route calculation.
 */
@interface SKTNavigationCalculatingRouteView : SKTBaseView

/** Used to send user actions.
 */
@property (nonatomic, weak) id <SKTNavigationCalculatingRouteViewDelegate> delegate;

/** Number of route info views to be displayed.
 */
@property (nonatomic, assign) NSInteger numberOfRoutes;

/** Contains numberOfRoutes progress views.
 */
@property (nonatomic, readonly) NSMutableArray *progressViews;

/** Contains numberOfRoutes info views.
 */
@property (nonatomic, readonly) NSMutableArray *infoViews;

/** Gets or sets the currently selected route.
    The info view at this index will be highlighted if there are more than one views.
 */
@property (nonatomic, assign) NSInteger selectedInfoIndex;

/** Allows the user to start navigation.
 */
@property (nonatomic, strong) UIButton *startButton;

/** Contains the top views (route progress, route info, separators).
 */
@property (nonatomic, strong) UIView *container;

/** View shown behind the status bar
 */
@property (nonatomic, strong) UIView *statusBarView;

/** Shows the route info view for at the given index.
 @param index Index of the view to be shown.
 */
- (void)showInfoViewAtIndex:(NSInteger)index;

/** Shows all the info views.
 */
- (void)showInfoViews;

/** Shows the route progress view for at the given index.
 @param index Index of the view to be shown.
 */
- (void)showProgressViewAtIndex:(NSInteger)index;

/** Shows all the progress views.
 */
- (void)showProgressViews;

@end

/** Used to receive user actions.
 */
@protocol SKTNavigationCalculatingRouteViewDelegate <NSObject>

/** Called when the user selected a route.
 @param view The SKTNavigationCalculatingRouteView that sends this message.
 @param index Index of the selected route.
 */
- (void)calculatingRouteView:(SKTNavigationCalculatingRouteView *)view didSelectRouteAtIndex:(NSInteger)index;

/** Called when the user wants to start the navigation with the currently selected route.
 @param view The SKTNavigationCalculatingRouteView that sends this message.
 */
- (void)calculatingRouteViewStartClicked:(SKTNavigationCalculatingRouteView *)view;

@end
