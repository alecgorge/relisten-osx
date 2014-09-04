
//
//  IGMediaItem.m
//  Relisten
//
//  Created by Alec Gorge on 9/3/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import "IGMediaItem.h"

@implementation IGMediaItem

- (instancetype)initWithTrack:(IGTrack *)track andShow:(IGShow *)show {
    if (self = [super init]) {
        self.igTrack = track;
        self.igShow = show;
    }
    
    return self;
}

-(NSInteger)id {
    return self.igTrack.id;
}

- (NSString *)title {
    return self.igTrack.title;
}

- (NSString *)artist {
    return self.igShow.artist.name;
}

- (NSString *)album {
    return self.igShow.displayDate;
}

- (NSInteger)track {
    return self.igTrack.track;
}

- (void)streamURL:(void (^)(NSURL *))callback {
    callback(self.igTrack.mp3);
}

- (NSString *)displayText {
    return self.title;
}

- (NSString *)displaySubText {
    return [NSString stringWithFormat:@"%@ — %@ — %@, %@", self.artist, self.album, self.igShow.venue.name, self.igShow.venue.city];
}

- (NSString *)shareText {
    return nil;
}

- (NSURL *)shareURL {
    return nil;
}

- (NSURL *)shareURLWithTime:(NSTimeInterval)seconds {
    return nil;
}

- (NSTimeInterval)duration {
    return self.igTrack.length;
}

@end
