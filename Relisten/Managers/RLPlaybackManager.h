//
//  RLPlaybackManager.h
//  Relisten
//
//  Created by Alec Gorge on 9/3/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AGMediaItem.h"

#import <StreamingKit/STKAudioPlayer.h>

@interface RLPlaybackManager : NSObject<STKAudioPlayerDelegate>

+ (instancetype)sharedManagerForView:(NSView *)view;

@property (nonatomic) RACCommand *trackStarted;
@property (nonatomic) RACCommand *stateChanged;

@property (nonatomic, readonly) STKAudioPlayerState state;

// playing, buffering etc
@property (nonatomic, readonly) BOOL playing;
@property (nonatomic, readonly) BOOL buffering;
@property (strong, nonatomic) STKAudioPlayer *audioPlayer;

// an array of AGMediaItems
@property (nonatomic) NSMutableArray *playbackQueue;
@property (nonatomic, readonly) AGMediaItem *currentItem;
@property (nonatomic, readonly) AGMediaItem *nextItem;
@property (nonatomic, readonly) NSInteger nextIndex;

@property (nonatomic) NSInteger currentIndex;

- (void)replaceQueueWithItems:(NSArray *) queue startIndex:(NSInteger)index;
- (void)addItemsToQueue:(NSArray *)queue;

@property (nonatomic) BOOL shuffle;
@property (nonatomic) BOOL loop;
@property (nonatomic) float progress;
@property (nonatomic) NSTimeInterval elapsed;
@property (nonatomic, readonly) float duration;

- (void)forward;
- (void)play;
- (void)pause;
- (void)backward;
- (void)togglePlayPause;

@end
