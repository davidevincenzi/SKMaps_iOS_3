//
//  SKTNavigationVisualAdviceView.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>
#import <SKMaps/SKDefinitions.h>

#import "SKTNavigationConstants.h"
#import "SKTBaseView.h"

@class SKTAnimatedLabel;

@protocol SKTNavigationVisualAdviceViewDelegate;

/** Used to display turn advices for the user.
 */
@interface SKTNavigationVisualAdviceView : SKTBaseView

/** Visual advice view's delegate
 */
@property (nonatomic, weak) id<SKTNavigationVisualAdviceViewDelegate> delegate;

/** Name of the next street.
 */
@property (nonatomic, strong) SKTAnimatedLabel *streetLabel;

/** Distance to the next turn.
 */
@property (nonatomic, strong) UILabel *distanceLabel;

/** The exit to be taken.
 */
@property (nonatomic, strong) UILabel *exitNumberLabel;

/** Separator between exit label and street label when in landscape.
 */
@property (nonatomic, strong) UILabel *separatorLabel;

/** The next turn sign.
 */
@property (nonatomic, strong) UIImageView *signImageView;

/** The advice street type.
 */
@property (nonatomic, assign) SKStreetType streetType;

@end

/** Receives notifications about user interaction.
 */
@protocol SKTNavigationVisualAdviceViewDelegate <NSObject>

/** Called when the user taps the view.
 @param view The view that the user taps.
 */
- (void)visualAdviceViewTapped:(SKTNavigationVisualAdviceView *)view;

@end
