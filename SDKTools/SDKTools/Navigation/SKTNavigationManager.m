//
//  NavigationManager.m
//  FrameworkIOSDemo
//

//

#import <SKMaps/SKRoutingService.h>
#import <SKMaps/SKNavigationSettings.h>
#import <SKMaps/SKPositionerService.h>
#import <SKMaps/SKRouteSettings.h>
#import <SKMaps/SKRouteInformation.h>
#import <SKMaps/SKMapScaleView.h>
#import <SKMaps/SKAdvisorSettings.h>
#import <SKMaps/SKRouteState.h>
#import <SKMaps/SKTrailSettings.h>
#import <SKMaps/SKVisualAdviceConfiguration.h>

#import <AVFoundation/AVAudioSession.h>

#import "SKTNavigationManager.h"
#import "SKTNavigationManager+Factories.h"
#import "SKTNavigationManager+UI.h"
#import "SKTNavigationManager+NavigationState.h"
#import "SKTNavigationManager+Styles.h"
#import "SKTNavigationManager+BackgroundMode.h"
#import "SKTNavigationManager+Settings.h"
#import "SKTNavigationView.h"
#import "SKTNavigationConfiguration.h"
#import "SKTAudioManager.h"
#import "SKTNavigationConstants.h"
#import "SKTNavigationUtils.h"
#import "SKTAudioManager.h"
#import "Reachability.h"
#import "SKTNavigationView.h"
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
#import "SKTMainView.h"
#import "SKTNavigationInfo.h"
#import "SKTActionSheet.h"

const NSTimeInterval kMinReroutingDisplayTime = 3.0;

typedef NS_ENUM(NSUInteger, SKTNavigationAlert) {
    SKTNavigationAlertQuit
};

@interface SKTNavigationManager () <SKNavigationDelegate, SKRoutingDelegate, SKPositionerServiceDelegate, SKTWaitingGPSSignalViewDelegate, SKTNavigationSpeedLimitViewDelegate, SKTNavigationCalculatingRouteViewDelegate, UIAlertViewDelegate, SKMapViewDelegate, SKTNavigationPanningViewDelegate, SKTNavigationSettingsViewDelegate, SKTNavigationVisualAdviceViewDelegate, SKTActionSheetDelegate, SKTBaseViewDelegate, SKTNavigationFreeDriveViewDelegate, SKTNavigationViewDelegate>

@property (nonatomic, assign) float previousMapBearing;
@property (nonatomic, assign) BOOL previousIdleTimerDisabled;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) SKTActionSheet *activeActionSheet;
//if this is SKTNavigationStateFreeDrive or SKTNavigationStateNavigating navigation will start after gps signal is good.
@property (nonatomic, assign) SKTNavigationState pendingNavigationState;

@end

@implementation SKTNavigationManager

@synthesize isFreeDrive = _isFreeDrive;

#pragma mark - Lifecycle

