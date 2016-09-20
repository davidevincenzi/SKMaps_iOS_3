//
//  SKOneBoxSearchComparator.m
//  SKOSearchLib
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxSearchComparator.h"

@interface SKOneBoxSearchComparator ()

@property (nonatomic, strong) NSString  *sortTitle;
@property (nonatomic, strong) UIImage   *sortImage;
@property (nonatomic, strong) NSComparator comparator;
@property (nonatomic, strong) id sortingParameter;

@end

@implementation SKOneBoxSearchComparator

+(instancetype)sortingComparatorWithTitle:(NSString*)title image:(UIImage*)image activeImage:(UIImage *)activeImage comparator:(NSComparator)comparator {
    SKOneBoxSearchComparator *comparatorObj = [SKOneBoxSearchComparator new];
    comparatorObj.sortTitle = title;
    comparatorObj.sortImage = image;
    comparatorObj.comparator = comparator;
    comparatorObj.defaultSorting = NO;
    comparatorObj.sortActiveImage = activeImage;
    
    return comparatorObj;
}

+(instancetype)sortingComparatorWithTitle:(NSString*)title image:(UIImage*)image activeImage:(UIImage *)activeImage sortingParameter:(id)sortingParameter {
    SKOneBoxSearchComparator *comparatorObj = [SKOneBoxSearchComparator new];
    comparatorObj.sortTitle = title;
    comparatorObj.sortImage = image;
    comparatorObj.sortActiveImage = activeImage;
    comparatorObj.sortingParameter = sortingParameter;
    comparatorObj.defaultSorting = NO;
    return comparatorObj;
}

@end
