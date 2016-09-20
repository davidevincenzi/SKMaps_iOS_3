//
//  SKOneBoxSearchDelayer.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxSearchDelayer.h"

#define kMaxSpeedChangeInPercentage 2.5

@interface SKOneBoxSearchDelayer ()

@property (nonatomic, strong) NSTimer   *timer;
@property (nonatomic, strong) NSDate    *lastFireDate;

@property (nonatomic, assign) double    defaultDelay;
@property (nonatomic, assign) BOOL      isCanceled;
@end

@implementation SKOneBoxSearchDelayer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.defaultDelay = 0.5;
        self.isCanceled = NO;
    }
    return self;
}

- (instancetype)initWithDefaultDelay:(double)delay {
    self = [super init];
    if (self) {
        self.defaultDelay = delay / kMaxSpeedChangeInPercentage;
    }
    return self;
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

- (double)delaySearchWithText:(NSString *)searchText {
    NSDate *currentDate = [NSDate date];
    double deltaDelay = [currentDate timeIntervalSinceDate:self.lastFireDate];
    self.lastFireDate = currentDate;
    
    [self cancelDelayedSearch];
    
    deltaDelay = MIN(deltaDelay, self.defaultDelay);
    if (!deltaDelay) {
        deltaDelay = self.defaultDelay;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldStartSearchWithText:)]) {
        self.isCanceled = NO;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:deltaDelay * kMaxSpeedChangeInPercentage target:self selector:@selector(shouldStartSearch:) userInfo:searchText repeats:NO];
    }
    
    return deltaDelay;
}

- (void)cancelDelayedSearch {
    self.isCanceled = YES;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)shouldStartSearch:(NSTimer *)timer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldStartSearchWithText:)] && !self.isCanceled) {
        [self.delegate shouldStartSearchWithText:timer.userInfo];
    }
}

@end
