//
//  SKTNavigationManager+UI.m
//  FrameworkIOSDemo
//

//

#import <SKMaps/SKRouteInformation.h>
#import <SKMaps/SKRoutingService.h>
#import <SKMaps/SKAnnotation.h>
#import <SKMaps/SKAnimationSettings.h>
#import <SKMaps/SKPositionerService.h>
#import <SKMaps/SKRouteState.h>

#import "SKTNavigationManager+UI.h"
#import "SKTNavigationUtils.h"
#import "SKTNavigationManager+NavigationState.h"
#import "SKTNavigationManager+Settings.h"
#import "SKTNavigationManager+Factories.h"
#import "SKTMainView.h"
#import "SKTWaitingGPSSignalView.h"
#import "SKTLostGPSSignalView.h"
#import "SKTRouteProgressView.h"
#import "SKTNavigationSpeedLimitView.h"
#import "SKTNavigationDoubleLabelView.h"
#import "SKTNavigationETAView.h"
#import "SKTNavigationDoubleLabelView.h"
#import "SKTInsetLabel.h"
#import "SKTNavigationVisualAdviceView.h"
#import "SKTNavigationShortVisualAdviceView.h"
#import "SKTNavigationCalculatingRouteView.h"
#import "SKTReroutingInfoView.h"
#import "SKTNavigationFreeDriveView.h"
#import "SKTNavigationPanningView.h"
#import "SKTNavigationSettingsView.h"
#import "SKTAnimatedLabel.h"
#import "SKTNavigationConfiguration.h"
#import "SKTNavigationOverviewView.h"
#import "SKTNavigationView.h"
#import "SKTNavigationBlockRoadsView.h"
#import "SKTNavigationInfoView.h"
#import "SKTNavigationInfo.h"

const int kFlagAnnotationIdentifier = 1923141;

//rerouting
#define kReroutingHeight ([UIDevice isiPad] ? 120.0 : 85.0)
//gps lost signal
#define kLostGPSSignalViewHeight ([UIDevice isiPad] ? 120 : 85.0)

@interface SKTNavigationManager () <SKTNavigationSettingsViewDelegate, SKTNavigationPanningViewDelegate, SKTNavigationOverviewViewDelegate, SKTWaitingGPSSignalViewDelegate>

@end

@implementation SKTNavigationManager (UI)

- (void)showWaitingGPSSignalUI {
    SKTWaitingGPSSignalView *view = [[SKTWaitingGPSSignalView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.mainView.frameWidth, self.mainView.frameHeight)];
    view.delegate = self;
    view.active = YES;
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.mainView.waitingGPSView = view;
    [self.mainView insertSubview:view atIndex:0];
}

- (void)showCalculatingRouteUI {
    self.mainView.calculatingRouteView.hidden = NO;
    self.mainView.calculatingRouteView.active = YES;
}

- (void)showNavigationUI {
    SKTNavigationView *navigationView = self.mainView.navigationView;
    navigationView.navigationViewType = [SKTNavigationUtils navigationViewTypeFromRouteMode:self.configuration.routeType];
    navigationView.hidden = NO;
    navigationView.active = YES;
    navigationView.visualAdviceView.active = YES;
	navigationView.speedLimitView.hidden = (self.navigationInfo.currentSpeedLimit > 1.0 ? NO : YES);
	[self updateSpeed];
    [self updateSpeedUnit];
	[self updateSpeedLimit];
    [self updatePositionerButtonImage];
}

- (void)showFreeDriveUI {
    self.mainView.freeDriveView.navigationFreeDriveViewType = [SKTNavigationUtils navigationFreeDriveViewTypeFromRouteMode:self.configuration.routeType];
    self.mainView.freeDriveView.hidden = NO;
    self.mainView.freeDriveView.active = YES;
    [self updateSpeedLimit];
    [self updateSpeed];
    [self updateSpeedUnit];
    [self updatePositionerButtonImage];
}

- (void)showReroutingUI {
    SKTReroutingInfoView *view = [[SKTReroutingInfoView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.mainView.frameWidth, kReroutingHeight)];
    view.active = YES;
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.mainView insertSubview:view atIndex:0];
	self.mainView.reroutingView = view;
}

- (void)showGPSDroppedUI {
    SKTLostGPSSignalView *view = [[SKTLostGPSSignalView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.mainView.frameWidth, kLostGPSSignalViewHeight)];
    view.active = YES;
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.mainView.lostGPSSignalView = view;
    [self.mainView insertSubview:view atIndex:0];
}

