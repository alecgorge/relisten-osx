//
//  AGMediaItem.m
//  iguana
//
//  Created by Alec Gorge on 3/3/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "AGMediaItem.h"

@implementation AGMediaItem

- (NSURL *)shareURLWithTime:(NSTimeInterval)seconds {
    return self.shareURL;
}

- (BOOL)isEqual:(id)object {
    if(![object isKindOfClass:AGMediaItem.class]) return NO;
    
    return self.id == ((AGMediaItem*)object).id;
}

- (void)streamURL:(void (^)(NSURL *))callback {
    NSAssert(NO, @"this needs to be overridden");
}

- (BOOL)isDownloadingOrQueued {
    return NO;
}

- (BOOL)isCacheable {
	return NO;
}

- (BOOL)isCached {
	return NO;
}

- (NSURL *)cachedFile {
	return nil;
}

@end
