//
//  SKTNavigationManager+Styles.m
//  FrameworkIOSDemo
//

//

#import <SKMaps/SKMapViewStyle.h>
#import <SKMaps/SKMapView+Style.h>
#import <SKMaps/SKRoutingService.h>

#import "SKTNavigationManager+Styles.h"
#import "SKTNavigationManager+Factories.h"
#import "SKTNavigationManager+UI.h"
#import "SKTNavigationUtils.h"
#import "SKTNavigationConfiguration.h"
#import "SKTNavigationInfo.h"

NSString * const kDayNightUserInfoKey = @"kDayNightUserInfoKey";
const NSTimeInterval kDayNightCheckInterval = 300.0;

@implementation SKTNavigationManager (Styles)

- (void)listenForDayNightChange {
    [self.dayNightTimer invalidate];
    self.dayNightTimer = [NSTimer scheduledTimerWithTimeInterval:kDayNightCheckInterval target:self selector:@selector(checkDayNight) userInfo:nil repeats:YES];
}

- (void)stopListeningForDayNightChange {
    [self.dayNightTimer invalidate];
    self.dayNightTimer = nil;
}

- (void)checkDayNight {
    if (self.isInBackground) {
        self.receivedDayNightNotificationInBackground = YES;
    } else {
        [self updateStyle];
    }
}

- (void)updateStyle {
	if (!self.configuration.automaticDayNight) {
		return;
	}

	if ([SKTNavigationUtils isNight]) {
		[self enableNightStyle];
	} else {
		[self enableDayStyle];
	}
}

- (void)enableDayStyle {
	//we can't change styles when in background or it's the same style
	if (self.isInBackground || self.currentStyle == self.configuration.dayStyle) {
		return;
	}
    
    self.colorScheme = [SKTNavigationManager colorConfigDictionaryForCountry:self.navigationInfo.currentCountryCode night:NO];
    if (self.navigationInfo.currentCountryCode && [self.navigationInfo.currentCountryCode isNotEmptyOrWhiteSpace]) {
		[SKRoutingService sharedInstance].visualAdviceConfigurations = [self visualAdviceConfiguration];
	}

	[SKMapView setMapStyle:self.configuration.dayStyle];
    self.currentStyle = self.configuration.dayStyle;
}

- (void)enableNightStyle {
	//we can't change styles when in background or it's the same style
	if (self.isInBackground || self.currentStyle == self.configuration.nightStyle) {
		return;
	}

    self.colorScheme = [SKTNavigationManager colorConfigDictionaryForCountry:self.navigationInfo.currentCountryCode night:YES];
    if (self.navigationInfo.currentCountryCode && [self.navigationInfo.currentCountryCode isNotEmptyOrWhiteSpace]) {
		[SKRoutingService sharedInstance].visualAdviceConfigurations = [self visualAdviceConfiguration];
	}

	[SKMapView setMapStyle:self.configuration.nightStyle];
    self.currentStyle = self.configuration.nightStyle;
}

- (void)updateColorDictionary {
    if (self.configuration.automaticDayNight && [SKTNavigationUtils isNight]) {
        self.colorScheme =  [SKTNavigationManager colorConfigDictionaryForCountry:self.navigationInfo.currentCountryCode night:YES];
        [self enableNightStyle];
    } else {
        self.colorScheme =  [SKTNavigationManager colorConfigDictionaryForCountry:self.navigationInfo.currentCountryCode night:NO];
        [self enableDayStyle];
    }
}

@end