- (void)showPanningUI {
    SKTNavigationPanningView *view = [[SKTNavigationPanningView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.mainView.frameWidth, self.mainView.frameHeight)];
    view.active = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.mainView addSubview:view];
    self.mainView.panningView = view;
    view.delegate = self;
}

- (void)showSettingsUI {
    SKTNavigationSettingsView *view = [[SKTNavigationSettingsView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.mainView.frameWidth, self.mainView.frameHeight)];
    view.active = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.mainView addSubview:view];
    self.mainView.settingsView = view;
    if (self.isFreeDrive) {
        view.settingsButtons = [self buttonsForFreeDrive];
        view.portraitNumberOfColumns = 2;
        view.landscapeNumberOfColumns = 3;
    } else {
        view.settingsButtons = [self buttonsForNavigation];
        view.portraitNumberOfColumns = 2;
        view.landscapeNumberOfColumns = 4;
    }
    view.delegate = self;
}

- (void)showBlockRoadsUI {
    SKTNavigationBlockRoadsView *view = [[SKTNavigationBlockRoadsView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.mainView.frameWidth, self.mainView.frameHeight)];
    view.active = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.mainView addSubview:view];
    self.mainView.blockRoadsView = view;
}

- (void)showOverviewUI {
    SKTNavigationOverviewView *view = [[SKTNavigationOverviewView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.mainView.frameWidth, self.mainView.frameHeight)];
    view.active = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mainView.overviewView = view;
    [self.mainView addSubview:view];
    view.destination = self.configuration.destination;
    view.delegate = self;
}

- (void)showRouteInfoUI {
    SKTNavigationInfoView *view = [[SKTNavigationInfoView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.mainView.frameWidth, self.mainView.frameHeight)];
    view.active = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.mainView addSubview:view];
    self.mainView.routeInfoView = view;
}

- (void)hideWaitingGPSSignalUI {
    [self.mainView.waitingGPSView removeFromSuperview];
	self.mainView.waitingGPSView = nil;
}

- (void)hideCalculatingRouteUI {
//	[self.mainView.calculatingRouteView removeFromSuperview];
//    self.mainView.calculatingRouteView = nil;
    self.mainView.calculatingRouteView.hidden = YES;
    self.mainView.active = NO;
}

- (void)hideNavigationUI {
    self.mainView.navigationView.hidden = YES;
    self.mainView.navigationView.active = NO;
}

- (void)hideFreeDriveUI {
	self.mainView.freeDriveView.hidden = YES;
    self.mainView.freeDriveView.active = NO;
}

- (void)hideReroutingUI {
    [self.mainView.reroutingView removeFromSuperview];
	self.mainView.reroutingView = nil;
}

- (void)hideGPSDroppedUI {
	[self.mainView.lostGPSSignalView removeFromSuperview];
    self.mainView.lostGPSSignalView = nil;
}

- (void)hidePanningUI {
    [self.mainView.panningView removeFromSuperview];
    self.mainView.panningView = nil;
}

- (void)hideSettingsUI {
    [self.mainView.settingsView removeFromSuperview];
    self.mainView.settingsView = nil;
}

- (void)hideBlockRoadsUI {
    [self.mainView.blockRoadsView removeFromSuperview];
    self.mainView.blockRoadsView = nil;
}

- (void)hideOverviewUI {
    [self.mainView.overviewView removeFromSuperview];
    self.mainView.overviewView = nil;
}

- (void)hideRouteInfoUI {
    [self.mainView.routeInfoView removeFromSuperview];
    self.mainView.routeInfoView = nil;
}

- (void)updateSpeed {
	//convert from m/s to km/h or mph according to configuration
	//the measurement unit is updated only once, when navigation starts
    int speed = [SKTNavigationUtils convertSpeed:self.navigationInfo.currentSpeed toFormat:self.configuration.distanceFormat];
	self.currentSpeedView.topLabel.text = [NSString stringWithFormat:@"%d", speed];
}

- (void)updateSpeedLimit {
    SKTNavigationSpeedLimitView *view = self.currentSpeedLimitView;
	if (self.navigationInfo.currentSpeedLimit > 1.0 && ([self currentNavigationState] == SKTNavigationStateFreeDrive || [self currentNavigationState] == SKTNavigationStateNavigating)) {
		//convert from m/s to km/h or mph according to configuration
		//the measurement unit is updated only once, when navigation starts
		int speed = (int)roundf(self.navigationInfo.currentSpeedLimit * (self.configuration.distanceFormat == SKDistanceFormatMetric ? kSKTMPSToKMPH : kSKTMPSToMPH));
		view.speedLimitLabel.text = [NSString stringWithFormat:@"%d", speed];
		view.hidden = (self.navigationInfo.currentSpeedLimit > 1.0 ? NO : YES);
	} else {
		view.hidden = YES;
	}
}

