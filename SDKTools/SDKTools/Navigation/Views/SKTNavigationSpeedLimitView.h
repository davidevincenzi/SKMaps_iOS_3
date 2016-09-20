//
//  SKTNavigationSpeedLimitView.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>

@class SKTProgressView;

@protocol SKTNavigationSpeedLimitViewDelegate;

/** Displays speed limit can blink a warning for the user when the speed limit is exceeded.
 */
@interface SKTNavigationSpeedLimitView : UIView

/** Speed limit view's delegate.
 */
@property(nonatomic, weak) id<SKTNavigationSpeedLimitViewDelegate> delegate;

/** A round background for the speed limit.
 */
@property(nonatomic, readonly) SKTProgressView *backgroundView;

/** The speed label of the speed limit view.
 */
@property(nonatomic, readonly) UILabel *speedLimitLabel;

/** Image to blink as warning when speed limit is exceeded.
 */
@property(nonatomic, readonly) UILabel *warningLabel;

/** Elable/disable speed limit warning.
 */
@property(nonatomic, assign) BOOL blinkWarning;

@end

/** Action listener for speed limit view
 */
@protocol SKTNavigationSpeedLimitViewDelegate <NSObject>

/** Called when the speed limit view is tapped. This is used to replay the audio advice when the user taps the view.
 @param speedLimitView The speed limit view that was tapped.
 */
- (void)speedLimitViewTapped:(SKTNavigationSpeedLimitView *)speedLimitView;

@end
