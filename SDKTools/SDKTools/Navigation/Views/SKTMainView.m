//
//  NavigationView.m
//  FrameworkIOSDemo
//

//

#import "SKTMainView.h"
#import "SKTWaitingGPSSignalView.h"
#import "SKTLostGPSSignalView.h"
#import "SKTRouteProgressView.h"
#import "SKTNavigationSpeedLimitView.h"
#import "SKTNavigationDoubleLabelView.h"
#import "SKTNavigationETAView.h"
#import "SKTNavigationDoubleLabelView.h"
#import "SKTInsetLabel.h"
#import "SKTNavigationCalculatingRouteView.h"
#import "SKTReroutingInfoView.h"
#import "SKTNavigationFreeDriveView.h"
#import "SKTNavigationPanningView.h"
#import "SKTNavigationSettingsView.h"
#import "SKTAnimatedLabel.h"
#import "SKTNavigationBlockRoadsView.h"
#import "SKTNavigationOverviewView.h"
#import "SKTNavigationInfoView.h"
#import "SKTNavigationView.h"

@interface SKTMainView () <SKTBaseViewDelegate>

@end

@implementation SKTMainView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
        [self addNavigationView];
		[self addFreeDriveView];
        self.touchTransparent = YES;
        
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}

	return self;
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    
    //by default the delegate is set to self and forwarded to this view's delegate
    //this is to remove the need of setting the delegate for each view separately
    if ([view isKindOfClass:[SKTBaseView class]]) {
        SKTBaseView *baseView = (SKTBaseView *)view;
        baseView.baseViewDelegate = self;
        [baseView updateStatusBarStyle];
    }
}

#pragma mark - Overidden

- (void)layoutSubviews {
	[super layoutSubviews];

	CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
	CGFloat statusBarHeight = MIN(20.0, MIN(statusBarSize.width, statusBarSize.height));
    CGFloat offset = (self.isUnderStatusBar ? statusBarHeight : 0.0);
    self.contentYOffset = offset;
}

#pragma mark - UI creation

- (void)addNavigationView {
    _navigationView = [[SKTNavigationView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, self.frameHeight)];
    _navigationView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _navigationView.hidden = YES;
    [self addSubview:_navigationView];
}

- (void)addFreeDriveView {
	//free drive street label covers the top of the screen
	_freeDriveView = [[SKTNavigationFreeDriveView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, self.frameHeight)];
	_freeDriveView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_freeDriveView.backgroundColor = [UIColor clearColor];
	_freeDriveView.hidden = YES;
	[self addSubview:_freeDriveView];
}

#pragma mark - SKTBaseViewDelegate

- (void)baseView:(SKTBaseView *)view requiresStatusBarStyle:(UIStatusBarStyle)style {
    if ([self.baseViewDelegate respondsToSelector:@selector(baseView:requiresStatusBarStyle:)]) {
        [self.baseViewDelegate baseView:view requiresStatusBarStyle:style];
    }
}

@end
