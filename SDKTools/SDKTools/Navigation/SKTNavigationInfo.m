//
//  SKTNavigationInfo.m
//  SDKTools
//

//

#import "SKTNavigationInfo.h"

@implementation SKTNavigationInfo

- (void)reset {
    _currentCountryCode = @"";
    _currentSpeed = 0.0;
    _currentSpeedLimit = 0.0;
    _currentDTA = 0;
    _currentETA = 0;
    _nextStreetType = SKStreetTypeRoad;
    _currentStreetType = SKStreetTypeRoad;
    _secondNextStreetType = SKStreetTypeRoad;
    _isLastAdvice = NO;
}

@end