- (id)initWithMapView:(SKMapView *)mapView {
    self = [super init];

    if (self) {
        _mapView = mapView;
        _mainView = [[SKTMainView alloc] initWithFrame:_mapView.frame];
        _mainView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _mainView.waitingGPSView.delegate = self;
        _mainView.navigationView.speedLimitView.delegate = self;
        _mainView.freeDriveView.speedLimitView.delegate = self;
        _mainView.settingsView.delegate = self;
        _mainView.navigationView.visualAdviceView.delegate = self;

        _navigationStates = [NSMutableArray array];
        _calculatedRoutes = [NSMutableArray array];
        _navigationInfo = [[SKTNavigationInfo alloc] init];

        _audioManager = [[SKTAudioManager alloc] init];
        
        _pendingNavigationState = SKTNavigationStateNone;

        [[AVAudioSession sharedInstance] addObserver:self forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew context:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }

    return self;
}

- (void)dealloc {
    _alertView.delegate = nil;
    [self stopListeningForDayNightChange];
    [self stopListeningForBackgroundChanges];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume"];
}

#pragma mark - Public properties

- (BOOL)isFreeDrive {
    return [self hasState:SKTNavigationStateFreeDrive];
}

- (void)setColorScheme:(NSDictionary *)colorScheme {
    _colorScheme = colorScheme;
    _mainView.colorScheme = colorScheme;
    
    [self updateShortVisualAdviceSign];
    [self updateVisualAdviceSign];
}

#pragma mark - Navigation functions

- (void)startNavigationWithConfiguration:(SKTNavigationConfiguration *)configuration {
    if ([self currentNavigationState] != SKTNavigationStateNone) {
        return;
    }
    
    if ([SKPositionerService sharedInstance].gpsAccuracyLevel == SKGPSAccuracyLevelBad) {
        _configuration = [configuration duplicate];
        _navigationInfo.currentCountryCode = [SKTNavigationUtils currentCountryCode];
        [self updateColorDictionary];
        self.pendingNavigationState = SKTNavigationStateNavigating;
        [SKPositionerService sharedInstance].delegate = self;
        [self checkGPS];
        return;
    }
    
    _pendingNavigationState = SKTNavigationStateNone;
        
    [self listenForBackgroundChanges];
    _configuration = [configuration duplicate];

    [self clearNavigation];
    _navigationInfo.currentCountryCode = [SKTNavigationUtils currentCountryCode];
    [self updateColorDictionary];
    [SKRoutingService sharedInstance].visualAdviceConfigurations = [self visualAdviceConfiguration];

    [self enableDelegates:YES];
    
    [self setupAudioAdvisor];
    
    [self updateSpeedUnit];
    [self addDestinationFlag];
    
    SKTNavigationCalculatingRouteView *view = [[SKTNavigationCalculatingRouteView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.mainView.frameWidth, self.mainView.frameHeight)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.configuration.routeType == SKRoutePedestrian) {
        [view.startButton setTitle:NSLocalizedString(kSKTStartPedestrianKey, nil) forState:UIControlStateNormal];
    }
    
    [self.mainView addSubview:view];
    self.mainView.calculatingRouteView = view;
    self.mainView.calculatingRouteView.delegate = self;
    [self pushNavigationState:SKTNavigationStateCalculatingRoute];

    if (_configuration.routeInfo) {
        _calculatedRoutes = [NSMutableArray arrayWithObject:_configuration.routeInfo];
        _selectedRoute = _configuration.routeInfo;
        [SKRoutingService sharedInstance].mainRouteId = _selectedRoute.routeID;
        [self zoomOnSelectedRoute];
        
        //prepare route calculation progress views
        _mainView.calculatingRouteView.numberOfRoutes = 1;
        [_mainView.calculatingRouteView showInfoViews];
        [self updateCalculatedRouteInformation];
    } else {
        //prepare route calculation progress views
        _mainView.calculatingRouteView.numberOfRoutes = _configuration.numberOfRoutes;
         SKTRouteProgressView *progressView = _mainView.calculatingRouteView.progressViews[0];
        [progressView startProgress];
        [_mainView.calculatingRouteView showProgressViews];
        _mainView.calculatingRouteView.startButton.hidden = YES;
        
        //calculate the routes first
        SKRouteSettings *settings = [SKTNavigationManager routeSettingsForConfiguration:configuration];
        [[SKRoutingService sharedInstance] calculateRoute:settings];
    }
}

- (void)startFreeDriveWithConfiguration:(SKTNavigationConfiguration *)configuration {
    if ([self currentNavigationState] != SKTNavigationStateNone) {
        return;
    }
    
    if ([SKPositionerService sharedInstance].gpsAccuracyLevel == SKGPSAccuracyLevelBad) {
        _configuration = [configuration duplicate];
        _navigationInfo.currentCountryCode = [SKTNavigationUtils currentCountryCode];
        [self updateColorDictionary];
        self.pendingNavigationState = SKTNavigationStateFreeDrive;
        [SKPositionerService sharedInstance].delegate = self;
        [self checkGPS];
        return;
    }
    
    _pendingNavigationState = SKTNavigationStateNone;
    
    _configuration = [configuration duplicate];
    [SKRoutingService sharedInstance].mainRouteId = 0;
    _navigationInfo.currentCountryCode = [SKTNavigationUtils currentCountryCode];
    [self updateColorDictionary];
    [SKRoutingService sharedInstance].visualAdviceConfigurations = [self visualAdviceConfiguration];

    _mainView.freeDriveView.hidden = YES;
    [self enableDelegates:YES];
    [self clearNavigation];
    [self listenForDayNightChange];
    [self listenForBackgroundChanges];
    [self setupAudioAdvisor];
    [self updateSpeedUnit];

    _navigationStarted = YES;
    
    _mainView.freeDriveView.animatedLabel.hidden = YES;
    [self pushNavigationState:SKTNavigationStateFreeDrive];
    [self startNavigationWithCurrentConfiguration];
    
    //push free drive mode
    [self updateStyle];
    [self checkGPS];
}

- (void)startFreeDriveAfterNavigation {
    [self removeState:SKTNavigationStateNavigating];

    [SKRoutingService sharedInstance].mainRouteId = 0;
    [[SKRoutingService sharedInstance] clearCurrentRoutes];
    [[SKRoutingService sharedInstance] startNavigationWithSettings:_navigationSettings];
    [self removeDestinationFlag];
    [self insertStateAtBeginning:SKTNavigationStateFreeDrive];
    [self checkGPS];
}

- (void)beginNavigating {
    [self updateStyle];
    [self listenForDayNightChange];
    [self stopRouteCalculationProgress];
    [[SKRoutingService sharedInstance] clearRouteAlternatives];

    [self removeState:SKTNavigationStateCalculatingRoute];

    _navigationInfo.currentDTA = _selectedRoute.distance;
    [self updateDTA];
    _navigationInfo.currentETA = _selectedRoute.estimatedTime;
    [self updateETA];

    [self startNavigationWithCurrentConfiguration];

    _navigationStarted = YES;

    [self pushNavigationState:SKTNavigationStateNavigating];
    [self checkGPS];
}

- (void)stopNavigation {
    [self stopNavigationWithReason:SKTNavigationStopReasonNone stopAudio:YES];
}

- (void)stopNavigationWithReason:(SKTNavigationStopReason)reason stopAudio:(BOOL)stopAudio {
    [UIApplication sharedApplication].idleTimerDisabled = self.previousIdleTimerDisabled;
    [self clearNavigation];
    [self stopListeningForDayNightChange];
    [self stopListeningForBackgroundChanges];
    [self removeDestinationFlag];
    [self enableDelegates:NO];
    
    _pendingNavigationState = SKTNavigationStateNone;
    
    [_activeActionSheet removeFromSuperview];
    _activeActionSheet = nil;
    
    _alertView.delegate = nil;
    _alertView = nil;

    if (stopAudio) {
        [_audioManager cancel];
    }

    _navigationStarted = NO;
    self.mapView.settings.showCompass = NO;
    
    if (self.isFreeDrive && _configuration.navigationType == SKNavigationTypeSimulationFromLogFile && _configuration.simulationLogPath && [_configuration.simulationLogPath isNotEmptyOrWhiteSpace]) {
        [[SKPositionerService sharedInstance] startPositionReplayFromLog:_configuration.simulationLogPath];
    }

    if ([self.delegate respondsToSelector:@selector(navigationManagerDidStopNavigation:withReason:)]) {
        [self.delegate navigationManagerDidStopNavigation:self withReason:reason];
    }

}

- (void)confirmStopNavigation {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(kSKTConfirmQuitKey, nil)
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(kSKTNoKey, nil)
                                          otherButtonTitles:NSLocalizedString(kSKTYesKey, nil), nil];
    alert.tag = SKTNavigationAlertQuit;
    [alert show];
}

