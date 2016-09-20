//
//  SKTNavigationOverviewView.h
//  SDKTools
//

//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>

#import "SKTBaseView.h"

@protocol SKTNavigationOverviewViewDelegate;

/** Displays info about destination and shows an overview of the route.
 */
@interface SKTNavigationOverviewView : SKTBaseView

/** The route overview's delegate.
 */
@property (nonatomic, weak) id<SKTNavigationOverviewViewDelegate> delegate;

/** Used to exit overview mode.
 */
@property (nonatomic, strong) UIButton *backButton;

/** Container for destination labels.
 */
@property (nonatomic, strong) UIView *infoContainer;

/** Displays a title.
 */
@property (nonatomic, strong) UILabel *titleLabel;

/** Displays destination street.
 */
@property (nonatomic, strong) UILabel *streetLabel;

/** Displays destination city.
 */
@property (nonatomic, strong) UILabel *cityLabel;

/** Coordinate for which the info is displayed.
 */
@property (nonatomic, assign) CLLocationCoordinate2D destination;

@end

/** Receives notifications about user interaction.
 */
@protocol SKTNavigationOverviewViewDelegate <NSObject>

/** Called when the user has pressed the back button.
 @param view The view that contains the button.
 */
- (void)navigationOverviewViewDidClickBackButton:(SKTNavigationOverviewView *)view;

@end