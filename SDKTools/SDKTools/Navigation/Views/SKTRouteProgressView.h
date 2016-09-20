//
//  SKTRouteProgressView.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>

/** Displays calculation progress for a single route. The progress is actually fake because route calculation does not have and eta.
 */
@interface SKTRouteProgressView : UIView

/** An activity indicator to animate while calculating the route.
 */
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

/** Displays the current calculation progress.
 */
@property (nonatomic, strong) UILabel *progressLabel;

/** Begins progress from 0.
 */
- (void)startProgress;

/** Resumes the progress update.
 */
- (void)resumeProgress;

/** Resets the progress to 0.
 */
- (void)resetProgress;

/** Stops progress update.
 */
- (void)stopProgress;

@end
