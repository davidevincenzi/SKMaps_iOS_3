//
//  SKOneBoxSearchDelayer.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SKOneBoxSearchDelayerProtocol <NSObject>

- (void)shouldStartSearchWithText:(NSString *)searchText;

@end

@interface SKOneBoxSearchDelayer : NSObject

@property (nonatomic, weak) id<SKOneBoxSearchDelayerProtocol> delegate;

- (instancetype)initWithDefaultDelay:(double)delay;

- (double)delaySearchWithText:(NSString *)searchText;
- (void)cancelDelayedSearch;

@end
