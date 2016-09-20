//
//  SKOneBoxSearchComparator.h
//  SKOSearchLib
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** Object containing details about a search comparison.
 */
@interface SKOneBoxSearchComparator : NSObject

/** Sorting title to be displayed in the UI.
 */
@property (nonatomic, strong, readonly) NSString *sortTitle;

/** Sorting image to be displayed in the UI.
 */
@property (nonatomic, strong, readonly) UIImage *sortImage;

/** Sorting image to be displayed in the UI when the comparator is active.
 */
@property (nonatomic, strong) UIImage *sortActiveImage;

/** NSComparator to be used to sort 2 SKOneBoxSearchResults.
 */
@property (nonatomic, strong, readonly) NSComparator comparator;

/** The type of the sorting to be sent to the Search API. String/Number, parameter that needs to be sent to the Search API.
 */
@property (nonatomic, strong, readonly) id sortingParameter;

/** Boolean indicating if this is the default sorting option.
 */
@property (nonatomic, assign) BOOL defaultSorting;

/**Creates an configured SKOneBoxSearchComparator
 @param title Title for the search comparator.
 @param image Image for the search comparator.
 @param activeImage Image for the search comparator in the active state.
 @param comparator NSComparator for the search comparator.
 @return - an configured autoreleased object
 */
+ (instancetype)sortingComparatorWithTitle:(NSString *)title image:(UIImage *)image activeImage:(UIImage *)activeImage comparator:(NSComparator)comparator;

/**Creates an configured SKOneBoxSearchComparator
 @param title Title for the search comparator.
 @param image Image for the search comparator.
 @param sortingParameter Sorting parameter for the search comparator.
 @return - an configured autoreleased object
 */
+ (instancetype)sortingComparatorWithTitle:(NSString *)title image:(UIImage *)image activeImage:(UIImage *)activeImage sortingParameter:(id)sortingParameter;

@end
