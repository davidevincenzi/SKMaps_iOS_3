//
//  NSString+FuzzyStringSearch.m
//  SKOSearchLib
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "NSString+FuzzyStringSearch.h"
#include <string>
#include <vector>

@implementation NSString (FuzzyStringSearch)

//http://ginstrom.com/scribbles/2007/12/01/fuzzy-substring-matching-with-levenshtein-distance-in-python/
int fuzzy_substring(const std::string& needle,
                    const std::string& haystack) {
    const int nlen = (int)needle.size(),
    hlen = (int)haystack.size();
    if (hlen == 0) {
        return -1;
    }
    if (nlen == 1)  {
        return (int)haystack.find(needle);
    }
    std::vector<int> row1(hlen+1, 0);
    for (int i = 0; i < nlen; ++i) {
        std::vector<int> row2(1, i+1);
        for (int j = 0; j < hlen; ++j) {
            const int cost = needle[i] != haystack[j];
            row2.push_back(std::min(row1[j+1]+1,
                                    std::min(row2[j]+1,
                                             row1[j]+cost)));
        }
        row1.swap(row2);
    }
    return *std::min_element(row1.begin(), row1.end());
}

- (float)normalizedSubstringSimilaritySubstring:(NSString*)needleString {
    float minLen = needleString.length;
    
    if (minLen == 0.0f)
        return 1.0f;
    
    float dis = [self substringSimilaritySubstring:needleString];
    
    return 1.0f - dis / minLen;
}

- (float)substringSimilaritySubstring:(NSString*)needleString {
    NSString *haystack = self.length >= needleString.length ? self : needleString;
    NSString *needle = self.length < needleString.length ? self : needleString;
    
    std::string needleStdString = std::string([needle UTF8String]);
    std::string haystackStdString = std::string([haystack UTF8String]);
    
    float dis = fuzzy_substring(needleStdString, haystackStdString);
    
    return dis;
}

@end
