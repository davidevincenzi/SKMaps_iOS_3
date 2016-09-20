//
//  SKOneBoxLocalizationManager.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxLocalizationManager.h"

NSString * const kSKOneBoxLanguageDidChangeNotification = @"kSKOneBoxLanguageDidChangeNotification";

static NSBundle *bundle = nil;

@implementation SKOneBoxLocalizationManager

#pragma mark - Abstract class implementation

- (instancetype)init {
    return self = nil;
}

#pragma mark - Public methods

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment {
    NSString *bundleID = [[self bundle] bundleIdentifier];
    
    if ([bundleID isEqualToString:@"SkobblerNordics"]) {
        NSString *normalString = [[self bundle] localizedStringForKey:key value:comment table:nil];
        
        return [[self bundle] localizedStringForKey:[key stringByAppendingString:@"_nordics"] value:normalString table:nil];
    } else {
        return [[self bundle] localizedStringForKey:key value:comment table:nil];
    }
}

+ (void)setLanguage:(NSString *)language {
    if ([language isEqualToString:@"en_us"]) {
        language = @"en";
    }
    
    NSString *path = [[self bundle] pathForResource:language ofType:@"lproj"];
    
    if (!path) {
        [self resetLocalization];
    } else {
        [SKOneBoxLocalizationManager setBundle:[NSBundle bundleWithPath:path]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSKOneBoxLanguageDidChangeNotification object:nil];
}

+ (void)resetLocalization {
    //path for resources
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"];
    [self setBundle:[NSBundle bundleWithPath:path]];
}

+ (NSString *)language {
    NSString *preferredLang = [[[self bundle] resourcePath] lastPathComponent];
    NSArray *components = [preferredLang componentsSeparatedByString:@"."];
    preferredLang = [components objectAtIndex:0];
    
    return preferredLang;
}

#pragma mark - Private methods

+ (void)setBundle:(NSBundle *)newBundle {
    if (newBundle != bundle) {
        bundle = newBundle;
    }
}

+ (NSBundle *)bundle {
    if (!bundle) {
        [self resetLocalization];
    }
    [bundle load];
    
    return bundle;
}

@end