- (void)stopAfterUserQuit {
    [self stopNavigationWithReason:SKTNavigationStopReasonUserQuit stopAudio:YES];
}

- (void)clearNavigation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeReroutingState) object:nil];
    [self clearNavigationStates];
    [self stopListeningForDayNightChange];
    [self.mainView.calculatingRouteView removeFromSuperview];
    self.mainView.calculatingRouteView = nil;

    if (_configuration.routeInfo) {
        [[SKRoutingService sharedInstance] clearRouteAlternatives];
    } else {
        [[SKRoutingService sharedInstance] clearCurrentRoutes];
    }
    self.mapView.settings.trailSettings = nil;
    [_navigationInfo reset];

    _mainView.navigationView.speedLimitView.blinkWarning = NO;

    _mapView.settings.displayMode = SKMapDisplayMode2D;
    _mapView.settings.followUserPosition = NO;
    _mapView.settings.headingMode = SKHeadingModeNone;
    _mapView.bearing = _previousMapBearing;

    [[SKRoutingService sharedInstance] stopNavigation];

    _navigationInfo.currentCountryCode = nil;
    _selectedRoute = nil;
    _mainView.navigationView.visualAdviceView.exitNumberLabel.hidden = YES;
    _mainView.navigationView.visualAdviceView.exitNumberLabel.text = @"";
    [_calculatedRoutes removeAllObjects];
    [SKRoutingService sharedInstance].mainRouteId = 0;
    _navigationStarted = NO;
}

- (void)startNavigationWithCurrentConfiguration {
    self.previousIdleTimerDisabled = [UIApplication sharedApplication].idleTimerDisabled;
    [UIApplication sharedApplication].idleTimerDisabled = _configuration.preventStandBy;
    [self updateSpeedUnit];
    _mapView.settings.showStreetNamePopUps = _configuration.showStreetNamesAsPopUps;
    _mapView.settings.displayMode = self.prefferedDisplayMode;
    
    [self configureMapFollowerMode];
    
    _mainView.navigationView.delegate = self;
    _mainView.freeDriveView.delegate = self;
    _audioManager.playAudioDuringCalls = _configuration.playAudioDuringCall;
    _blockedRoadsDistance = 0;

    _navigationSettings = [SKNavigationSettings navigationSettings];
    _navigationSettings.distanceFormat = _configuration.distanceFormat;
    _navigationSettings.navigationType = _configuration.navigationType;
    _navigationSettings.transportMode = [SKTNavigationUtils transportModeFromRouteMode:_configuration.routeType];
    
    [[SKPositionerService sharedInstance] startLocationUpdate];
    [SKPositionerService sharedInstance].worksInBackground = _configuration.allowBackgroundNavigation;
    
    if (_configuration.distanceFormat == SKDistanceFormatMetric) {
        SKSpeedWarningThreshold speedWarningThreshold = _navigationSettings.speedWarningThreshold;
        speedWarningThreshold.inCity = _configuration.speedLimitWarningThresholdInCity / kSKTMPSToKMPH;
        speedWarningThreshold.outsideCity = _configuration.speedWarningThresholdOutsideCity / kSKTMPSToKMPH;
        _navigationSettings.speedWarningThreshold = speedWarningThreshold;
    } else {
        SKSpeedWarningThreshold speedWarningThreshold = _navigationSettings.speedWarningThreshold;
        speedWarningThreshold.inCity = _configuration.speedLimitWarningThresholdInCity / kSKTMPSToMPH;
        speedWarningThreshold.outsideCity = _configuration.speedWarningThresholdOutsideCity / kSKTMPSToMPH;
        _navigationSettings.speedWarningThreshold = speedWarningThreshold;
    }

    if (self.configuration.routeType == SKRoutePedestrian) {
        SKTrailSettings *trailSettings = [SKTrailSettings trailSettings];
        trailSettings.enablePedestrianTrail = YES;
        trailSettings.pedestrianTrailSmoothLevel = 1;
        _mapView.settings.trailSettings = trailSettings;
        _mapView.settings.displayMode = SKMapDisplayMode2D;
        self.mapView.settings.showCompass = YES;
        self.mapView.settings.compassOffset = CGPointMake(0.0, 120.0);
        
        SKSpeedWarningThreshold speedWarningThreshold = _navigationSettings.speedWarningThreshold;
        speedWarningThreshold.inCity = 9999;
        speedWarningThreshold.outsideCity = 9999;
        _navigationSettings.speedWarningThreshold = speedWarningThreshold;
    }
    
    if (self.isFreeDrive && _configuration.navigationType == SKNavigationTypeSimulationFromLogFile && _configuration.simulationLogPath && [_configuration.simulationLogPath isNotEmptyOrWhiteSpace]) {
        [[SKPositionerService sharedInstance] startPositionReplayFromLog:_configuration.simulationLogPath];
    }
    
//    SKVisualAdviceConfiguration *visualAdviceConfiguration = [[SKVisualAdviceConfiguration alloc] init];
//    visualAdviceConfiguration.countryCode = @"";
//    visualAdviceConfiguration.allowedStreetColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
//    visualAdviceConfiguration.forbiddenStreetColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
//    
//    NSArray *array = @[visualAdviceConfiguration];
//    [SKRoutingService sharedInstance].visualAdviceConfigurations = array;
    [[SKRoutingService sharedInstance] startNavigationWithSettings:_navigationSettings];
    NSArray *routeAdviceList = [[SKRoutingService sharedInstance] routeAdviceListWithDistanceFormat:_navigationSettings.distanceFormat];
    for (SKRouteAdvice *advice in routeAdviceList) {
        NSLog(@"Advice id: %d", advice.adviceID);
    }
}

