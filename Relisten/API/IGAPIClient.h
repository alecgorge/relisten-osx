//
//  IGAPIClient.h
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <AFHTTPSessionManager.h>

#import "IGYear.h"
#import "IGShow.h"
#import "IGVenue.h"
#import "IGArtist.h"

@interface IGAPIClient : AFHTTPSessionManager

+ (instancetype)sharedInstance;

// an array of IGArtist
- (void)artists:(void(^)(NSArray *))success;

// an array of IGYear
- (void)years:(void (^)(NSArray *))success
    forArtist:(IGArtist *)artist;

- (void)year:(NSUInteger)year
     success:(void (^)(IGYear *))success
   forArtist:(IGArtist *)artist;

// an array of IGShow
- (void)showsOn:(NSString *)displayDate
        success:(void (^)(NSArray *))success
      forArtist:(IGArtist *)artist;

- (void)randomShow:(void (^)(NSArray *))success
         forArtist:(IGArtist *)artist;

// venues
- (void)venues:(void (^)(NSArray *))success
     forArtist:(IGArtist *)artist;

- (void)venue:(IGVenue *)venue
      success:(void (^)(IGVenue *))success
    forArtist:(IGArtist *)artist;

- (void)topShows:(void (^)(NSArray *))success
       forArtist:(IGArtist *)artist;

@end
