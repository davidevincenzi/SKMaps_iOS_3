//
//  SKTNavigationManager+NavigationState.h
//  FrameworkIOSDemo
//

//

#import "SKTNavigationManager.h"
#import "SKTNavigationConstants.h"

/** NavigationState category is used to manage displaying views based on current navigation state. Ex. while navigating and the GPS signal drops, the GPS signal dropped state is pushed and the appropriate UI is displayed. When the GPS is good again we remove GPS dropped state which in turn will hide the UI and show the previous one.
*/
@interface SKTNavigationManager (NavigationState)

/** Clears the navigationStates stack and exits all current present states
 */
- (void)clearNavigationStates;

/** Returns the top of the stack
 */
- (SKTNavigationState)currentNavigationState;

/** Exits the current active state and pushes the given state on the stack
 @param state The state to be pushed
 */
- (void)pushNavigationState:(SKTNavigationState)state;

/** Exits the current active state and pushes the given state on the stack only if the state is not already on the stack.
 @param state The state to be pushed
 */
- (void)pushNavigationStateIfNotPresent:(SKTNavigationState)state;

/** Inserts the given state after another give state.
 @param state The state to be inserted.
 @param afterState The state to be inserted after.
 */
- (void)insertNavigationState:(SKTNavigationState)state afterState:(SKTNavigationState)afterState;

/** Inserts the given state at the bottom of the stack.
 @param state State to be inserted.
 */
- (void)insertStateAtBeginning:(SKTNavigationState)state;

/** Inserts the given state after another give state only if the state is not already on the stack.
 @param state The state to be inserted.
 @param afterState The state to be inserted after.
 */
- (void)insertNavigationStateIfNotPresent:(SKTNavigationState)state afterState:(SKTNavigationState)afterState;

/** Removes and exits the current active state and enters the previous one
 */
- (SKTNavigationState)popNavigationState;

/** Removes the state from the stack even if it's not active
  @param state State to be removed.
 */
- (void)removeState:(SKTNavigationState)state;

/** Tells whether the given state exists on the stack
  @param state The state to be searched.
 */
- (BOOL)hasState:(SKTNavigationState)state;

@end