- (void)checkGPS {
    //if GPS is bad push waiting GPS mode
    if ([[SKPositionerService  sharedInstance] gpsAccuracyLevel] == SKGPSAccuracyLevelBad) {
        [self pushNavigationStateIfNotPresent:SKTNavigationStateWaitingForGPS];
    }
}

- (void)enableDelegates:(BOOL)enable {
    [SKRoutingService sharedInstance].mapView = (enable ? _mapView : nil);
    id delegate = (enable ? self : nil);
    [SKRoutingService sharedInstance].navigationDelegate = delegate;
    [SKRoutingService sharedInstance].routingDelegate = delegate;
    _mapView.delegate = delegate;

    [SKPositionerService sharedInstance].delegate = delegate;
    
    if (!_mainView.baseViewDelegate && enable) {
        _mainView.baseViewDelegate = self;
    }
}

- (void)setupAudioAdvisor {
    if (_configuration.useTTSAdvisor) {
        [SKRoutingService sharedInstance].advisorConfigurationSettings = [SKTNavigationManager ttsAudioAdvisorSettingsForLanguage:_configuration.advisorLanguage];
    } else {
        _audioManager.audioFilesFolderPath = [SKTNavigationUtils audioFilesFolderPathForLanguage:_configuration.advisorLanguage];
        [SKRoutingService sharedInstance].advisorConfigurationSettings = [SKTNavigationManager audioAdvisorSettingsForLanguage:_configuration.advisorLanguage];
    }
}

#pragma mark - SKRoutingDelegate methods

- (void)routingService:(SKRoutingService *)routingService didFinishRouteCalculationWithInfo:(SKRouteInformation *)routeInformation {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        
        
       __block BOOL routeExists = NO;
       [_calculatedRoutes enumerateObjectsUsingBlock:^(SKRouteInformation *obj, NSUInteger idx, BOOL *stop) {
            if (routeInformation.routeID == obj.routeID) {
                routeExists = YES;
                *stop = YES;
            }
        }];

       if (!routeInformation.corridorIsDownloaded || routeExists || _calculatedRoutes.count == _configuration.numberOfRoutes) {
           return;
       }

       //are we still calculating the routes?
       if ([self hasState:SKTNavigationStateCalculatingRoute]) {
           [_calculatedRoutes addObject:routeInformation];
           
           //stop progress for the calculated route
           SKTRouteProgressView *progressVIew = _mainView.calculatingRouteView.progressViews[_calculatedRoutes.count - 1];
           [progressVIew startProgress];

           //show the info for the calculated route
           [_mainView.calculatingRouteView showInfoViewAtIndex:_calculatedRoutes.count - 1];
           [self updateCalculatedRouteInformationAtIndex:_calculatedRoutes.count - 1];

           //start progress for next route if needed
           if (_calculatedRoutes.count < _mainView.calculatingRouteView.numberOfRoutes) {
               SKTRouteProgressView *progressVIew = _mainView.calculatingRouteView.progressViews[_calculatedRoutes.count];
               [progressVIew startProgress];
           }

           if (!_selectedRoute) {
               _selectedRoute = routeInformation;
               [SKRoutingService sharedInstance].mainRouteId = _selectedRoute.routeID;
               [self zoomOnSelectedRoute];
               _mainView.calculatingRouteView.selectedInfoIndex = 0;
               _mainView.calculatingRouteView.startButton.hidden = NO;
           }
       } else if ([self hasState:SKTNavigationStateRerouting]) { //nope, we're being rerouted
           _selectedRoute = routeInformation;
           _navigationInfo.currentDTA = _selectedRoute.distance;
           [self updateDTA];
           _navigationInfo.currentETA = _selectedRoute.estimatedTime;
           [self updateETA];
           [SKRoutingService sharedInstance].mainRouteId = _selectedRoute.routeID;
           [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeReroutingState) object:nil];
           [self performSelector:@selector(removeReroutingState) withObject:nil afterDelay:kMinReroutingDisplayTime];
       }
    });
}

