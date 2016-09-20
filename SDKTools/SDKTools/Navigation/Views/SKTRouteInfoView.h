//
//  SKTRouteInfoView.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>

#import "SKTNavigationDoubleLabelView.h"

@protocol SKTRouteInfoViewDelegate;

/** Displays info about a calculated route.
 */
@interface SKTRouteInfoView : UIButton

/** The delegate is notified about user interaction.
 */
@property (nonatomic, weak) id<SKTRouteInfoViewDelegate> delegate;

/** Contains information about route length and estimated time.
 */
@property (nonatomic, strong) SKTNavigationDoubleLabelView *infoLabel;

@end

/** Receives notifications about user interaction.
 */
@protocol SKTRouteInfoViewDelegate <NSObject>

/** Called when the info view is tapped.
 @param view The view that is tapped.
 */
- (void)routeInfoViewClicked:(SKTRouteInfoView *)view;

@end

