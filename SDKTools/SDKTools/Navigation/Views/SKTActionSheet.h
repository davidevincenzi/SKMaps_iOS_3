//
//  SKTActionSheet.h
//  SDKTools
//

//

#import <UIKit/UIKit.h>

@protocol SKTActionSheetDelegate;

/** Displays multiple action options to the user.
 */
@interface SKTActionSheet : UIView

/** Action sheet's delegate.
 */
@property (nonatomic, weak) id<SKTActionSheetDelegate> delegate;

/** The index of the cancel button.
 */
@property (nonatomic, readonly) NSUInteger cancelButtonIndex;

/** Shows the action sheet in the given view.
 @param view The view that will contain the action sheet.
 */
- (void)showInView:(UIView *)view;

/** Dismisses the action sheet with animation.
 */
- (void)dismiss;

/** Dismisses the action sheet without animation.
 */
- (void)dismissInstantly;

/** Factory method. Creates a new action sheet with the given cancel and action titles.
 @param buttonTitles The titles of the action buttons.
 @param cancelButtonTitle The title of the cancel button.
 */
+ (instancetype)actionSheetWithButtonTitles:(NSArray *)buttonTitles cancelButtonTitle:(NSString *)cancelButtonTitle;

@end

/** Receives notifications about user interaction.
 */
@protocol SKTActionSheetDelegate <NSObject>

/** Called when a button has been pressed.
 @param actionSheet The action sheet that contains the button.
 @param index Index of the button that has bee pressed.
 */
- (void)actionSheet:(SKTActionSheet *)actionSheet didSelectButtonAtIndex:(NSUInteger)index;

@optional

/** Called when the user presses the cancel button or taps outside the button area.
 @param actionSheet The action sheet that was dismissed.
 */
- (void)actionSheetDidDismiss:(SKTActionSheet *)actionSheet;

@end
