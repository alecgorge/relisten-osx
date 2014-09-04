//
//  IGAPIClient.m
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGAPIClient.h"

#import "IGIguanaAppConfig.h"

@implementation IGAPIClient

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithBaseURL:IGIguanaAppConfig.apiBase];
    });
    return sharedInstance;
}

- (void)failure:(NSError *)error {
    DDLogError(@"Network Error: %@", error);
    
    NSAlert *a = [NSAlert alertWithMessageText:@"Network Error"
                                 defaultButton:@"OK"
                               alternateButton:nil
                                   otherButton:nil
                     informativeTextWithFormat:@"A network error has been encountered. Try again? %@", error.localizedDescription];
    [a runModal];
}

- (void)artists:(void (^)(NSArray *))success {
    [self GET:@"artists"
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGArtist *y = [[IGArtist alloc] initWithDictionary:item
                                                           error:&err];
              
              if(err) {
                  [self failure: err];
                  DDLogError(@"json err: %@", err);
              }
              
              return y;
          }];
          
          success(r);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

- (NSString *)apiPath:(NSString *)path
            forArtist:(IGArtist *)artist {
    return [NSString stringWithFormat:@"artists/%@/%@", artist.slug, path];
}

- (void)years:(void (^)(NSArray *))success forArtist:(IGArtist *)artist {
    [self GET:[self apiPath:@"years" forArtist:artist]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGYear *y = [[IGYear alloc] initWithDictionary:item
                                                       error:&err];
              
              if(err) {
                  [self failure: err];
                  DDLogError(@"json err: %@", err);
              }
              
              y.artist = artist;
              
              return y;
          }];
          
          success(r);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

- (void)venues:(void (^)(NSArray *))success forArtist:(IGArtist *)artist {
    [self GET:[self apiPath:@"venues" forArtist:artist]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGVenue *y = [[IGVenue alloc] initWithDictionary:item
                                                       error:&err];
              
              if(err) {
                  [self failure: err];
                  DDLogError(@"json err: %@", err);
              }
              
              y.artist = artist;
              
              return y;
          }];
          
          success(r);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

- (void)year:(NSUInteger)year success:(void (^)(IGYear *))success forArtist:(IGArtist *)artist {
    [self GET:[self apiPath:[@"years/" stringByAppendingFormat:@"%lu", (unsigned long)year] forArtist:artist]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSError *err;
          IGYear *y = [[IGYear alloc] initWithDictionary:responseObject[@"data"]
                                                   error:&err];
          
          if(err) {
              [self failure: err];
              DDLogError(@"json err: %@", err);
          }
          
          y.artist = artist;
          
          [y.shows each:^(IGShow *show) {
              show.artist = artist;
          }];
          
          success(y);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

- (void)venue:(IGVenue *)venue success:(void (^)(IGVenue *))success forArtist:(IGArtist *)artist {
    [self GET:[self apiPath:[@"venues/" stringByAppendingFormat:@"%lu", (unsigned long)venue.id] forArtist:artist]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSError *err;
          IGVenue *y = [[IGVenue alloc] initWithDictionary:responseObject[@"data"]
													 error:&err];
          
          if(err) {
              [self failure: err];
              DDLogError(@"json err: %@", err);
          }
          
          y.artist = artist;
          
          success(y);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

- (void)topShows:(void (^)(NSArray *))success forArtist:(IGArtist *)artist {
    [self GET:[self apiPath:@"top_shows" forArtist:artist]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGShow *y = [[IGShow alloc] initWithDictionary:item
                                                       error:&err];
              
              if(err) {
                  [self failure: err];
                  DDLogError(@"json err: %@", err);
              }
              else {
                  for(IGTrack *t in y.tracks) {
                      t.show = y;
                  }
              }
              
              y.artist = artist;
              
              return y;
          }];
          
          success(r);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

- (void)showsOn:(NSString *)displayDate success:(void (^)(NSArray *))success forArtist:(IGArtist *)artist {
    [self GET:[self apiPath:[@"years/" stringByAppendingFormat:@"%@/shows/%@", [displayDate substringToIndex:4], displayDate] forArtist:artist]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGShow *y = [[IGShow alloc] initWithDictionary:item
                                                       error:&err];
              
              if(err) {
                  [self failure: err];
                  DDLogError(@"json err: %@", err);
              }
              else {
                  for(IGTrack *t in y.tracks) {
                      t.show = y;
                  }
              }
              
              y.artist = artist;
              
              return y;
          }];
          
          success(r);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

- (void)randomShow:(void (^)(NSArray *))success forArtist:(IGArtist *)artist {
    [self GET:[self apiPath:@"random_show" forArtist:artist]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGShow *y = [[IGShow alloc] initWithDictionary:item
                                                       error:&err];
              
              if(err) {
                  [self failure: err];
                  DDLogError(@"json err: %@", err);
              }
              else {
                  for(IGTrack *t in y.tracks) {
                      t.show = y;
                  }
              }
              
              y.artist = artist;
              
              return y;
          }];
          
          success(r);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

@end
