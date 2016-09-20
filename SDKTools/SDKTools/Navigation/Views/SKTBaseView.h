//
//  SKTBaseView.h
//  SDKTools
//

//

#import <UIKit/UIKit.h>

#import "SKTNavigationConstants.h"

@protocol SKTBaseViewDelegate;

/** Base class that contains properties and implements behaviour used by the navigation UI.
 */
@interface SKTBaseView : UIView

/** SKTBaseView's delegate.
 */
@property (nonatomic, weak) id<SKTBaseViewDelegate> baseViewDelegate;

/** Vertical offset for the subviews. Default is 0.0. This property is propagated recursively to all subviews that are subclasses of SKTBaseView.
 */
@property (nonatomic, assign) CGFloat contentYOffset;

/** Desired layout orientation. Default is portrait. This property is propagated recursively to all subviews that are subclasses of SKTBaseView.
 */
@property (nonatomic, assign) SKTUIOrientation orientation;

/** Ignores the touches that occur in this view but not in it's subviews. Default is NO.
 */
@property (nonatomic, assign, getter = isTouchTransparent) BOOL touchTransparent;

/** Enables or disables showing the views under the status bar. You should set it to YES when displaying the view fullscreen on iOS 7. This property is propagated recursively to all subviews that are subclasses of SKTBaseView. Default is NO.
 */
@property (nonatomic, assign) BOOL isUnderStatusBar;

/** Tells whether the content of the view appears under the status bar. Default is NO.
 */
@property (nonatomic, assign) BOOL hasContentUnderStatusBar;

/** Contains the colors used by the UI. This property is propagated recursively to all subviews that are subclasses of SKTBaseView.
 */
@property (nonatomic, strong) NSDictionary *colorScheme;

/** Tells whether this view is currently the visible view in the navigation stack. Default is NO.
 */
@property (nonatomic, assign, getter = isActive) BOOL active;

/** Protected method. Called when the status bar style should be updated. (isUnderStatusBar, colorScheme, hasContentUnderStatusBar or active has changed).
 */
- (void)updateStatusBarStyle;

@end

/** Used by the base view to request setting the status bar style.
 */
@protocol SKTBaseViewDelegate <NSObject>

/** Sets requests the status bar style to changed.
 @param view The view that requests this style.
 @param style The desired style.
 */
- (void)baseView:(SKTBaseView *)view requiresStatusBarStyle:(UIStatusBarStyle)style;

@end
