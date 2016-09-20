//
//  SKOneBoxLocalizationManager.h
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SKOneBoxLocalizedString(key, comment) [SKOneBoxLocalizationManager localizedStringForKey:(key) value:(comment)]

#define SKOneBoxSetLanguage(language) [SKOneBoxLocalizationManager setLanguage:(language)]

extern NSString * const kSKOneBoxLanguageDidChangeNotification;

@interface SKOneBoxLocalizationManager : NSObject

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment;
+ (void)setLanguage:(NSString *)language;
+ (void)resetLocalization;
+ (NSString *)language;

@end
