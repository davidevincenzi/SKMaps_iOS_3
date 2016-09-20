//
//  NSString+Additions.h
//  
//

//

#import <Foundation/Foundation.h>

#define safeString(string) (string == nil ? @"" : string)

/** This category provides helper methods for strings
 */
@interface NSString (Additions)

/** Tells whether the string is not empty and not whitespace.
 */
- (BOOL)isNotEmptyOrWhiteSpace;

/** Tells whether the string is empty or whitespace.
 */
- (BOOL)isEmptyOrWhiteSpace;

@end
