//
//  NSString+SKOneBoxStringAdditions.m
//  SKOSearchLib
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "NSString+SKOneBoxStringAdditions.h"
#import "SKOSearchLibUtils.h"
#import "NSString+FuzzyStringSearch.h"

int const kFullWordMultiplier = 1;
int const kMinCharactersMatch = 3;

@implementation NSString (SKOneBoxStringAdditions)

/** Removes special characters from the string
 http://stackoverflow.com/a/4686064/1806119
 The only characters allowed in the search are the following: all alpha numerical characters, ",", "?", "!", "#", ".", " "
 As this characters could be in a name of a search, or on its location
 */
+ (NSString *)removeSearchSpecialCharacters:(NSString *)specialCharacters {
    NSMutableCharacterSet *strippedCharacters = [NSMutableCharacterSet new];
    
    // Add special allowed charactere
    [strippedCharacters addCharactersInString:kSKOneBoxSearchObjectSpecialCharacters];
    
    // Add leters characters from all languages including accents characters
    [strippedCharacters formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]];
    
    // Add number characters
    [strippedCharacters formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    // Invert the set to obtain all the other characters which need to be removed
    [strippedCharacters invert];
    
    // Strip all the characters from the string
    NSString *returnValue = [specialCharacters stringByTrimmingCharactersInSet:strippedCharacters];
    
    return returnValue;
}

- (double)matchDistanceForTerm:(NSString*)term {
    if (!term.length) {
        return 0;
    }
    
    if (term.length < kMinCharactersMatch) { //minimum of 3 chars to match
        return 0;
    }
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSString *editedTerm = [[term lowercaseString] stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:usLocale];
    NSString *editedSelf = [[self lowercaseString] stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:usLocale];
    
    double result = [editedSelf substringSimilaritySubstring:editedTerm];
    
    return result;
}


- (BOOL)matchesTerm:(NSString *)term distance:(double*)distance {
    *distance = 0;
    
    if (!term.length) {
        return NO;
    }
    
    if (term.length < kMinCharactersMatch) { //minimum of 3 chars to match
        return NO;
    }
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSString *editedTerm = [[term lowercaseString] stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:usLocale];
    NSString *editedSelf = [[self lowercaseString] stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:usLocale];
    
    __block BOOL match = NO;
    
    //look through whole words
    [editedSelf enumerateSubstringsInRange:NSMakeRange(0, editedSelf.length) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        double result = [substring normalizedSubstringSimilaritySubstring:editedTerm];
        
        if (result >= 0.8f && result > *distance) { //set only the highest
            match = YES;
            *distance = result * kFullWordMultiplier;
        }

//        [term enumerateSubstringsInRange:NSMakeRange(0, term.length) options:NSStringEnumerationByWords usingBlock:^(NSString *termSubstring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
//            NSUInteger distance = [SKOSearchLibUtils levenshteinDistanceFirstString:substring.lowercaseString secondString:termSubstring.lowercaseString];
//            
//            // Why?
////            if (termSubstring.length <= 5) {
////                match = match || distance == 1;
////                return;
////            }
//            
//            double differencePercent;
//            if (distance > termSubstring.length) {
//                differencePercent = termSubstring.length / (double)distance;
//            } else {
//                differencePercent = distance / (double)termSubstring.length;
//            }
//            
////            NSLog(@"Search term: %@ matched search term: %@? %f", self, term, differencePercent);
//            match = match || differencePercent <= 0.2;
//        }];
    }];
    
    return match;
}

@end