- (void)updateSpeedUnit {
    SKTNavigationDoubleLabelView *speedView = self.currentSpeedView;
	NSString *unit = (self.configuration.distanceFormat == SKDistanceFormatMetric ? @"km/h" : @"mph");
	speedView.bottomLabel.text = unit;
}

- (SKTNavigationSpeedLimitView *)currentSpeedLimitView {
    return (self.isFreeDrive ? self.mainView.freeDriveView.speedLimitView : self.mainView.navigationView.speedLimitView);
}

- (SKTNavigationDoubleLabelView *)currentSpeedView {
    return (self.isFreeDrive ? self.mainView.freeDriveView.speedView : self.mainView.navigationView.speedView);
}

- (void)updateDTA {
	NSString *formattedDistance = [SKTNavigationUtils formattedDistanceWithDistance:self.navigationInfo.currentDTA format:self.configuration.distanceFormat];
    SKTNavigationDoubleLabelView *dtaView = self.mainView.navigationView.dtaView;
	NSArray *components = [formattedDistance componentsSeparatedByString:@" "];
	dtaView.topLabel.text = components[0];
	dtaView.bottomLabel.text = components[1];
}

- (void)updateETA  {
	self.mainView.navigationView.etaView.timeToArrival = self.navigationInfo.currentETA;
}

- (void)updateVisualAdviceSign {
    SKTNavigationVisualAdviceView *adviceView = self.mainView.navigationView.visualAdviceView;
    if (self.navigationInfo.firstAdvice) {
        if (self.navigationInfo.firstAdviceIsLast) {
            NSString *imageName = self.colorScheme[[SKTNavigationUtils destinationImageNameForStreetType:self.navigationInfo.nextStreetType]];
            imageName = [@"Icons/DestinationImages" stringByAppendingPathComponent:imageName];
            adviceView.signImageView.image = [UIImage navigationImageNamed:imageName];
        } else {
            SKVisualAdviceConfiguration *config = [self configurationForStreetType:self.navigationInfo.nextStreetType];
            adviceView.signImageView.image = [[SKRoutingService sharedInstance] visualAdviceImageForRouteAdvice:self.navigationInfo.firstAdvice color:config];
        }
    } else {
        adviceView.signImageView.image = nil;
    }
}

- (void)updateShortVisualAdviceSign {
    SKTNavigationShortVisualAdviceView *adviceView = self.mainView.navigationView.shortAdviceView;
    
    if (self.navigationInfo.secondaryAdvice) {
        SKVisualAdviceConfiguration *config = [self configurationForStreetType:self.navigationInfo.secondNextStreetType];
        adviceView.signImageView.image = [[SKRoutingService sharedInstance] visualAdviceImageForRouteAdvice:self.navigationInfo.secondaryAdvice color:config];
    } else {
        adviceView.signImageView.image = nil;
    }
    
    if (adviceView.signImageView.image) {
        adviceView.hidden = NO;
        if (self.navigationInfo.nextAdviceIsLast) {
            NSString *imageName = self.colorScheme[[SKTNavigationUtils destinationImageNameForStreetType:self.navigationInfo.secondNextStreetType]];
            imageName = [@"Icons/DestinationImages" stringByAppendingPathComponent:imageName];
            adviceView.signImageView.image = [UIImage navigationImageNamed:imageName];
        }
    } else {
        adviceView.hidden = YES;
    }
}

- (void)updateCalculatedRouteInformation {
	//it's possible that not all alternatives were calculated, so we remove the extra info views
	self.mainView.calculatingRouteView.numberOfRoutes = self.calculatedRoutes.count;
	for (int i = 0; i < self.calculatedRoutes.count; i++) {
		[self updateCalculatedRouteInformationAtIndex:i];
	}

	NSInteger index = [self.calculatedRoutes indexOfObject:self.selectedRoute];
	//we highlight the selected route only if we have more than one route
	if (self.calculatedRoutes.count > 1) {
		self.mainView.calculatingRouteView.selectedInfoIndex = index;
	} else {
		self.mainView.calculatingRouteView.selectedInfoIndex = -1;
	}
}

