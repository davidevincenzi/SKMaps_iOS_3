//
//  SKTNavigationSettings.m
//  FrameworkIOSDemo
//

//

#import "SKTNavigationConfiguration.h"

@implementation SKTNavigationConfiguration

+ (instancetype)defaultConfiguration {
	SKTNavigationConfiguration *configuration = [[SKTNavigationConfiguration alloc] init];
    configuration.routeInfo = nil;
	configuration.routeType = SKRouteCarEfficient;
	configuration.numberOfRoutes = 3;
	configuration.distanceFormat = SKDistanceFormatMetric;
	configuration.navigationType = SKNavigationTypeReal;
	configuration.allowBackgroundNavigation = YES;
	configuration.showStreetNamesAsPopUps = YES;
	configuration.automaticDayNight = YES;
	configuration.advisorLanguage = SKAdvisorLanguageEN_US;
    configuration.useTTSAdvisor = YES;
    configuration.playAudioDuringCall = YES;
    configuration.speedLimitWarningThresholdInCity = 20.0;
    configuration.speedWarningThresholdOutsideCity = 20.0;
    configuration.preventStandBy = YES;
    configuration.avoidTollRoads = NO;
    configuration.avoidHighways = NO;
    configuration.avoidFerries = NO;
    configuration.continueFreeDriveAfterNavigationEnd = YES;
    
	SKMapViewStyle *dayStyle = [SKMapViewStyle mapViewStyle];
	dayStyle.styleFileName = @"daystyle.json";
	dayStyle.resourcesFolderName = @"DayStyle";
	configuration.dayStyle = dayStyle;

	SKMapViewStyle *nightStyle = [SKMapViewStyle mapViewStyle];
	nightStyle.styleFileName = @"nightstyle.json";
	nightStyle.resourcesFolderName = @"NightStyle";
	configuration.nightStyle = nightStyle;

	return configuration;
}

- (instancetype)duplicate {
    SKTNavigationConfiguration *configuration = [[SKTNavigationConfiguration alloc] init];
    configuration.destination = self.destination;
    configuration.viaPoints = self.viaPoints;
    configuration.routeInfo = self.routeInfo;
	configuration.routeType = self.routeType;
	configuration.numberOfRoutes = self.numberOfRoutes;
	configuration.distanceFormat = self.distanceFormat;
	configuration.navigationType = self.navigationType;
	configuration.allowBackgroundNavigation = self.allowBackgroundNavigation;
	configuration.showStreetNamesAsPopUps = self.showStreetNamesAsPopUps;
	configuration.automaticDayNight = self.automaticDayNight;
	configuration.advisorLanguage = self.advisorLanguage;
    configuration.useTTSAdvisor = self.useTTSAdvisor;
    configuration.playAudioDuringCall = self.playAudioDuringCall;
    configuration.speedLimitWarningThresholdInCity = self.speedLimitWarningThresholdInCity;
    configuration.speedWarningThresholdOutsideCity = self.speedWarningThresholdOutsideCity;
    configuration.preventStandBy = self.preventStandBy;
    configuration.avoidTollRoads = self.avoidTollRoads;
    configuration.avoidHighways = self.avoidHighways;
    configuration.avoidFerries = self.avoidHighways;
    configuration.continueFreeDriveAfterNavigationEnd = self.continueFreeDriveAfterNavigationEnd;
    
	SKMapViewStyle *dayStyle = [SKMapViewStyle mapViewStyle];
	dayStyle.styleFileName = self.dayStyle.styleFileName;
	dayStyle.resourcesFolderName = self.dayStyle.resourcesFolderName;
	configuration.dayStyle = dayStyle;
    
	SKMapViewStyle *nightStyle = [SKMapViewStyle mapViewStyle];
	nightStyle.styleFileName = self.nightStyle.styleFileName;
	nightStyle.resourcesFolderName = self.nightStyle.resourcesFolderName;
	configuration.nightStyle = nightStyle;
    
    configuration.simulationLogPath = self.simulationLogPath;
    configuration.startCoordinate = self.startCoordinate;
    
	return configuration;

}

@end
