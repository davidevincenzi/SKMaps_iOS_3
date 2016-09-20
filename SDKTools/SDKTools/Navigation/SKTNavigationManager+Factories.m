//
//  SKTNavigationManager+Factories.m
//  FrameworkIOSDemo
//

//

#import <SKMaps/SKRouteAlternativeSettings.h>
#import <SKMaps/SKPositionerService.h>
#import <SKMaps/SKVisualAdviceConfiguration.h>
#import <SKMaps/SKAdvisorSettings.h>
#import <SKMaps/SKTrailSettings.h>

#import "SKTNavigationConfiguration.h"
#import "SKTNavigationManager+Factories.h"
#import "SKTNavigationUtils.h"
#import "SKTNavigationInfo.h"

@implementation SKTNavigationManager (Factories)

+ (SKRouteSettings *)routeSettingsForConfiguration:(SKTNavigationConfiguration *)configuration {
	SKRouteSettings *settings = [SKRouteSettings routeSettings];

    if (configuration.navigationType == SKNavigationTypeReal || [SKTNavigationUtils locationIsZero:configuration.startCoordinate]) {
     	settings.startCoordinate = [SKPositionerService sharedInstance].currentCoordinate;
    } else if (configuration.navigationType == SKNavigationTypeSimulation) {
        settings.startCoordinate = configuration.startCoordinate;
    }
    
	settings.destinationCoordinate = configuration.destination;
	settings.shouldBeRendered = YES;
	settings.requestAdvices = YES;
	settings.routeMode = configuration.routeType;
	settings.maximumReturnedRoutes = configuration.numberOfRoutes;

    SKRouteRestrictions restrictions = settings.routeRestrictions;
    restrictions.avoidHighways = configuration.avoidHighways;
    restrictions.avoidTollRoads = configuration.avoidTollRoads;
    restrictions.avoidFerryLines = configuration.avoidFerries;
    settings.routeRestrictions = restrictions;
    settings.viaPoints = configuration.viaPoints;

	return settings;
}

- (NSArray *)visualAdviceConfiguration {
    if (self.navigationInfo.currentCountryCode && [self.navigationInfo.currentCountryCode isNotEmptyOrWhiteSpace]) {
        return @[[self configurationForStreetType:SKStreetTypeRoad],
                 [self configurationForStreetType:SKStreetTypePrimary_link],
                 [self configurationForStreetType:SKStreetTypePrimary],
                 [self configurationForStreetType:SKStreetTypeTrunk_link],
                 [self configurationForStreetType:SKStreetTypeTrunk],
                 [self configurationForStreetType:SKStreetTypeMotorway_link],
                 [self configurationForStreetType:SKStreetTypeMotorway],
                 //for any other route types we use any_road colors
                 [self configurationForStreetType:SKStreetTypeUndefined],
                 [self configurationForStreetType:SKStreetTypeBridleway],
                 [self configurationForStreetType:SKStreetTypeConstruction],
                 [self configurationForStreetType:SKStreetTypeCrossing],
                 [self configurationForStreetType:SKStreetTypeCycleway],
                 [self configurationForStreetType:SKStreetTypeFootway],
                 [self configurationForStreetType:SKStreetTypeFord],
                 [self configurationForStreetType:SKStreetTypeLiving_street],
                 [self configurationForStreetType:SKStreetTypePath],
                 [self configurationForStreetType:SKStreetTypePedestrian],
                 [self configurationForStreetType:SKStreetTypeResidential],
                 [self configurationForStreetType:SKStreetTypeSecondary],
                 [self configurationForStreetType:SKStreetTypeSecondary_link],
                 [self configurationForStreetType:SKStreetTypeService],
                 [self configurationForStreetType:SKStreetTypeSteps],
                 [self configurationForStreetType:SKStreetTypeTertiary],
                 [self configurationForStreetType:SKStreetTypeTertiary_link],
                 [self configurationForStreetType:SKStreetTypeUnclassified],
                 [self configurationForStreetType:SKStreetTypeFerryPed],
                 [self configurationForStreetType:SKStreetTypeResidential_limited],
                 [self configurationForStreetType:SKStreetTypeUnpavedTrack],
                 [self configurationForStreetType:SKStreetTypePermissive],
                 [self configurationForStreetType:SKStreetTypeDestination],
                 [self configurationForStreetType:SKStreetTypePier]];
    } else {
        return nil;
    }
}

