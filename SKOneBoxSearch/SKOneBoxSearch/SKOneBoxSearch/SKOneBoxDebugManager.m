//
//  SKOneBoxDebugManager.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxDebugManager.h"

@implementation SKOneBoxDebugManager

#pragma mark - Lifecycle

+ (instancetype)sharedInstance {
    static SKOneBoxDebugManager *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SKOneBoxDebugManager alloc] init];
    });
    
    return sharedInstance;
}

-(id)init {
    self = [super init];
    if (self) {
        self.testRelevancyEnabled = NO;
    }
    return self;
}

-(void)setTestRelevancyEnabled:(BOOL)testRelevancyEnabled {
    _testRelevancyEnabled = testRelevancyEnabled;
    
    [[NSUserDefaults standardUserDefaults] setBool:testRelevancyEnabled forKey:@"kEnableResultFilteringByDistance"];
}

@end
