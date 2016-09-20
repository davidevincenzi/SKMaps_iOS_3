//
//  SKTNavigationPanningView.h
//  SDKTools
//

//

#import <UIKit/UIKit.h>

#import "SKTBaseView.h"

@protocol SKTNavigationPanningViewDelegate;

/** Displays useful controls while in panning mode.
 */
@interface SKTNavigationPanningView : SKTBaseView

/** Panning view's delegate
 */
@property (nonatomic, weak) id<SKTNavigationPanningViewDelegate> delegate;

/** Used to exit panning mode.
 */
@property (nonatomic, strong) UIButton *panningBackButton;

/** Allows the user to center on his current position while in panning mode.
 */
@property (nonatomic, strong) UIButton *centerButton;

/** Allows the user to zoom in on the map while in panning mode.
 */
@property (nonatomic, strong) UIButton *zoomInButton;

/** Allows the user to zoom out on the map while in panning mode.
 */
@property (nonatomic, strong) UIButton *zoomOutButton;

@end

/** Reveives notifications when user taps one of the buttons.
 */
@protocol SKTNavigationPanningViewDelegate <NSObject>

/** Called when the user has pressed the back button.
 @param view The view that contains the button.
 */
-(void)panningViewDidClickBackButton:(SKTNavigationPanningView *)view;

/** Called when the user has pressed the center on current position button.
 @param view The view that contains the button.
 */
-(void)panningViewDidClickCenterButton:(SKTNavigationPanningView *)view;

/** Called when the user has pressed the zoom in button.
 @param view The view that contains the button.
 */
-(void)panningViewDidClickZoomInButton:(SKTNavigationPanningView *)view;

/** Called when the user has pressed the zoom out button.
 @param view The view that contains the button.
 */
-(void)panningViewDidClickZoomOutButton:(SKTNavigationPanningView *)view;

@end
