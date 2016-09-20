//
//  NSString+SKOneBoxStringAdditions.h
//  SKOSearchLib
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSKOneBoxSearchObjectSpecialCharacters  @",. !?#&"

@interface NSString (SKOneBoxStringAdditions)

/** Removes special characters from the string
 http://stackoverflow.com/a/4686064/1806119
 The only characters allowed in the search are the following: all alpha numerical characters, ",", "?", "!", "#", ".", " ", "&"
 As this characters could be in a name of a search, or on its location
 */
+ (NSString *)removeSearchSpecialCharacters:(NSString *)specialCharacters;

- (double)matchDistanceForTerm:(NSString*)term;

- (BOOL)matchesTerm:(NSString *)term distance:(double*)distance;

@end
