//
//  SKOneBoxSearchObject.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxSearchObject.h"
#import "NSString+SKOneBoxStringAdditions.h"

@interface SKOneBoxSearchObject()

@property (strong, nonatomic) NSArray *searchTermComponents;
@property (strong, nonatomic) NSString *quotesString;

@end

@implementation SKOneBoxSearchObject

- (id)init {
    self = [super init];
    if (self) {
        self.coordinate = CLLocationCoordinate2DMake(0, 0);
        self.searchTerm = @"";
        self.itemsPerPage = @20;
        self.pageIndex = nil;
        self.pageToLoad = nil;
        self.searchLanguage = @"en";
        self.quotesString = nil;
    }
    return self;
}

+ (instancetype)oneBoxSearchObject {
    SKOneBoxSearchObject *oneBoxSearchObject = [[SKOneBoxSearchObject alloc] init];
    return oneBoxSearchObject;
}

#pragma mark - Public methods

- (BOOL)isEqualToSearchObject:(SKOneBoxSearchObject*)object {
    if ((self.searchTerm == object.searchTerm || [[self searchTerm] isEqualToString:[object searchTerm]])
        && self.coordinate.latitude == object.coordinate.latitude
        && self.coordinate.longitude == object.coordinate.longitude
        && ([self searchLanguage] == [object searchLanguage] || [[self searchLanguage] isEqualToString:[object searchLanguage]])
        && ([self quotesString] == [object quotesString] || [[self quotesString] isEqual:[object quotesString]])) {
            return YES;
        }
    return NO;
}

- (long)numberOfComponents {
    return self.searchTermComponents.count;
}

- (BOOL)nameMatchesWithString:(NSString *)value {
    if (value.length <= 0) {
        return NO;
    }
    
    NSString *term = [self getNameOfLocationFromSearchTerm];

    return [self term:term matchesValue:value];
}

- (NSString *)quoteString {
    return self.quotesString;
}

#pragma mark - Overwritten

- (void)setSearchTerm:(NSString *)searchTerm {
    if (searchTerm) {
        // Set the quotes string
        [self setQuotesStringBasedOnString:searchTerm];
        
        // Remove special characters
        NSString *termWithoutSpecialCharacters = [NSString removeSearchSpecialCharacters:searchTerm];
        
        // Remove extra white spaces and sequances of same special character
        _searchTerm = [self removeExtraWhiteSpacesAndMultipleSpecialCharacter:termWithoutSpecialCharacters];
        
        [self calculateComponentsOfSearchTerm];
    }
}

#pragma mark - Private methods

- (void)setQuotesStringBasedOnString:(NSString *)value {
    NSMutableArray *target = [NSMutableArray array];
    NSScanner *scanner = [NSScanner scannerWithString:value];
    NSString *tmp;
    
    while ([scanner isAtEnd] == NO)
    {
        [scanner scanUpToString:@"\"" intoString:NULL];
        [scanner scanString:@"\"" intoString:NULL];
        [scanner scanUpToString:@"\"" intoString:&tmp];
        if ([scanner isAtEnd] == NO && tmp)
            [target addObject:tmp];
        [scanner scanString:@"\"" intoString:NULL];
    }
    
    self.quotesString = [target componentsJoinedByString:@" "];
}

- (void)calculateComponentsOfSearchTerm {
    // Replace all the spaces with ','
    NSString *commasString = [self.searchTerm stringByReplacingOccurrencesOfString:@" " withString:@","];
    
    // Split string by , to see all the components
    NSArray *splitedString = [commasString componentsSeparatedByString:@","];
    
    NSMutableArray *actualComponents = [NSMutableArray new];

    for (NSString *value in splitedString) {
        if (value.length > 0) {
            [actualComponents addObject:value];
        }
    }
    
    self.searchTermComponents = actualComponents;
}

- (NSString *)removeExtraWhiteSpacesAndMultipleSpecialCharacter:(NSString *)value {
    // Replace all sequences of spaces with a single one
    
    NSString *newValue = [NSString stringWithString:value];
    
    for (int i = 0; i < kSKOneBoxSearchObjectSpecialCharacters.length; i++) {
        unichar character = [kSKOneBoxSearchObjectSpecialCharacters characterAtIndex:i];
        
        NSString *regexString = [NSString stringWithFormat:@"[%c]+",character];
        
        newValue = [newValue stringByReplacingOccurrencesOfString:regexString
                                                   withString:[NSString stringWithFormat:@"%c",character]
                                                      options:NSRegularExpressionSearch
                                                        range:NSMakeRange(0, newValue.length)];
    }
    
    NSString *squashed = [newValue stringByReplacingOccurrencesOfString:@"[ ]+"
                                                                    withString:@" "
                                                                       options:NSRegularExpressionSearch
                                                                         range:NSMakeRange(0, newValue.length)];
    
    // Remove leading and trailing white characters
    NSString *correctlySpacedString = [squashed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return correctlySpacedString;
}

/** Tries to get the name of the search location
 If there is a ',' then fetch the first part the one before the comma, otherwise return the string
 */
- (NSString *)getNameOfLocationFromSearchTerm {
    // Check if the search term contains ',' if so, get only the first part
    NSString *term = [self.searchTerm copy];
    
    if ([self.searchTerm containsString:@","]) {
        NSArray *commaValues = [self.searchTerm componentsSeparatedByString:@","];
        
        if (commaValues.count > 0) {
            NSString *firstPart = commaValues[0];
            
            if (firstPart.length > 0) {
                term = firstPart;
            }
        }
    }
    
    return term;
}

- (BOOL)term:(NSString *)value matchesValue:(NSString *)string {
    // Split the term in components, by spaces, compare the with wich one of them
    NSArray *termComponents = [value componentsSeparatedByString:@" "];
    NSArray *valueComponents = [string componentsSeparatedByString:@" "];
    
    for (NSString *term in termComponents) {
        for (NSString *value in valueComponents) {
            // Compare levenstein distance between them
            double distance = 0.0f;
            
            if ([term matchesTerm:value distance:&distance]) {
                return YES;
            }
            
        }
    }
    
    return NO;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    SKOneBoxSearchObject *copy = [[[self class] allocWithZone:zone] init];
    copy.coordinate = self.coordinate;
    
    copy.searchTerm = self.searchTerm;
    copy.quotesString = self.quotesString;
    copy.itemsPerPage = self.itemsPerPage;
    copy.pageIndex = self.pageIndex;
    copy.pageToLoad = self.pageToLoad;
    copy.radius = self.radius;
    copy.searchCategory = self.searchCategory;
    copy.searchSort = self.searchSort;
    copy.searchLanguage = self.searchLanguage;
    copy.uid = self.uid;
    
    return copy;
}

@end