- (void)routingService:(SKRoutingService *)routingService didFailWithErrorCode:(SKRoutingErrorCode)errorCode {
    dispatch_async(dispatch_get_main_queue(), ^{
       if (_calculatedRoutes.count == 0 && ![self hasState:SKTNavigationStateWaitingForGPS]) {
           [self stopNavigationWithReason:SKTNavigationStopReasonRoutingFailed stopAudio:YES];
       }
    });
}

- (void)routingServiceDidCalculateAllRoutes:(SKRoutingService *)routingService {
    dispatch_async(dispatch_get_main_queue(), ^{
       if (_selectedRoute) {
           if ([self hasState:SKTNavigationStateCalculatingRoute]) {
               //stop route progress
               [self stopRouteCalculationProgress];
               [self updateCalculatedRouteInformation];
               [_mainView.calculatingRouteView showInfoViews];
           } else if ([self hasState:SKTNavigationStateRerouting]) {
               [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeReroutingState) object:nil];
               [self performSelector:@selector(removeReroutingState) withObject:nil afterDelay:kMinReroutingDisplayTime];
           }
       } else {
           if (![self hasState:SKTNavigationStateWaitingForGPS]) {
               [self stopNavigationWithReason:SKTNavigationStopReasonRoutingFailed stopAudio:YES];
           }
       }
    });
}

- (BOOL)routingServiceShouldRetryCalculatingRoute:(SKRoutingService *)routingService withRouteHangingTime:(int)timeInterval{
    //retry only if we have internet
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    return [reachability currentReachabilityStatus] != NotReachable;
}

#pragma mark - SKNavigationDelegate methods

- (void)routingService:(SKRoutingService *)routingService didChangeDistanceToDestination:(int)distance withFormattedDistance:(NSString *)formattedDistance {
    dispatch_async(dispatch_get_main_queue(), ^{
       //split the distance into distance and measurement unit
       NSArray *components = [formattedDistance componentsSeparatedByString:@" "];
       _mainView.navigationView.dtaView.topLabel.text = components[0];
       _mainView.navigationView.dtaView.bottomLabel.text = components[1];
    });
}

- (void)routingService:(SKRoutingService *)routingService didChangeEstimatedTimeToDestination:(int)time {
    dispatch_async(dispatch_get_main_queue(), ^{
       _navigationInfo.currentETA = time;
       _mainView.navigationView.etaView.timeToArrival = time;
    });
}

- (void)routingService:(SKRoutingService *)routingService didChangeCurrentStreetName:(NSString *)currentStreetName streetType:(SKStreetType)streetType countryCode:(NSString *)countryCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isFreeDrive) {
           return;
        }
        _navigationInfo.currentStreetType = streetType;
        _mainView.freeDriveView.streetType = streetType;
        if (currentStreetName && [currentStreetName isNotEmptyOrWhiteSpace]) {
           _mainView.freeDriveView.streetLabel.text = currentStreetName;
           _mainView.freeDriveView.animatedLabel.hidden = NO;
        } else {
           _mainView.freeDriveView.streetLabel.text = nil;
           _mainView.freeDriveView.animatedLabel.hidden = YES;
        }
        
        [_mainView.freeDriveView updateStatusBarStyle];
    });
}

- (void)routingService:(SKRoutingService *)routingService didChangeNextStreetName:(NSString *)nextStreetName streetType:(SKStreetType)streetType countryCode:(NSString *)countryCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        _navigationInfo.nextStreetType = streetType;
        _mainView.navigationView.visualAdviceView.streetType = streetType;
        _mainView.navigationView.visualAdviceView.streetLabel.label.text = nextStreetName;
        [self updateVisualAdviceSign];
        [_mainView.navigationView.visualAdviceView setNeedsLayout];
    });
}

- (void)routingService:(SKRoutingService *)routingService didChangeSecondNextStreet:(NSString *)nextStreetName streetType:(SKStreetType)streetType countryCode:(NSString *)countryCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        _navigationInfo.secondNextStreetType = streetType;
        _mainView.navigationView.shortAdviceView.streetType = streetType;
        
        if (nextStreetName && [nextStreetName isNotEmptyOrWhiteSpace]) {
            _mainView.navigationView.shortAdviceView.streetLabel.label.text = nextStreetName;
            _mainView.navigationView.shortAdviceView.hidden = NO;
        } else {
            _mainView.navigationView.shortAdviceView.hidden = YES;
        }
        [self updateShortVisualAdviceSign];
    });
}

