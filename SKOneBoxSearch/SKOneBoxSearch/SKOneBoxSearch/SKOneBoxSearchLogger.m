//
//  SKOneBoxSearchLogger.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxSearchLogger.h"

@implementation SKOneBoxSearchLogger

+(void)logSearchQuery:(NSString *)searchQuery location:(CLLocationCoordinate2D)coordinate {
    if (!searchQuery) {
        return;
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:@"https://oneboxsearch.herokuapp.com/saveSearchQuery"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys: searchQuery,@"searchText",[NSNumber numberWithFloat:coordinate.latitude],@"latitude",[NSNumber numberWithFloat:coordinate.longitude],@"longitude",
                             nil];
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&err];
    
    NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    [request setHTTPBody:jsonData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
    }];
    
    [postDataTask resume];
}

@end
