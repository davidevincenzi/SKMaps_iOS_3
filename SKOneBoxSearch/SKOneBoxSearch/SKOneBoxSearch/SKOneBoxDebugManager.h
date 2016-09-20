//
//  SKOneBoxDebugManager.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKOneBoxDebugManager : NSObject

@property (nonatomic,assign) BOOL testRelevancyEnabled;
@property (nonatomic,assign) BOOL markBadResults;

+ (instancetype)sharedInstance;

@end