- (void)routingService:(SKRoutingService *)routingService didChangeCurrentAdvice:(SKRouteAdvice *)currentAdvice isLastAdvice:(BOOL)isLastAdvice {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationInfo.firstAdvice = currentAdvice;
        self.navigationInfo.firstAdviceIsLast = isLastAdvice;
        [self updateVisualAdviceSign];
    });
}

- (void)routingService:(SKRoutingService *)routingService didChangeSecondAdvice:(SKRouteAdvice *)secondAdvice isLastAdvice:(BOOL)isLastAdvice {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationInfo.secondaryAdvice = secondAdvice;
        self.navigationInfo.secondaryAdviceIsLast = isLastAdvice;
        [self updateShortVisualAdviceSign];
    });
}

- (void)routingService:(SKRoutingService *)routingService didChangeCurrentVisualAdviceDistance:(int)distance withFormattedDistance:(NSString *)formattedDistance {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![_mainView.navigationView.visualAdviceView.distanceLabel.text isEqualToString:formattedDistance]) {
            _mainView.navigationView.visualAdviceView.distanceLabel.text = formattedDistance;
            [_mainView.navigationView.visualAdviceView setNeedsLayout];
        }
    });
}

- (void)routingService:(SKRoutingService *)routingService didChangeSecondaryVisualAdviceDistance:(int)distance withFormattedDistance:(NSString *)formattedDistance {
    dispatch_async(dispatch_get_main_queue(), ^{
        _mainView.navigationView.shortAdviceView.distanceToTurn = formattedDistance;
    });
}

- (void)routingService:(SKRoutingService *)routingService didUpdateFilteredAudioAdvices:(NSArray *)audioAdvices {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.configuration.routeType != SKRoutePedestrian && !self.configuration.useTTSAdvisor) {
            [_audioManager play:audioAdvices];
        }
    });
}

- (void)routingService:(SKRoutingService *)routingService didUpdateUnfilteredAudioAdvices:(NSArray *)audioAdvices withDistance:(int)distance {
    dispatch_async(dispatch_get_main_queue(), ^{
       _navigationInfo.lastAudioAdvices = audioAdvices;
    });
}

- (BOOL)routingService:(SKRoutingService *)routingService didUpdateFilteredAudioInstruction:(NSString*)instruction forLanguage:(SKAdvisorLanguage)language {
    if (self.configuration.routeType == SKRoutePedestrian) {
        return NO;
    } else {
        return YES;
    }
}

- (void)routingService:(SKRoutingService *)routingService didChangeCurrentSpeed:(double)speed {
    dispatch_async(dispatch_get_main_queue(), ^{
       _navigationInfo.currentSpeed = speed;
       [self updateSpeed];
    });
}

- (void)routingService:(SKRoutingService *)routingService didChangeCurrentSpeedLimit:(double)speedLimit {
    dispatch_async(dispatch_get_main_queue(), ^{
       _navigationInfo.currentSpeedLimit = speedLimit;
       [self updateSpeedLimit];
    });
}

- (void)routingService:(SKRoutingService *)routingService didUpdateSpeedWarningToStatus:(BOOL)speedWarningIsActive withAudioWarnings:(NSArray *)audioWarnings insideCity:(BOOL)isInsideCity {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentSpeedLimitView.blinkWarning = speedWarningIsActive;
        if (!self.configuration.routeType == SKRoutePedestrian) {
            [_audioManager play:audioWarnings];
        }
    });
}

- (void)routingServiceDidStartRerouting:(SKRoutingService *)routingService {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeReroutingState) object:nil];
        [self removeState:SKTNavigationStateRerouting];
        [self insertNavigationState:SKTNavigationStateRerouting afterState:SKTNavigationStateNavigating];
        //reset exit number
        _mainView.navigationView.visualAdviceView.exitNumberLabel.text = @"";
        _mainView.navigationView.visualAdviceView.exitNumberLabel.hidden = YES;
        [_mainView.navigationView.visualAdviceView setNeedsLayout];
    });
}

- (void)routingServiceDidReachDestination:(SKRoutingService *)routingService {
    dispatch_async(dispatch_get_main_queue(), ^{
       if (_isInBackground || !_configuration.continueFreeDriveAfterNavigationEnd) {
           [self stopNavigationWithReason:SKTNavigationStopReasonReachedDestination stopAudio:NO];
       } else {
           [self startFreeDriveAfterNavigation];
       }
    });
}

- (void)routingService:(SKRoutingService *)routingService didChangeCountryCode:(NSString *)countryCode {
    dispatch_async(dispatch_get_main_queue(), ^{
       _navigationInfo.currentCountryCode = countryCode;
       [self updateColorDictionary];

       [SKRoutingService sharedInstance].visualAdviceConfigurations = [self visualAdviceConfiguration];
    });
}

