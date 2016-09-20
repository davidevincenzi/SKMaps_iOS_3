//
//  SKTNavigationDoubleLabelView.h
//  FrameworkIOSDemo
//

//

#import <UIKit/UIKit.h>

/** Helper view that contains 2 labels of equal size.
 */
@interface SKTNavigationDoubleLabelView : UIView

/** The top label of the view.
 */
@property (nonatomic, strong) UILabel *topLabel;

/** The bottom unit label of the view.
 */
@property (nonatomic, strong) UILabel *bottomLabel;

@end
