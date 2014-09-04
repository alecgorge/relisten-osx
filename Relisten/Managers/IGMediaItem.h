//
//  IGMediaItem.h
//  Relisten
//
//  Created by Alec Gorge on 9/3/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import "AGMediaItem.h"

#import "IGAPIClient.h"

@interface IGMediaItem : AGMediaItem

- (instancetype)initWithTrack:(IGTrack *)track
                      andShow:(IGShow *)show;

@property (nonatomic) IGTrack *igTrack;
@property (nonatomic) IGShow *igShow;

@property (nonatomic) NSInteger id;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *album;
@property (nonatomic, assign) NSInteger track;
@property (nonatomic) NSImage *albumArt;

- (void)streamURL:(void(^)(NSURL *file))callback;

@property (nonatomic) NSString *displayText;
@property (nonatomic) NSString *displaySubText;

@property (nonatomic) NSString *shareText;
@property (nonatomic) NSURL *shareURL;

- (NSURL *)shareURLWithTime:(NSTimeInterval)seconds;

@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic) STKDataSource *dataSource;

@end
