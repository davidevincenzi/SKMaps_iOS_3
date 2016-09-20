//
//  NSString+FuzzyStringSearch.h
//  SKOSearchLib
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FuzzyStringSearch)

- (float)normalizedSubstringSimilaritySubstring:(NSString*)needleString;
- (float)substringSimilaritySubstring:(NSString*)needleString;

@end