- (void)routingService:(SKRoutingService *)routingService didChangeExitNumber:(NSString *)exitNumber {
    dispatch_async(dispatch_get_main_queue(), ^{
       if (exitNumber && [exitNumber isNotEmptyOrWhiteSpace]) {
           _mainView.navigationView.visualAdviceView.exitNumberLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(kSKTExitKey, nil), exitNumber];
           _mainView.navigationView.visualAdviceView.exitNumberLabel.hidden = NO;
       } else {
           _mainView.navigationView.visualAdviceView.exitNumberLabel.text = @"";
           _mainView.navigationView.visualAdviceView.exitNumberLabel.hidden = YES;
       }
       [_mainView.navigationView.visualAdviceView setNeedsLayout];
    });
}

- (void)routingService:(SKRoutingService *)routingService didStartFCDTripWithID:(NSString *)tripId {
}

#pragma mark - SKPositionerServiceDelegate methods

- (void)positionerService:(SKPositionerService *)positionerService changedGPSAccuracyToLevel:(SKGPSAccuracyLevel)level {
    dispatch_async(dispatch_get_main_queue(), ^{
       if (_navigationStates.count == 0) {
           return;
       }

       if (level == SKGPSAccuracyLevelBad) {
           if ([self hasState:SKTNavigationStateCalculatingRoute] || _navigationStates.count < 1) {
               [self pushNavigationStateIfNotPresent:SKTNavigationStateWaitingForGPS];
           } else {
               if (self.isFreeDrive) {
                   [self insertNavigationStateIfNotPresent:SKTNavigationStateGPSDropped afterState:SKTNavigationStateFreeDrive];
               } else {
                   [self insertNavigationStateIfNotPresent:SKTNavigationStateGPSDropped afterState:SKTNavigationStateNavigating];
               }
           }
       } else {
           [self removeState:SKTNavigationStateWaitingForGPS];
           [self removeState:SKTNavigationStateGPSDropped];
           if (_pendingNavigationState == SKTNavigationStateNavigating) {
               [self startNavigationWithConfiguration:_configuration];
           } else if (_pendingNavigationState == SKTNavigationStateFreeDrive) {
               [self startFreeDriveWithConfiguration:_configuration];
           }
       }
    });
}

#pragma mark - SKTWaitingGPSSignalViewDelegate methods

- (void)skWaitingGPSSignalDidClickOkButton:(SKTWaitingGPSSignalView *)view {
    [self stopNavigationWithReason:SKTNavigationStopReasonUserQuit stopAudio:YES];
}

#pragma mark - SKTNavigationSpeedLimitViewDelegate methods

- (void)speedLimitViewTapped:(SKTNavigationSpeedLimitView *)speedLimitView {
    [self.audioManager cancel];
    [[SKRoutingService sharedInstance] giveNowSpeedLimitAudioInfo];
}

#pragma mark - SKTNavigationCalculatingRouteViewDelegate methods

- (void)calculatingRouteView:(SKTNavigationCalculatingRouteView *)view didSelectRouteAtIndex:(NSInteger)index {
    if (index == view.selectedInfoIndex && index >= 0) {
        [self .mainView.calculatingRouteView removeFromSuperview];
        self.mainView.calculatingRouteView = nil;
        [self beginNavigating];
        return;
    }
    
    if (_calculatedRoutes.count > 1) {
        _mainView.calculatingRouteView.selectedInfoIndex = index;
    } else {
        _mainView.calculatingRouteView.selectedInfoIndex = -1;
    }

    _selectedRoute = _calculatedRoutes[index];
    [SKRoutingService sharedInstance].mainRouteId = _selectedRoute.routeID;
    [self zoomOnSelectedRoute];
}

- (void)calculatingRouteViewStartClicked:(SKTNavigationCalculatingRouteView *)view {
    [self.mainView.calculatingRouteView removeFromSuperview];
    self.mainView.calculatingRouteView = nil;
    [self beginNavigating];
}

#pragma mark - SKMapViewDelegateMethods

- (void)mapView:(SKMapView *)mapView didPanFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    [self tryEnterPanningMode];
}

- (void)mapView:(SKMapView *)mapView didPinchWithScale:(float)scale {
    [self tryEnterPanningMode];
}

- (void)mapView:(SKMapView *)mapView didRotateWithAngle:(float)angle {
    [self tryEnterPanningMode];
}

- (void)mapView:(SKMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    SKTActionSheet *sheet = nil;
    if ([self currentNavigationState] == SKTNavigationStateCalculatingRoute) {
        sheet = [SKTActionSheet actionSheetWithButtonTitles:@[NSLocalizedString(kSKTQuitKey, nil)] cancelButtonTitle:NSLocalizedString(kSKTCancelKey, nil)];
    } else {
        sheet = [SKTActionSheet actionSheetWithButtonTitles:@[NSLocalizedString(kSKTSettingsKey, nil), NSLocalizedString(kSKTQuitKey, nil)] cancelButtonTitle:NSLocalizedString(kSKTCancelKey, nil)];
    }
    
    sheet.delegate = self;
    _activeActionSheet = sheet;
    [sheet showInView:_mainView];
}

#pragma mark - SKTNavigationViewDelegate methods

- (void)navigationView:(SKTNavigationView *)navigationView didPressPositionerButton:(UIButton *)positionerButton {
    [self changeMapFollowerModeWithButton:positionerButton];
    [self updatePositionerButtonImage];
}

#pragma mark - SKTNavigationFreeDriveViewDelegate methods

