//
//  SKTNavigationManager+NavigationState.m
//  FrameworkIOSDemo
//

//

#import <SKMaps/SKPositionerService.h>
#import <SKMaps/SKRoutingService.h>

#import "SKTNavigationManager+NavigationState.h"
#import "SKTNavigationManager+UI.h"
#import "SKTNavigationManager+Settings.h"
#import "SKTNavigationOverviewView.h"
#import "SKTNavigationInfoView.h"
#import "SKTMainView.h"
#import "SKTNavigationConfiguration.h"

@implementation SKTNavigationManager (NavigationState)

- (void)clearNavigationStates {
	//clean up all existing states
	for (NSNumber *state in[self.navigationStates reverseObjectEnumerator]) {
		[self exitState:[state intValue]];
	}

	[self.navigationStates removeAllObjects];
}

- (SKTNavigationState)currentNavigationState {
	if (self.navigationStates.count > 0) {
		return [[self.navigationStates lastObject] intValue];
	} else {
		return SKTNavigationStateNone;
	}
}

- (void)pushNavigationState:(SKTNavigationState)state {
	if ([self.navigationStates lastObject]) {
		[self exitState:[[self.navigationStates lastObject] intValue]];
	}

	[self.navigationStates addObject:@(state)];
	[self enterState:state];
}

- (void)pushNavigationStateIfNotPresent:(SKTNavigationState)state {
    if (![self hasState:state]) {
        [self pushNavigationState:state];
    }
}

- (void)insertNavigationState:(SKTNavigationState)state afterState:(SKTNavigationState)afterState {
    if ([self currentNavigationState] == afterState) {
        [self pushNavigationState:state];
    } else {
        NSUInteger index = [self.navigationStates indexOfObject:@(afterState)];
        if (index != NSNotFound) {
            [self.navigationStates insertObject:@(state) atIndex:index + 1];
        }
    }
}

- (void)insertStateAtBeginning:(SKTNavigationState)state {
    [self.navigationStates insertObject:@(state) atIndex:0];
    if (self.navigationStates.count == 1) {
        [self enterState:state];
    }
}

- (void)insertNavigationStateIfNotPresent:(SKTNavigationState)state afterState:(SKTNavigationState)afterState {
    if (![self hasState:state]) {
        [self insertNavigationState:state afterState:afterState];
    }
}

- (SKTNavigationState)popNavigationState {
	SKTNavigationState currentState = SKTNavigationStateNone;
	if (self.navigationStates.count > 0) {
		currentState = [[self.navigationStates lastObject] intValue];
		[self exitState:currentState];
		[self.navigationStates removeLastObject];

		if (self.navigationStates.count > 0) {
			[self enterState:[[self.navigationStates lastObject] intValue]];
		}
	}

	return currentState;
}

- (void)removeState:(SKTNavigationState)state {
	//if the state to be removed is the current state we use the pop logic to transition to the previous one
	if ([[self.navigationStates lastObject] intValue] == state) {
		[self popNavigationState];
	} else {
		if ([self.navigationStates containsObject:@(state)]) {
			[self exitState:state];
		}

		[self.navigationStates removeObject:@(state)];
	}
}

- (BOOL)hasState:(SKTNavigationState)state {
	return [self.navigationStates containsObject:@(state)];
}

- (void)enterState:(SKTNavigationState)state {
	switch (state) {
		case SKTNavigationStateCalculatingRoute:
			[self enterRouteCalculationState];
			break;

		case SKTNavigationStateFreeDrive:
			[self enterFreeDriveState];
			break;

		case SKTNavigationStateWaitingForGPS:
			[self enterWaitingGPSState];
			break;

		case SKTNavigationStateGPSDropped:
			[self enterGPSDroppedState];
			break;

		case SKTNavigationStateNavigating:
			[self enterNavigationState];
			break;

		case SKTNavigationStateRerouting:
			[self enterReroutingState];
			break;

        case SKTNavigationStatePanning:
            [self enterPanningState];
            break;
            
        case SKTNavigationStateSettings:
            [self enterSettingsState];
            break;
            
        case SKTNavigationStateBlockRoads:
            [self enterBlockRoadsState];
            break;
            
        case SKTNavigationStateOverview:
            [self enterOverviewState];
            break;
            
        case SKTNavigationStateRouteInfo:
            [self enterRouteInfoState];
            break;
            
		default:
			break;
	}
}

