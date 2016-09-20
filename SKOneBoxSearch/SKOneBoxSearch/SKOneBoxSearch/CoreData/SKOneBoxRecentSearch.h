//
//  SKOneBoxRecentSearch.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SKOneBoxRecentSearch : NSManagedObject

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *searchText;
@property (nonatomic, retain) NSNumber *frequency;

@end
