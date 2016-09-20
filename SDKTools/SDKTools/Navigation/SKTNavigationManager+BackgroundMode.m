//
//  SKTNavigationManager+BackgroundMode.m
//  FrameworkIOSDemo
//

//

#import <SKMaps/SKPositionerService.h>
#import <SKMaps/SKRoutingService.h>
#import <SKMaps/SKMapView.h>

#import "SKTNavigationManager+BackgroundMode.h"
#import "SKTNavigationManager+NavigationState.h"
#import "SKTNavigationManager+Factories.h"
#import "SKTNavigationManager+Styles.h"
#import "SKTNavigationManager+Settings.h"
#import "SKTNavigationUtils.h"
#import "SKTAudioManager.h"
#import "SKTNavigationConfiguration.h"

NSString *const kBackgroundLocalNotificationKey = @"kBackgroundLocalNotificationKey";

@implementation SKTNavigationManager (BackgroundMode)

- (void)listenForBackgroundChanges {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)stopListeningForBackgroundChanges {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
	[SKTNavigationUtils cancelLocalNoficationWithUserInfoKey:kBackgroundLocalNotificationKey];
}

- (void)didEnterBackground {
	self.isInBackground = YES;

	if (self.configuration.allowBackgroundNavigation) {
		//notify the user that the navigaiton will continue while in background
		UILocalNotification *backgroundLocalNotification = [[UILocalNotification alloc] init];

		backgroundLocalNotification.alertBody = NSLocalizedString(kSKTBackgroundNavigationLocalNotificationKey, nil);
		backgroundLocalNotification.userInfo = @{ kBackgroundLocalNotificationKey : kBackgroundLocalNotificationKey };
		[[UIApplication sharedApplication] scheduleLocalNotification:backgroundLocalNotification];
	} else {
		//stop location update, navigation,  to conserve battery
   		[[SKRoutingService sharedInstance] stopNavigation];
		[[SKPositionerService sharedInstance] cancelLocationUpdate];
		[self.audioManager cancel];
	}
}

- (void)didEnterForeground {
	self.isInBackground = NO;
	[SKTNavigationUtils cancelLocalNoficationWithUserInfoKey:kBackgroundLocalNotificationKey];

	[[SKPositionerService sharedInstance] startLocationUpdate];
    
	//if we were previously navigating and background mode was off we resume navigation
	if (([self hasState:SKTNavigationStateFreeDrive] || [self hasState:SKTNavigationStateNavigating]) && !self.configuration.allowBackgroundNavigation) {
		[[SKRoutingService sharedInstance] startNavigationWithSettings:self.navigationSettings];
		self.mapView.settings.displayMode = self.prefferedDisplayMode;
	}

	//we may have passed to day or night so we update style if needed
	if (self.configuration.automaticDayNight && self.receivedDayNightNotificationInBackground) {
		[self updateStyle];
	}
    
    self.receivedDayNightNotificationInBackground = NO;
    
    [self.audioManager resume];
}

- (void)applicationWillTerminate:(NSNotification *)notif {
    [SKTNavigationUtils cancelLocalNoficationWithUserInfoKey:kBackgroundLocalNotificationKey];
}

@end
