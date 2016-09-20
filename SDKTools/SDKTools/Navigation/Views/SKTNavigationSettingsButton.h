//
//  SKTNavigationSettingsButton.h
//  SDKTools
//

//

#import <UIKit/UIKit.h>

@class SKTNavigationDoubleLabelView;

/** Custom button for navigation settings.
 */
@interface SKTNavigationSettingsButton : UIButton

/** Labels for this button.
 */
@property (nonatomic, strong) SKTNavigationDoubleLabelView *infoLabelView;

/** The container for the button's image.
 */
@property (nonatomic, strong) UIImageView *customImageView;

/** Factory helper method.
 @param image Image of the button.
 @param topText Text of the top label.
 @param bottomText Text of the bottom label.
 */
+ (instancetype)settingsButtonWithImage:(UIImage *)image topText:(NSString *)topText bottomText:(NSString *)bottomText;

@end
