//
//  SKTNavigationETAView.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>

#import "SKTNavigationConstants.h"

@class SKTNavigationDoubleLabelView;

/** SKTNavigationETAView displays the time to arrival or arrival time. Tapping on the view will switch between the two modes.
 */
@interface SKTNavigationETAView : UIView

/** Contains the measurement unit and estimated time.
 */
@property (nonatomic, strong) SKTNavigationDoubleLabelView *infoView;

/** Sets the estimated arrival time in seconds. The label is updated when this property changes
 */
@property (nonatomic, assign) int timeToArrival;

/** Format of the time (12 or 24h).
 */
@property (nonatomic, assign) SKTNavigationTimeFormat timeFormat;

@end
