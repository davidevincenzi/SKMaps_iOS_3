//
//  SKTNavigationManager+Settings.m
//  SDKTools
//

//

#import <SKMaps/SKRoutingService.h>
#import <AVFoundation/AVAudioSession.h>

#import "SKTNavigationManager+Settings.h"
#import "SKTNavigationManager+Styles.h"
#import "SKTNavigationManager+NavigationState.h"
#import "SKTNavigationManager+UI.h"
#import "SKTNavigationSettingsButton.h"
#import "SKTNavigationConfiguration.h"
#import "SKTNavigationDoubleLabelView.h"
#import "SKTNavigationBlockRoadsView.h"
#import "SKTMainView.h"
#import "SKTNavigationUtils.h"
#import "SKTNavigationOverviewView.h"
#import "SKTNavigationSettingsView.h"
#import "SKTAudioManager.h"
#import "SKTNavigationInfoView.h"
#import "SKTNavigationInfo.h"

NSString *const kDisplayModeKey = @"kSDKTools.DisplayModeKey";
NSString *const kFollowerModeKey = @"kSDKTools.FollowerModeKey";

@interface SKTNavigationManager (SettingsInternal) <SKTNavigationBlockRoadsViewDelegate, SKTNavigationOverviewViewDelegate, SKTNavigationInfoViewDelegate>

@end

@implementation SKTNavigationManager (Settings)


- (NSArray *)buttonsForFreeDrive {
    return @[[self audioButton],
             [self styleButton],
             [self infoButton],
             [self panningButton],
             [self twoDButton],
             [self quitButton]];
}

- (NSArray *)buttonsForNavigation {
    return @[[self audioButton],
             [self styleButton],
             [self overviewButton],
             [self routeInfoButton],
             [self blockRoadButton],
             [self panningButton],
             [self twoDButton],
             [self quitButton]];
}

#pragma mark - Button factory

