//
//  SKTNavigationInfoView.h
//  SDKTools
//

//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>

#import "SKTBaseView.h"

@protocol SKTNavigationInfoViewDelegate;

/** Displays information about the navigation.
 */
@interface SKTNavigationInfoView : SKTBaseView

/** The info view's delegate.
 */
@property (nonatomic, weak) id<SKTNavigationInfoViewDelegate> delegate;

/** Used to exit info view.
 */
@property (nonatomic, strong) UIButton *backButton;

/** Current location container.
 */
@property (nonatomic, strong) UIView *currentLocationInfoContainer;

/** Current location title.
 */
@property (nonatomic, strong) UILabel *currentLocationTitleLabel;

/** Current street.
 */
@property (nonatomic, strong) UILabel *currentStreetLabel;

/** Current city.
 */
@property (nonatomic, strong) UILabel *currentCityLabel;

/** Destination info container.
 */
@property (nonatomic, strong) UIView *destinationInfoContainer;

/** Destination title.
 */
@property (nonatomic, strong) UILabel *destinationTitleLabel;

/** Destination street.
 */
@property (nonatomic, strong) UILabel *destinationStreetLabel;

/** Destination city.
 */
@property (nonatomic, strong) UILabel *destinationCityLabel;

/** Current location.
 */
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

/** Navigation destination.
 */
@property (nonatomic, assign) CLLocationCoordinate2D destinationLocation;

@end

/** Receives notifications about user interaction.
 */
@protocol SKTNavigationInfoViewDelegate <NSObject>

/** Called when the user has pressed the back button.
 @param view The view that contains the button.
 */
- (void)navigationInfoViewDidClickBackButton:(SKTNavigationInfoView *)view;

@end
