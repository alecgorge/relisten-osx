//
//  IGIguanaAppConfig.m
//  iguana
//
//  Created by Alec Gorge on 3/1/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGIguanaAppConfig.h"

@implementation IGIguanaAppConfig

+ (NSString *)appName {
    return NSBundle.mainBundle.infoDictionary[@"iguana"][@"app_name"];
}

+ (NSString *)siteBase {
    return NSBundle.mainBundle.infoDictionary[@"iguana"][@"site_base"];
}

+ (NSString *)twitterHandle {
    return NSBundle.mainBundle.infoDictionary[@"iguana"][@"twitter_handle"];
}

+ (NSURL *)apiBase {
    return [NSURL URLWithString:NSBundle.mainBundle.infoDictionary[@"iguana"][@"iguana_api_base"]];
}

+ (NSString *)itunesAppId {
    return NSBundle.mainBundle.infoDictionary[@"iguana"][@"itunes_app_id"];
}

@end
