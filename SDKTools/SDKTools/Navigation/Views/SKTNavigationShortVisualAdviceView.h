//
//  SKTNavigationShortVisualAdvice.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>
#import <SKMaps/SKDefinitions.h>

#import "SKTBaseView.h"

@class SKTNavigationDoubleLabelView;
@class SKTAnimatedLabel;

/** Used to display information about second next street.
 */
@interface SKTNavigationShortVisualAdviceView : SKTBaseView

/** Second next turn sign.
 */
@property (nonatomic, strong) UIImageView *signImageView;

/** Displays distance to the turn.
 */
@property (nonatomic, strong) SKTNavigationDoubleLabelView *dtaView;

/** Distance remaining until the indicated turn.
 */
@property (nonatomic, strong) NSString *distanceToTurn;

/** The advice street type.
 */
@property (nonatomic, assign) SKStreetType streetType;

/** Second next street animated label.
 */
@property (nonatomic, strong) SKTAnimatedLabel *streetLabel;

@end