- (void)updateCalculatedRouteInformationAtIndex:(NSInteger)index {
	SKTRouteInfoView *infoView = self.mainView.calculatingRouteView.infoViews[index];
	SKRouteInformation *route = self.calculatedRoutes[index];

	infoView.infoLabel.bottomLabel.text = [SKTNavigationUtils formattedDistanceWithDistance:route.distance format:self.configuration.distanceFormat];
	if (route.estimatedTime > 60) {
		infoView.infoLabel.topLabel.text = [SKTNavigationUtils formattedTimeForTime:route.estimatedTime];
	} else {
		infoView.infoLabel.topLabel.text = NSLocalizedString(kSKTLessThanAMinuteKey, nil);
	}
}

- (void)stopRouteCalculationProgress {
	for (SKTRouteProgressView *view in self.mainView.calculatingRouteView.progressViews) {
		[view stopProgress];
		[view resetProgress];
	}
}

- (void)zoomOnSelectedRoute {
    if ([UIDevice isiPad]) {
        [[SKRoutingService sharedInstance] zoomToRouteWithInsets:UIEdgeInsetsMake(200.0, 200.0, 200.0, 200.0) duration:500];
    } else {
        [[SKRoutingService sharedInstance] zoomToRouteWithInsets:UIEdgeInsetsMake(90.0, 30.0, 70.0, 30.0) duration:500];
    }
}

- (void)addDestinationFlag {
    SKAnnotation *annotation = [SKAnnotation annotation];
    annotation.annotationType = SKAnnotationTypeDestinationFlag;
    annotation.location = self.configuration.destination;
    annotation.identifier = kFlagAnnotationIdentifier;
    
    SKAnimationSettings *animationSettings = [SKAnimationSettings animationSettings];
    [self.mapView addAnnotation:annotation withAnimationSettings:animationSettings];
}

- (void)removeDestinationFlag {
    [self.mapView removeAnnotationWithID:kFlagAnnotationIdentifier];
}

- (void)setupNavigationDisplayMode {
    [self configureMapFollowerMode];
    self.mapView.settings.displayMode = self.prefferedDisplayMode;
    
    if (self.configuration.routeType == SKRoutePedestrian) {
        self.mapView.settings.displayMode = SKMapDisplayMode2D;
    }
    SKCoordinateRegion region;
    region.center = [SKPositionerService sharedInstance].currentCoordinate;
    region.zoomLevel = 16.83;
    self.mapView.visibleRegion = region;
}

- (void)configureMapFollowerMode {
    switch (self.prefferedFollowerMode) {
        case SKMapFollowerModeNone:
        {
            self.mapView.settings.followUserPosition = NO;
            self.mapView.settings.headingMode = SKHeadingModeNone;
            
            break;
        }
        case SKMapFollowerModePosition:
        {
            self.mapView.settings.followUserPosition = YES;
            self.mapView.settings.headingMode = SKHeadingModeRotatingHeading;
            
            break;
        }
        case SKMapFollowerModeHistoricPosition:
        {
            self.mapView.settings.followUserPosition = YES;
            self.mapView.settings.headingMode = SKHeadingModeHistoricPositions;
            
            break;
        }
        case SKMapFollowerModePositionPlusHeading:
        {
            self.mapView.settings.followUserPosition = YES;
            self.mapView.settings.headingMode = SKHeadingModeRotatingMap;
            
            break;
        }
        case SKMapFollowerModeNavigation:
        {
            self.mapView.settings.followUserPosition = YES;
            self.mapView.settings.headingMode = SKHeadingModeRoute;
            
            break;
        }
        case SKMapFollowerModeNoneWithHeading:
        {
            self.mapView.settings.followUserPosition = NO;
            self.mapView.settings.headingMode = SKHeadingModeRoute;
            
            break;
        }
            
        default:
            break;
    }
}

- (void)updatePositionerButtonImage {
    if (self.isFreeDrive && self.configuration.routeType == SKRoutePedestrian) {
        [self updatePositionerButtonImageForButton:self.mainView.freeDriveView.positionerButton];
    } else {
        [self updatePositionerButtonImageForButton:self.mainView.navigationView.positionerButton];
    }
}

- (void)updatePositionerButtonImageForButton:(UIButton *)button {
    switch (self.prefferedFollowerMode) {
        case SKMapFollowerModeHistoricPosition:
            [button setImage:[UIImage navigationImageNamed:@"Pedestrian/icon_historical_positions.png"] forState:UIControlStateNormal];
            break;
        case SKMapFollowerModePositionPlusHeading:
            [button setImage:[UIImage navigationImageNamed:@"Pedestrian/icon_compass.png"] forState:UIControlStateNormal];
            break;
        case SKMapFollowerModePosition:
            [button setImage:[UIImage navigationImageNamed:@"Pedestrian/icon_north_oriented.png"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

@end