+ (NSDictionary *)colorConfigDictionaryForCountry:(NSString *)country night:(BOOL)night {
    NSBundle *navBundle = [SKTNavigationUtils navigationBundle];
    NSURL *url = [navBundle URLForResource:kSKTSignPostConfigFilename withExtension:@"plist"];
	NSDictionary *configDictionary = [NSDictionary dictionaryWithContentsOfURL:url];
    
	NSDictionary *currentConfig = nil;
	if (night) {
		currentConfig = configDictionary[kSKTSignPostNightStyleName];
	} else {
		currentConfig = configDictionary[kSKTSignPostDayStyleName];
	}
    
	NSDictionary *colorDictionary = currentConfig[country];
	if (!colorDictionary) {
		colorDictionary = currentConfig[kSKTSignPostDefaultColorsName];
	}
    
    NSMutableDictionary *dict = [colorDictionary mutableCopy];
    [dict setObject:currentConfig[kSKTGenericBackgroundColorKey] forKey:kSKTGenericBackgroundColorKey];
    [dict setObject:currentConfig[kSKTGenericTextColorKey] forKey:kSKTGenericTextColorKey];
    [dict setObject:currentConfig[kSKTGenericStatusBarStyleDefaultKey] forKey:kSKTGenericStatusBarStyleDefaultKey];
    [dict setObject:currentConfig[kSKTGenericStatusBarStyleOnMapDefaultKey] forKey:kSKTGenericStatusBarStyleOnMapDefaultKey];
    [dict setObject:currentConfig[kSKTGenericHighlightColorKey] forKey:kSKTGenericHighlightColorKey];
    [dict setObject:currentConfig[kSKTGenericWarningColorKey] forKey:kSKTGenericWarningColorKey];
    
    return dict;
}

- (SKVisualAdviceConfiguration *)configurationForStreetType:(SKStreetType)streetType {
    NSString *name = [SKTNavigationUtils adviceSignColorNameForStreetType:streetType];
	uint32_t color = [self.colorScheme[name] unsignedIntValue];
	SKVisualAdviceConfiguration *config = [SKVisualAdviceConfiguration visualAdviceColor];
	config.streetType = streetType;
	config.countryCode = self.navigationInfo.currentCountryCode;
	config.routeStreetColor = [UIColor colorWithHex:color alpha:1.0];
	config.allowedStreetColor = [UIColor colorWithHex:color alpha:0.0f];
	config.forbiddenStreetColor = [UIColor colorWithHex:color alpha:0.0f];

	return config;
}

+ (SKAdvisorSettings *)audioAdvisorSettingsForLanguage:(SKAdvisorLanguage)language {
	SKAdvisorSettings *settings = [SKAdvisorSettings advisorSettings];
	settings.advisorVoice = [SKTNavigationUtils languageNameForLanguage:language];
	settings.language = language;
    settings.advisorType = SKAdvisorTypeAudioFiles;

	return settings;
}

+ (SKAdvisorSettings *)ttsAudioAdvisorSettingsForLanguage:(SKAdvisorLanguage)language {
    SKAdvisorSettings *settings = [SKAdvisorSettings advisorSettings];
    settings.advisorVoice = [SKTNavigationUtils languageNameForLanguage:language];
    settings.language = language;
    settings.advisorType = SKAdvisorTypeTextToSpeech;
    
    return settings;
}

@end
