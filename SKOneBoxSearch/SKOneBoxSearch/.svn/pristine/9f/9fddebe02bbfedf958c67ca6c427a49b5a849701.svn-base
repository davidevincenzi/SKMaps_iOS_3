//
//  SKOneBoxCoreDataManager.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SKOneBoxRecentSearch;

@interface SKOneBoxCoreDataManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;

+ (SKOneBoxCoreDataManager *)sharedInstance;

- (void)save;

@end

@interface SKOneBoxCoreDataManager (Searches)

- (SKOneBoxRecentSearch *)createEmptySearch;
- (NSArray *)searchList;
- (NSArray *)searchListUsingPredicate:(NSPredicate*)predicate;

@end