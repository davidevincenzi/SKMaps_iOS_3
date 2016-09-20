//
//  SKTNavigationConstants.h
//  FrameworkIOSDemo
//

//

#import <Foundation/Foundation.h>

#pragma mark - Navigation

/** Used to identify the state of the navigation
 */
typedef NS_ENUM(NSUInteger, SKTNavigationState) {
    SKTNavigationStateNone,
    SKTNavigationStateCalculatingRoute,
    SKTNavigationStateFreeDrive,
    SKTNavigationStateWaitingForGPS,
    SKTNavigationStateNavigating,
    SKTNavigationStateGPSDropped,
    SKTNavigationStateRerouting,
    SKTNavigationStatePanning,
    SKTNavigationStateSettings,
    SKTNavigationStateBlockRoads,
    SKTNavigationStateOverview,
    SKTNavigationStateRouteInfo
};

#pragma mark - UI

/** SKTUIOrientation is used for elements that need to look different in landscape and portrait
 */
typedef NS_ENUM(NSUInteger, SKTUIOrientation) {
    SKTUIOrientationPortrait,
    SKTUIOrientationLandscape
};

/** Time format
 */
typedef NS_ENUM(NSUInteger, SKTNavigationTimeFormat) {
    SKTNavigationTimeFormat12h,
    SKTNavigationTimeFormat24h
};


/** Time of day
 */
typedef NS_ENUM(NSUInteger, SKTNavigationTimeOfDay) {
    SKTNavigationDay,
    SKTNavigationNight
};

/** SKTNavigationStopReason informs about the reason that the navigation was stopped
 */
typedef NS_ENUM(NSUInteger, SKTNavigationStopReason) {
    SKTNavigationStopReasonNone, //sent when the navigation is programatically stopped by calling stopNavigation
    SKTNavigationStopReasonUserQuit, //sent when the user has chosen to quit or when he pressed the OK button while waiting for GPS signal
    SKTNavigationStopReasonRoutingFailed, //sent when the route calculation or rerouting failed
    SKTNavigationStopReasonReachedDestination //only sent if continue in continueFreeDriveAfterNavigationEnd is NO
};

/**SKTNavigationUnitReturnFormat is used for conversion
 */
typedef NS_ENUM(NSUInteger, SKTNavigationUnitReturnFormat) {
    SKTNavigationUnitReturnFeet = 0,
    SKTNavigationUnitReturnKilometers,
    SKTNavigationUnitReturnYards,
    SKTNavigationUnitReturnMiles,
    SKTNavigationUnitReturnMeters
};

typedef NS_ENUM (NSUInteger, SKTNavigationViewType) {
    SKTNavigationViewTypeCar,
    SKTNavigationViewTypePedestrian
};

typedef NS_ENUM (NSUInteger, SKTNavigationFreeDriveViewType) {
    SKTNavigationFreeDriveViewTypeCar,
    SKTNavigationFreeDriveViewTypePedestrian
};

extern double const kSKTMPSToKMPH;
extern double const kSKTMPSToMPH;
extern double const kSKTYardsPerMeter;
extern double const kSKTFeetPerMeter;

extern NSString * const kSKTSignPostConfigFilename;
extern NSString * const kSKTSignPostDayStyleName;
extern NSString * const kSKTSignPostNightStyleName;
extern NSString * const kSKTSignPostDefaultColorsName;

extern const uint32_t kSKTGrayBackground;
extern const uint32_t kSKTGrayText;
extern const uint32_t kSKTLostGPSBackground;

#pragma mark - Colors

extern const uint32_t kSKTBlackBackgroundColor;
extern const uint32_t kSKTRedBackgroundColor;
extern const uint32_t kSKTGreenBackgroundColor;
extern const uint32_t kSKTBlueBackgroundColor;
extern const uint32_t kSKTBlueHighlightColor;
extern const CGFloat kSKTBackgroundOpacity;

extern NSString * const kSKTGenericBackgroundColorKey;
extern NSString * const kSKTGenericTextColorKey;
extern NSString * const kSKTGenericHighlightColorKey;
extern NSString * const kSKTGenericStatusBarStyleDefaultKey;
extern NSString * const kSKTGenericStatusBarStyleOnMapDefaultKey;
extern NSString * const kSKTGenericWarningColorKey;

extern const NSTimeInterval kSKTColorSchemeChangeDuration;

extern NSString * const kSKTNavigationResourcesBundle;

#pragma mark - Localized keys

extern NSString * const kSKTLessThanAMinuteKey;
extern NSString * const kSKTOKKey;
extern NSString * const kSKTGPSDroppedKey;
extern NSString * const kSKTWaitingGPSTitleKey;
extern NSString * const kSKTWaitingGPSTextKey;
extern NSString * const kSKTReroutingKey;
extern NSString * const kSKTStartNavigationKey;
extern NSString * const kSKTSettingsVolumeKey;
extern NSString * const kSKTSettingsAudioKey;
extern NSString * const kSKTSettingsAudioOnKey;
extern NSString * const kSKTSettingsAudioOffKey;
extern NSString * const kSKTSettingsNightModeKey;
extern NSString * const kSKTSettingsDayModeKey;
extern NSString * const kSKTSettingsInfoKey;
extern NSString * const kSKTSettingsPanningKey;
extern NSString * const kSKTSettingsOverviewkey;
extern NSString * const kSKTSettingsRouteInfoKey;
extern NSString * const kSKTSettingsBlockRoadKey;
extern NSString * const kSKTSettingsUnblockRoadKey;
extern NSString * const kSKTDestinationKey;
extern NSString * const kSKTCurrentPositionKey;
extern NSString * const kSKTQuitKey;
extern NSString * const kSKTSettingsKey;
extern NSString * const kSKTCancelKey;
extern NSString * const kSKTBackgroundNavigationLocalNotificationKey;
extern NSString * const kSKTConfirmQuitKey;
extern NSString * const kSKTYesKey;
extern NSString * const kSKTNoKey;
extern NSString * const kSKTExitKey;
extern NSString * const kSKTStartPedestrianKey;