- (void)exitState:(SKTNavigationState)state {
	switch (state) {
		case SKTNavigationStateCalculatingRoute:
			[self exitRouteCalculationState];
			break;

		case SKTNavigationStateFreeDrive:
			[self exitFreeDriveState];
			break;

		case SKTNavigationStateWaitingForGPS:
			[self exitWaitingGPSState];
			break;

		case SKTNavigationStateGPSDropped:
			[self exitGPSDroppedState];
			break;

		case SKTNavigationStateNavigating:
			[self exitNavigationState];
			break;

		case SKTNavigationStateRerouting:
			[self exitReroutingState];
			break;
            
        case SKTNavigationStatePanning:
            [self exitPanningState];
            break;
            
        case SKTNavigationStateSettings:
            [self exitSettingsState];
            break;
            
        case SKTNavigationStateBlockRoads:
            [self exitBlockRoadsState];
            break;
            
        case SKTNavigationStateOverview:
            [self exitRouteOverviewState];
            break;
            
        case SKTNavigationStateRouteInfo:
            [self exitRouteInfoState];
            break;
            
		default:
			break;
	}
}

- (void)enterRouteCalculationState {
	[self showCalculatingRouteUI];
}

- (void)enterFreeDriveState {
	[self showFreeDriveUI];
    [self setupNavigationDisplayMode];
}

- (void)enterNavigationState {
	[self showNavigationUI];
    [self setupNavigationDisplayMode];
}

- (void)enterReroutingState {
	[self showReroutingUI];
}

- (void)enterWaitingGPSState {
	[self showWaitingGPSSignalUI];
}

- (void)enterGPSDroppedState {
	[self showGPSDroppedUI];
    [self setupNavigationDisplayMode];
}

- (void)enterPanningState {
    [self showPanningUI];
    
    self.mapView.settings.followUserPosition = NO;
    self.mapView.settings.displayMode = SKMapDisplayMode2D;
}

- (void)enterSettingsState {
    [self showSettingsUI];
}

- (void)enterBlockRoadsState {
    [self showBlockRoadsUI];
}

- (void)enterOverviewState {
    [self showOverviewUI];
    self.mapView.settings.displayMode = SKMapDisplayMode2D;
    self.mapView.settings.followUserPosition = NO;
    self.mapView.settings.headingMode = SKHeadingModeNone;
    self.mapView.bearing = 0.0;
    [[SKRoutingService sharedInstance] zoomToRouteWithInsets:UIEdgeInsetsMake(170.0,
	                                                                          30.0,
	                                                                          20.0,
	                                                                          30.0)
                                                    duration:500];
}

- (void)enterRouteInfoState {
    [self showRouteInfoUI];
    SKTNavigationInfoView *infoView = self.mainView.routeInfoView;
    SKPosition pos = [[SKPositionerService sharedInstance] currentMatchedPosition];
    infoView.currentLocation = CLLocationCoordinate2DMake(pos.latY, pos.lonX);
    if (self.isFreeDrive) {
        infoView.destinationInfoContainer.hidden = YES;
        infoView.destinationTitleLabel.hidden = YES;
    } else {
        infoView.destinationLocation = self.configuration.destination;
        infoView.destinationInfoContainer.hidden = NO;
        infoView.destinationTitleLabel.hidden = NO;
    }
}

- (void)exitRouteCalculationState {
	[self hideCalculatingRouteUI];
}

- (void)exitFreeDriveState {
	[self hideFreeDriveUI];
}

- (void)exitNavigationState {
	[self hideNavigationUI];
}

- (void)exitReroutingState {
	[self hideReroutingUI];
}

- (void)exitWaitingGPSState {
	[self hideWaitingGPSSignalUI];
}

- (void)exitGPSDroppedState {
	[self hideGPSDroppedUI];
}

- (void)exitPanningState {
    [self hidePanningUI];
    [self setupNavigationDisplayMode];
}

- (void)exitSettingsState {
    [self hideSettingsUI];
}

- (void)exitBlockRoadsState {
    [self hideBlockRoadsUI];
}

- (void)exitRouteOverviewState {
    [self hideOverviewUI];
}

- (void)exitRouteInfoState {
    [self hideRouteInfoUI];
}

@end
