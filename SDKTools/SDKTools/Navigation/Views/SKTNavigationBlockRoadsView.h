//
//  SKTNavigationBlockRoadsView.h
//  SDKTools
//

//

#import <UIKit/UIKit.h>

#import "SKTBaseView.h"

@protocol SKTNavigationBlockRoadsViewDelegate;

/** Displays a list of options for the user to block roads.
 */
@interface SKTNavigationBlockRoadsView : SKTBaseView

/** Block roads' view delegate.
 */
@property (nonatomic, weak) id<SKTNavigationBlockRoadsViewDelegate> delegate;

/** Used to exit block roads.
 */
@property (nonatomic, strong) UIButton *backButton;

/** Datasource for table. Contains an array of strings.
 */
@property (nonatomic, strong) NSArray *datasource;

@end

/** Receives notifications about user interaction.
 */
@protocol SKTNavigationBlockRoadsViewDelegate <NSObject>

/** Called when the user has pressed the back button.
 @param view The view that contains the button.
 */
- (void)blockRoadsViewDidPressBackButton:(SKTNavigationBlockRoadsView *)view;

/** Called when the user selects an item from the table view.
 @param view The view that contains the button.
 @param index Index of the selected item.
 */
- (void)blockRoadsView:(SKTNavigationBlockRoadsView *)view didSelectIndex:(NSUInteger)index;

@end