- (void)navigationFreeDriveView:(SKTNavigationFreeDriveView *)navigationFreeDriveView didPressPositionerButton:(UIButton *)positionerButton {
    [self changeMapFollowerModeWithButton:positionerButton];
    [self updatePositionerButtonImage];
}

#pragma mark - Private methods

- (void)tryEnterPanningMode {
    if ([self currentNavigationState] != SKTNavigationStateFreeDrive &&
        [self currentNavigationState] != SKTNavigationStateNavigating &&
        [self currentNavigationState] != SKTNavigationStateGPSDropped &&
        [self currentNavigationState] != SKTNavigationStateRerouting) {
        return;
    }

    [self pushNavigationState:SKTNavigationStatePanning];
}

- (void)removeReroutingState {
    [self removeState:SKTNavigationStateRerouting];
}

- (void)changeMapFollowerModeWithButton:(UIButton *)button {
    //This method is called when pressing the positioner button in Pedestrian navigation.
    //Here we set the next Follower mode depending on the current follower mode.
    switch (self.prefferedFollowerMode) {
        case SKMapFollowerModeHistoricPosition:
            //The map now turns based on your recent position and next it will turn based on the orientation of the device.
            self.prefferedFollowerMode = SKMapFollowerModePositionPlusHeading;
            self.mapView.settings.followUserPosition = YES;
            self.mapView.settings.headingMode = SKHeadingModeRotatingMap;
            break;
        case SKMapFollowerModePositionPlusHeading:
            //Currently the map turns based on the orientation of the device and next it will be north oriented.
            self.prefferedFollowerMode = SKMapFollowerModePosition;
            self.mapView.settings.followUserPosition = YES;
            self.mapView.settings.headingMode = SKHeadingModeRotatingHeading;
            self.mapView.bearing = 0.0;
            break;
        case SKMapFollowerModePosition:
            //Now the map is north oriented and next it will turn based on your recent position.
            self.prefferedFollowerMode = SKMapFollowerModeHistoricPosition;
            self.mapView.settings.followUserPosition = YES;
            self.mapView.settings.headingMode = SKHeadingModeHistoricPositions;
            break;
            
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == SKTNavigationAlertQuit && alertView.cancelButtonIndex != buttonIndex) {
        [self stopNavigationWithReason:SKTNavigationStopReasonUserQuit stopAudio:YES];
    }
}

- (void)actionSheet:(SKTActionSheet *)actionSheet didSelectButtonAtIndex:(NSUInteger)index {
    if (index == 0) {
        if ([self currentNavigationState] == SKTNavigationStateCalculatingRoute) {
            [self stopNavigationWithReason:SKTNavigationStopReasonUserQuit stopAudio:YES];
        } else {
            //remove states that should't exist while settings view is visible
            [self removeState:SKTNavigationStateBlockRoads];
            [self removeState:SKTNavigationStateOverview];
            [self removeState:SKTNavigationStateRouteInfo];

            [self pushNavigationStateIfNotPresent:SKTNavigationStateSettings];
        }
        
        [actionSheet dismissInstantly];
        self.mainView.settingsView.delegate = self;
    } else if (index == 1) {
        if (self.isFreeDrive) {
            [self stopNavigationWithReason:SKTNavigationStopReasonUserQuit stopAudio:YES];
        } else {
            [self confirmStopNavigation];
        }
        
        [actionSheet dismiss];
    }
    
    _activeActionSheet = nil;
}

#pragma mark - Actions

- (void)panningViewDidClickBackButton:(SKTNavigationPanningView *)view {
    [self removeState:SKTNavigationStatePanning];
}

- (void)panningViewDidClickCenterButton:(SKTNavigationPanningView *)view {
    [_mapView centerOnCurrentPosition];
}

- (void)panningViewDidClickZoomInButton:(SKTNavigationPanningView *)view {
    [_mapView animateToZoomLevel:_mapView.visibleRegion.zoomLevel + 1.0];
}

- (void)panningViewDidClickZoomOutButton:(SKTNavigationPanningView *)view {
    [_mapView animateToZoomLevel:_mapView.visibleRegion.zoomLevel - 1.0];
}

#pragma mark - SKTNavigationSettingsViewDelegate methods

- (void)navigationSettingsViewDidClickBackButton:(SKTNavigationSettingsView *)view {
    [self removeState:SKTNavigationStateSettings];
}

#pragma mark - SKTNavigationVisualAdviceViewDelegate methods

- (void)visualAdviceViewTapped:(SKTNavigationVisualAdviceView *)view {
    [_audioManager cancel];
    if (!self.configuration.routeType == SKRoutePedestrian) {
        [_audioManager play:_navigationInfo.lastAudioAdvices];
    }
}

#pragma mark - SKTBaseViewDelegate methods

- (void)baseView:(SKTBaseView *)view requiresStatusBarStyle:(UIStatusBarStyle)style {
    //by default we set the status bar style directly
    //if the application sets View controller-based status bar appearance to YES, it needs to implement the main view's delegate.
    [UIApplication sharedApplication].statusBarStyle = style;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"outputVolume"]) {
        [self updateVolumeUI];
    }
}

@end