- (SKTNavigationSettingsButton *)audioButton {
    BOOL audioOn = [[AVAudioSession sharedInstance] outputVolume] > 0.0;
    NSString *imageName = (audioOn ? @"Settings/ic_audio_off.png" : @"Settings/ic_audio_on.png");
    NSString *status = (audioOn ? [NSLocalizedString(kSKTSettingsAudioOffKey, nil) uppercaseString] : [NSLocalizedString(kSKTSettingsAudioOnKey, nil) uppercaseString]);
    NSString *topText = [NSLocalizedString(kSKTSettingsAudioKey, nil) uppercaseString];
    topText = [topText stringByAppendingFormat:@" %@", status];
    SKTNavigationSettingsButton *button = [SKTNavigationSettingsButton settingsButtonWithImage:[UIImage navigationImageNamed:imageName] topText:topText bottomText:nil];
    [button addTarget:self action:@selector(audioClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (SKTNavigationSettingsButton *)styleButton {
    BOOL dayStyle = (self.currentStyle == self.configuration.dayStyle);
    NSString *imageName = (dayStyle ? @"Settings/ic_nightmode.png" : @"Settings/ic_daymode.png");
    UIImage *image = [UIImage navigationImageNamed:imageName];
    NSString *topText = [(dayStyle ? @"Night mode" : @"Day mode") uppercaseString];
    SKTNavigationSettingsButton *button = [SKTNavigationSettingsButton settingsButtonWithImage:image topText:topText bottomText:nil];
    [button addTarget:self action:@selector(styleClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (SKTNavigationSettingsButton *)infoButton {
    UIImage *image = [UIImage navigationImageNamed:@"Settings/ic_routeinfo.png"];
    NSString *topText = [NSLocalizedString(kSKTSettingsInfoKey, nil) uppercaseString];
    SKTNavigationSettingsButton *button = [SKTNavigationSettingsButton settingsButtonWithImage:image topText:topText bottomText:nil];
    [button addTarget:self action:@selector(infoClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;

}

- (SKTNavigationSettingsButton *)routeInfoButton {
    UIImage *image = [UIImage navigationImageNamed:@"Settings/ic_routeinfo.png"];
    NSString *topText = [NSLocalizedString(kSKTSettingsRouteInfoKey, nil) uppercaseString];
    SKTNavigationSettingsButton *button = [SKTNavigationSettingsButton settingsButtonWithImage:image topText:topText bottomText:nil];
    [button addTarget:self action:@selector(infoClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (SKTNavigationSettingsButton *)panningButton {
    UIImage *image = [UIImage navigationImageNamed:@"Settings/ic_panning.png"];
    NSString *topText = [NSLocalizedString(kSKTSettingsPanningKey, nil) uppercaseString];
    SKTNavigationSettingsButton *button = [SKTNavigationSettingsButton settingsButtonWithImage:image topText:topText bottomText:nil];
    [button addTarget:self action:@selector(panningClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (SKTNavigationSettingsButton *)twoDButton {
    SKMapDisplayMode mode = self.prefferedDisplayMode;
    NSString *imageName = (mode == SKMapDisplayMode3D ? @"Settings/ic_2d.png" : @"Settings/ic_3d.png");
    UIImage *image = [UIImage navigationImageNamed:imageName];
    NSString *topText = (mode == SKMapDisplayMode3D ? @"2D" : @"3D");
    SKTNavigationSettingsButton *button = [SKTNavigationSettingsButton settingsButtonWithImage:image topText:topText bottomText:nil];
    [button addTarget:self action:@selector(twoDClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (SKTNavigationSettingsButton *)quitButton {
    UIImage *image = [UIImage navigationImageNamed:@"Settings/ic_quit.png"];
    NSString *topText = [NSLocalizedString(kSKTQuitKey, nil) uppercaseString];
    SKTNavigationSettingsButton *button = [SKTNavigationSettingsButton settingsButtonWithImage:image topText:topText bottomText:nil];
    [button addTarget:self action:@selector(quitClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (SKTNavigationSettingsButton *)overviewButton {
    UIImage *image = [UIImage navigationImageNamed:@"Settings/ic_overview.png"];
    NSString *topText = [NSLocalizedString(kSKTSettingsOverviewkey, nil) uppercaseString];
    SKTNavigationSettingsButton *button = [SKTNavigationSettingsButton settingsButtonWithImage:image topText:topText bottomText:nil];
    [button addTarget:self action:@selector(overviewClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (SKTNavigationSettingsButton *)blockRoadButton {
    UIImage *image = [UIImage navigationImageNamed:@"Settings/ic_roadblock.png"];
    NSString *topText = [NSLocalizedString(kSKTSettingsBlockRoadKey, nil) uppercaseString];
    SKTNavigationSettingsButton *button = [SKTNavigationSettingsButton settingsButtonWithImage:image topText:topText bottomText:nil];
    [button addTarget:self action:@selector(blockRoadClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Public properties

- (void)setPrefferedDisplayMode:(SKMapDisplayMode)prefferedDisplayMode {
    [[NSUserDefaults standardUserDefaults] setObject:@(prefferedDisplayMode) forKey:kDisplayModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (SKMapDisplayMode)prefferedDisplayMode {
    NSNumber *mode = [[NSUserDefaults standardUserDefaults] valueForKey:kDisplayModeKey];
    if (mode) {
        return [mode intValue];
    } else {
        self.prefferedDisplayMode = SKMapDisplayMode3D;
        return SKMapDisplayMode3D;
    }
}

- (SKMapFollowerMode)prefferedFollowerMode {
    NSNumber *mode = [[NSUserDefaults standardUserDefaults] valueForKey:kFollowerModeKey];
    
    if (self.configuration.routeType == SKRoutePedestrian) {
        if (mode) {
            return [mode intValue];
        } else {
            self.prefferedFollowerMode = SKMapFollowerModeHistoricPosition;
            return SKMapFollowerModeHistoricPosition;
        }
    } else {
        return SKMapFollowerModeNavigation;
    }
}

- (void)setPrefferedFollowerMode:(SKMapFollowerMode)prefferedFollowerMode {
    [[NSUserDefaults standardUserDefaults] setObject:@(prefferedFollowerMode) forKey:kFollowerModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Actions

- (void)audioClicked:(SKTNavigationSettingsButton *)sender {
    if ([[AVAudioSession sharedInstance] outputVolume] > 0.0) {
        sender.customImageView.image = [UIImage navigationImageNamed:@"Settings/ic_audio_on.png"];
        sender.infoLabelView.topLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(kSKTSettingsAudioKey, nil), NSLocalizedString(kSKTSettingsAudioOnKey, nil)];
        self.previousVolume = [[AVAudioSession sharedInstance] outputVolume];
        self.mainView.settingsView.volumeSlider.value = 0.0;
    } else {
        sender.customImageView.image = [UIImage navigationImageNamed:@"Settings/ic_audio_off.png"];
        sender.infoLabelView.topLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(kSKTSettingsAudioKey, nil), NSLocalizedString(kSKTSettingsAudioOffKey, nil)];
        if (self.previousVolume > 0.0) {
            self.mainView.settingsView.volumeSlider.value = self.previousVolume;
        } else {
            self.mainView.settingsView.volumeSlider.value = 0.125;
        }
        [self replayAdvice];
    }
}

- (void)replayAdvice {
    [self.audioManager cancel];
    [self.audioManager play:self.navigationInfo.lastAudioAdvices];
}

- (void)styleClicked:(SKTNavigationSettingsButton *)sender {
    if (self.currentStyle == self.configuration.nightStyle) {
        [self enableDayStyle];
        [sender setImage:[UIImage navigationImageNamed:@"Settings/ic_nightmode.png"] forState:UIControlStateNormal];
        sender.infoLabelView.topLabel.text = NSLocalizedString(kSKTSettingsNightModeKey, nil);
    } else {
        [self enableNightStyle];
        [sender setImage:[UIImage navigationImageNamed:@"Settings/ic_daymode.png"] forState:UIControlStateNormal];
        sender.infoLabelView.topLabel.text = NSLocalizedString(kSKTSettingsDayModeKey, nil);
    }

    [self removeState:SKTNavigationStateSettings];
}

- (void)infoClicked:(SKTNavigationSettingsButton *)sender {
    [self pushNavigationState:SKTNavigationStateRouteInfo];
     self.mainView.routeInfoView.delegate = self;
}

- (void)panningClicked:(SKTNavigationSettingsButton *)sender {
    [self removeState:SKTNavigationStatePanning];
    [self removeState:SKTNavigationStateSettings];
    [self pushNavigationStateIfNotPresent:SKTNavigationStatePanning];
}

- (void)twoDClicked:(SKTNavigationSettingsButton *)sender {
    if (self.prefferedDisplayMode == SKMapDisplayMode2D) {
        [sender setImage:[UIImage navigationImageNamed:@"Settings/ic_2D.png"] forState:UIControlStateNormal];
        sender.infoLabelView.topLabel.text = @"2D";
        self.prefferedDisplayMode = SKMapDisplayMode3D;
        self.mapView.settings.displayMode = SKMapDisplayMode3D;
    } else {
        [sender setImage:[UIImage navigationImageNamed:@"Settings/ic_3D.png"] forState:UIControlStateNormal];
        sender.infoLabelView.topLabel.text = @"3D";
        self.prefferedDisplayMode = SKMapDisplayMode2D;
        self.mapView.settings.displayMode = SKMapDisplayMode2D;
    }

    [self removeState:SKTNavigationStateSettings];
}

- (void)quitClicked:(SKTNavigationSettingsButton *)sender {
    if (!self.isFreeDrive) {
        [self confirmStopNavigation];
    } else {
        [self stopAfterUserQuit];
    }
}

- (void)overviewClicked:(SKTNavigationSettingsButton *)sender {
    self.mainView.overviewView.delegate = self;
    [self pushNavigationState:SKTNavigationStateOverview];
}

- (void)blockRoadClicked:(SKTNavigationSettingsButton *)sender {
    [self pushNavigationState:SKTNavigationStateBlockRoads];
    self.mainView.blockRoadsView.delegate = self;
    NSString *unit = @"meters";
    if (self.configuration.distanceFormat == SKDistanceFormatMilesFeet) {
        unit = @"feet";
    } else if (self.configuration.distanceFormat == SKDistanceFormatMilesYards) {
        unit = @"yards";
    }
    if (self.blockedRoadsDistance > 0.0) {
        self.mainView.blockRoadsView.datasource = @[NSLocalizedString(kSKTSettingsUnblockRoadKey, nil),
                                                          [NSString stringWithFormat:@"100 %@", unit],
                                                          [NSString stringWithFormat:@"500 %@", unit]];
    } else {
        self.mainView.blockRoadsView.datasource = @[[NSString stringWithFormat:@"100 %@", unit],
                                                          [NSString stringWithFormat:@"500 %@", unit]];
    }
}

- (void)updateVolumeUI {
    SKTNavigationSettingsButton *button = [self.mainView.settingsView.settingsButtons firstObject];
    if (!button) {
        return;
    }
    
    if ([[AVAudioSession sharedInstance] outputVolume] > 0.0) {
        button.customImageView.image = [UIImage navigationImageNamed:@"Settings/ic_audio_off.png"];
        button.infoLabelView.topLabel.text = [[NSString stringWithFormat:@"%@ %@", NSLocalizedString(kSKTSettingsAudioKey, nil), NSLocalizedString(kSKTSettingsAudioOffKey, nil)] uppercaseString];
    } else {
        button.customImageView.image = [UIImage navigationImageNamed:@"Settings/ic_audio_on.png"];
        button.infoLabelView.topLabel.text = [[NSString stringWithFormat:@"%@ %@", NSLocalizedString(kSKTSettingsAudioKey, nil), NSLocalizedString(kSKTSettingsAudioOnKey, nil)] uppercaseString];
    }
}

#pragma mark - Block roads delegate

- (void)blockRoadsViewDidPressBackButton:(SKTNavigationBlockRoadsView *)view {
    [self removeState:SKTNavigationStateBlockRoads];
}

- (void)blockRoadsView:(SKTNavigationBlockRoadsView *)view didSelectIndex:(NSUInteger)index {
    if (self.blockedRoadsDistance > 0.0 && index == 0) {
        [[SKRoutingService sharedInstance] unBlockAllRoads];
        self.blockedRoadsDistance = 0.0;
    } else {
        double distance = (index == 0 ? 100.0 : 500.0);
        if (self.configuration.distanceFormat == SKDistanceFormatMilesFeet) {
            distance /= kSKTFeetPerMeter;
        } else if (self.configuration.distanceFormat == SKDistanceFormatMilesYards) {
            distance /= kSKTYardsPerMeter;
        }

        [[SKRoutingService sharedInstance] blockRoads:distance];
        self.blockedRoadsDistance = distance;
    }

    [self removeState:SKTNavigationStateBlockRoads];
    [self removeState:SKTNavigationStateSettings];
}

#pragma mark - Overview delegate

- (void)navigationOverviewViewDidClickBackButton:(SKTNavigationOverviewView *)view {
    [self removeState:SKTNavigationStateOverview];
}

#pragma mark - SKTNavigationInfoViewDelegate methods

- (void)navigationInfoViewDidClickBackButton:(SKTNavigationInfoView *)view {
    [self removeState:SKTNavigationStateRouteInfo];
}

@end
