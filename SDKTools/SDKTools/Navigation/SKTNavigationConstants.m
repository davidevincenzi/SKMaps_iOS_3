//
//  SKTNavigationConstants.m
//  FrameworkIOSDemo
//

//

#import "SKTNavigationConstants.h"

double const kSKTMPSToKMPH = 3.6;
double const kSKTMPSToMPH = 2.23694;
double const kSKTYardsPerMeter = 1.09361;
double const kSKTFeetPerMeter = 3.28084;

NSString * const kSKTSignPostConfigFilename = @"SKColorScheme";
NSString * const kSKTSignPostDayStyleName = @"DayStyle";
NSString * const kSKTSignPostNightStyleName = @"NightStyle";
NSString * const kSKTSignPostDefaultColorsName = @"default";

NSString * const kSKTDidReceiveLocalNotification = @"kSKTDidReceiveLocalNotification";
NSString * const kSKTLocalNotificationKey = @"kSKTLocalNotificationKey";

const uint32_t kSKTGrayBackground = 0xecebeb;
const uint32_t kSKTGrayText = 0xababab;
const uint32_t kSKTLostGPSBackground = 0xff5649;
const uint32_t kSKTSpeedBackground = 0xececec;

const uint32_t kSKTBlackBackgroundColor = 0x494949;
const uint32_t kSKTRedBackgroundColor = 0xd60000;
const uint32_t kSKTYellowBackgroundColor = 0xf1f100;
const uint32_t kSKTGreenBackgroundColor = 0x0a200;
const uint32_t kSKTBlueBackgroundColor = 0x0043ee;
const uint32_t kSKTBlueHighlightColor = 0x0269cf;
const CGFloat kSKTBackgroundOpacity = 0.9;

NSString * const kSKTGenericBackgroundColorKey = @"GenericBackgroundColor";
NSString * const kSKTGenericTextColorKey = @"GenericTextColor";
NSString * const kSKTGenericHighlightColorKey = @"GenericHighlightColor";
NSString * const kSKTGenericStatusBarStyleDefaultKey = @"GenericStatusBarStyleDefault";
NSString * const kSKTGenericStatusBarStyleOnMapDefaultKey = @"GenericStatusBarStyleOnMapDefault";
NSString * const kSKTGenericWarningColorKey = @"GenericWarningColor";

const NSTimeInterval kSKTColorSchemeChangeDuration = 0.0;

NSString * const kSKTNavigationResourcesBundle = @"SKTNavigationResources.bundle";

#pragma mark - Localized keys

NSString * const kSKTLessThanAMinuteKey = @"SDKTools.lessThanAMinuteKey";
NSString * const kSKTOKKey = @"SDKTools.OkKey";
NSString * const kSKTGPSDroppedKey = @"SDKTools.GPSDroppedKey";
NSString * const kSKTWaitingGPSTitleKey = @"SDKTools.waitingGPSTitleKey";
NSString * const kSKTWaitingGPSTextKey = @"SDKTools.waitingGPSTextKey";
NSString * const kSKTReroutingKey = @"SDKTools.reroutingKey";
NSString * const kSKTStartNavigationKey = @"SDKTools.startNavigationKey";
NSString * const kSKTSettingsVolumeKey = @"SDKTools.settingsVolumeKey";
NSString * const kSKTSettingsAudioKey = @"SDKTools.settingsAudioKey";
NSString * const kSKTSettingsAudioOnKey = @"SDKTools.settingsAudioOnKey";
NSString * const kSKTSettingsAudioOffKey = @"SDKTools.settingsAudioOffKey";
NSString * const kSKTSettingsNightModeKey = @"SDKTools.settingsNightModeKey";
NSString * const kSKTSettingsDayModeKey = @"SDKTools.settingsDayModeKey";
NSString * const kSKTSettingsInfoKey = @"SDKTools.settingsInfoKey";
NSString * const kSKTSettingsPanningKey = @"SDKTools.settingsPanningKey";
NSString * const kSKTSettingsOverviewkey = @"SDKTools.settingsOverviewkey";
NSString * const kSKTSettingsRouteInfoKey = @"SDKTools.settingsRouteInfoKey";
NSString * const kSKTSettingsBlockRoadKey = @"SDKTools.settingsBlockRoadKey";
NSString * const kSKTSettingsUnblockRoadKey = @"SDKTools.settingsUnblockRoadKey";
NSString * const kSKTDestinationKey = @"SDKTools.destinationKey";
NSString * const kSKTCurrentPositionKey = @"SDKTools.currentPositionKey";
NSString * const kSKTQuitKey = @"SDKTools.quitKey";
NSString * const kSKTSettingsKey = @"SDKTools.settingsKey";
NSString * const kSKTCancelKey = @"SDKTools.cancelKey";
NSString * const kSKTBackgroundNavigationLocalNotificationKey = @"SDKTools.backgroundNavigationLocalNotificationKey";
NSString * const kSKTConfirmQuitKey = @"SDKTools.confirmQuitKey";
NSString * const kSKTYesKey  = @"SDKTools.yesKey";
NSString * const kSKTNoKey  = @"SDKTools.noKey";
NSString * const kSKTExitKey = @"SDKTools.exitKey";
NSString * const kSKTStartPedestrianKey = @"SDKTools.pedestrianNavigationKey";
