//
//  RLPlaybackManager.m
//  Relisten
//
//  Created by Alec Gorge on 9/3/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import "RLPlaybackManager.h"

#import <StreamingKit/STKAutoRecoveringHTTPDataSource.h>

#import "IGDurationHelper.h"

@interface RLPlaybackManager ()

@property (nonatomic) NSView *view;

@property (nonatomic, readonly) NSButton *uiRewindButton;
@property (nonatomic, readonly) NSButton *uiPlayButton;
@property (nonatomic, readonly) NSButton *uiPauseButton;
@property (nonatomic, readonly) NSButton *uiForwardButton;

@property (nonatomic, readonly) NSTextField *uiTitleLabel;
@property (nonatomic, readonly) NSTextField *uiSubTitleLabel;
@property (nonatomic, readonly) NSTextField *uiStatusLabel;

@property (nonatomic, readonly) NSTextField *uiTimeElapsedLabel;
@property (nonatomic, readonly) NSTextField *uiTimeRemainingLabel;

@property (nonatomic, readonly) NSSlider *uiProgressSlider;
@property (nonatomic, readonly) NSSlider *uiVolumeSlider;

@end

@implementation RLPlaybackManager

+ (instancetype)sharedManagerForView:(NSView *)view {
    static RLPlaybackManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] initWithView:view];
    });
    
    return _sharedManager;
}

- (instancetype)initWithView:(NSView *)view {
    if (self = [super init]) {
        self.view = view;
        
        self.audioPlayer = STKAudioPlayer.alloc.init;
        self.audioPlayer.delegate = self;
        
        self.trackStarted = [RACCommand.alloc initWithSignalBlock:^RACSignal *(AGMediaItem *item) {
            return [RACSignal return:item];
        }];
        
        self.stateChanged = [RACCommand.alloc initWithSignalBlock:^RACSignal *(RLPlaybackManager *manager) {
            return [RACSignal return:manager];
        }];
        
        [self setupUI];
    }
    
    return self;
}

- (NSView *)viewWithIdentifier:(NSString *)identifier {
    for (NSView *sview in self.view.subviews) {
        if ([sview.identifier isEqualToString:identifier]) {
            return sview;
        }
    }
    
    return nil;
}

#pragma mark - UI Glue

- (NSButton *)uiRewindButton {
    return (NSButton*)[self viewWithIdentifier:@"rewind"];
}

- (NSButton *)uiPlayButton {
    return (NSButton*)[self viewWithIdentifier:@"play"];
}

- (NSButton *)uiPauseButton {
    return (NSButton*)[self viewWithIdentifier:@"pause"];
}

- (NSButton *)uiForwardButton {
    return (NSButton*)[self viewWithIdentifier:@"forward"];
}

- (NSTextField *)uiTitleLabel {
    return (NSTextField *)[self viewWithIdentifier:@"title"];
}

- (NSTextField *)uiSubTitleLabel {
    return (NSTextField *)[self viewWithIdentifier:@"subtitle"];
}

- (NSTextField *)uiStatusLabel {
    return (NSTextField *)[self viewWithIdentifier:@"status"];
}

- (NSTextField *)uiTimeElapsedLabel {
    return (NSTextField *)[self viewWithIdentifier:@"timeElapsed"];
}

- (NSTextField *)uiTimeRemainingLabel {
    return (NSTextField *)[self viewWithIdentifier:@"totalTime"];
}

- (NSSlider *)uiProgressSlider {
    return (NSSlider *)[self viewWithIdentifier:@"progressSlider"];
}

- (NSSlider *)uiVolumeSlider {
    return (NSSlider *)[self viewWithIdentifier:@"volumeSlider"];
}

- (void)uiProgressChangeRequested:(NSSlider *)sender {
    self.progress = sender.floatValue;
}

- (void)uiVolumeChangeRequested:(NSSlider *)sender {
    self.audioPlayer.volume = sender.floatValue;
}

#pragma mark - UI Drawing

- (void)setupUI {
    self.uiVolumeSlider.floatValue = self.audioPlayer.volume;
    self.uiProgressSlider.floatValue = 0;
    
    self.uiStatusLabel.stringValue = @"";
    self.uiTitleLabel.stringValue = @"";
    self.uiSubTitleLabel.stringValue = @"";
    
    self.uiForwardButton.enabled = NO;
    self.uiRewindButton.enabled = NO;
    self.uiPlayButton.enabled = NO;
    self.uiPauseButton.enabled = NO;
    
    self.uiPauseButton.target = self.uiPlayButton.target = self.uiForwardButton.target =
    self.uiRewindButton.target = self.uiVolumeSlider.target = self.uiProgressSlider.target = self;
    
    self.uiPauseButton.action = @selector(pause);
    self.uiPlayButton.action = @selector(play);
    self.uiForwardButton.action = @selector(forward);
    self.uiRewindButton.action = @selector(backward);
    
    self.uiProgressSlider.action = @selector(uiProgressChangeRequested:);
    self.uiVolumeSlider.action = @selector(uiVolumeChangeRequested:);
    
    [self startUpdates];
}

// no expensive calculations, just make UI is synced
- (void)redrawUI {
    self.uiPauseButton.hidden = !(self.playing || self.buffering);
    self.uiPlayButton.hidden = self.playing || self.buffering;
    self.uiPlayButton.enabled = YES;
    self.uiPauseButton.enabled = YES;
    
    if(self.playbackQueue.count > 0) {
        self.uiVolumeSlider.floatValue = self.audioPlayer.volume;

        self.uiRewindButton.enabled = self.currentIndex != 0;
        self.uiForwardButton.enabled = self.currentIndex < self.playbackQueue.count;
        
        self.uiTimeElapsedLabel.stringValue = [IGDurationHelper formattedTimeWithInterval:self.elapsed];
        self.uiTimeRemainingLabel.stringValue = [IGDurationHelper formattedTimeWithInterval:self.duration];
        
        self.uiProgressSlider.floatValue = self.progress;
        
        self.uiTitleLabel.stringValue = self.currentItem.displayText;
        self.uiSubTitleLabel.stringValue = self.currentItem.displaySubText;
    }
    
//	if(!self.currentTrackHasBeenScrobbled && self.progress > .5) {
//        if (IGThirdPartyKeys.sharedInstance.isLastFmEnabled) {
//            [[LastFm sharedInstance] sendScrobbledTrack:self.currentItem.title
//                                               byArtist:self.currentItem.artist
//                                                onAlbum:self.currentItem.album
//                                           withDuration:self.audioPlayer.duration
//                                            atTimestamp:(int)[[NSDate date] timeIntervalSince1970]
//                                         successHandler:nil
//                                         failureHandler:nil];
//        }
//        
//        [IGEvents trackEvent:@"played_track"
//              withAttributes:@{@"provider": NSStringFromClass(self.currentItem.class),
//                               @"title": self.currentItem.title,
//                               @"album": self.currentItem.album,
//                               @"is_cached_attr": @(self.currentItem.isCached).stringValue,
//                               @"artist": self.currentItem.artist}
//                  andMetrics:@{@"duration": [NSNumber numberWithFloat:self.duration],
//                               @"is_cached": [NSNumber numberWithBool:self.currentItem.isCached]}];
//        
//		self.currentTrackHasBeenScrobbled = YES;
//    }
}

- (void)startUpdates {
    [self redrawUI];
    
    [self performSelector:@selector(startUpdates)
               withObject:nil
               afterDelay:0.5];
}

#pragma mark - Public Interface

- (STKAudioPlayerState)state {
    return self.audioPlayer.state;
}

- (float)duration {
    if(self.audioPlayer.duration != 0) {
        return self.audioPlayer.duration;
    }
    
    return self.currentItem.duration;
}

- (BOOL)playing {
    return self.state == STKAudioPlayerStatePlaying;
}

- (BOOL)buffering {
    return self.state == STKAudioPlayerStateBuffering;
}

- (AGMediaItem *)currentItem {
    if (self.currentIndex >= self.playbackQueue.count) {
        return nil;
    }
    
    return self.playbackQueue[self.currentIndex];
}

- (NSInteger) nextIndex {
    if(self.loop) {
        return self.currentIndex;
    }
    else if(self.shuffle) {
        NSInteger randomIndex = -1;
        while(randomIndex == -1 || randomIndex == self.currentIndex)
            randomIndex = arc4random_uniform((u_int32_t)self.playbackQueue.count);
        return randomIndex;
    }
    else if(self.playbackQueue.count == 1) {
        return -1;
    }
    
    if(self.currentIndex + 1 >= self.playbackQueue.count) {
        return 0;
    }
    
    return self.currentIndex + 1;
}

- (AGMediaItem *)nextItem {
    if(self.nextIndex >= self.playbackQueue.count) {
        return nil;
    }
    
    return self.playbackQueue[self.nextIndex];
}

- (void)queueNextItem {
    if (self.nextItem) {
		[self.audioPlayer queueDataSource:[self dataSourceForItem:self.nextItem]
						  withQueueItemId:self.nextItem];
    }
}

- (STKDataSource *)dataSourceForItem:(AGMediaItem *) item {
	STKHTTPDataSource *http = [STKHTTPDataSource.alloc initWithAsyncURLProvider:^(STKHTTPDataSource *dataSource, BOOL forSeek, STKURLBlock callback) {
		[item streamURL:callback];
	}];
    
    item.dataSource = http;
	
	return [STKAutoRecoveringHTTPDataSource.alloc initWithHTTPDataSource:http];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
	
	[self.audioPlayer playDataSource:[self dataSourceForItem:self.currentItem]
					 withQueueItemID:self.currentItem];
	
    if (self.nextIndex > -1) {
        for(NSInteger i = self.nextIndex; i < self.playbackQueue.count; i++) {
            AGMediaItem *m = self.playbackQueue[i];
            [self.audioPlayer queueDataSource:[self dataSourceForItem:m]
                              withQueueItemId:m];
        }
    }
    
//    self.currentTrackHasBeenScrobbled = NO;
//    
//    [LastFm.sharedInstance sendNowPlayingTrack:self.currentItem.title
//									  byArtist:self.currentItem.artist
//									   onAlbum:self.currentItem.album
//								  withDuration:self.audioPlayer.duration
//								successHandler:nil
//								failureHandler:nil];
    
    [self redrawUI];
}

- (float)progress {
    if(self.audioPlayer.duration == 0.0) {
        return 0;
    }
    
    return self.audioPlayer.progress / self.audioPlayer.duration;
}

- (NSTimeInterval)elapsed {
    return self.audioPlayer.progress;
}

- (void)setProgress:(float)progress {
    [self.audioPlayer seekToTime: progress * self.audioPlayer.duration];
    self.uiProgressSlider.floatValue = progress;
}

- (void)forward {
    self.currentIndex = self.nextIndex;
}

- (void)backward {
    if(self.audioPlayer.progress < 10) {
        self.currentIndex--;
    }
    else {
        self.progress = 0.0;
    }
}

- (void)play {
    [self.audioPlayer resume];
    [self redrawUI];
}

- (void)pause {
    [self.audioPlayer pause];
    [self redrawUI];
}

- (void)togglePlayPause {
    if(!self.playing) {
        [self play];
    }
    else {
        [self pause];
    }
}

- (void)addItemsToQueue:(NSArray *)queue {
    [self.playbackQueue addObjectsFromArray:queue];
}

- (void)replaceQueueWithItems:(NSArray *)queue startIndex:(NSInteger)index {
    self.playbackQueue = [queue mutableCopy];
    self.currentIndex = index;
}

#pragma mark - STKAudioPlayerDelegate

- (NSString *)stringForStatus:(STKAudioPlayerState)status {
    switch (status) {
        case STKAudioPlayerStateReady:
            return @"Ready";
        case STKAudioPlayerStateRunning:
            return @"Running";
        case STKAudioPlayerStatePlaying:
            return @"Playing";
        case STKAudioPlayerStateBuffering:
            return @"Buffering";
        case STKAudioPlayerStatePaused:
            return @"Paused";
        case STKAudioPlayerStateStopped:
            return @"Stopped";
        case STKAudioPlayerStateError:
            return @"Error";
        case STKAudioPlayerStateDisposed:
            return @"Disposed";
    }
}

- (NSString *)stringForStopReason:(STKAudioPlayerStopReason)status {
    switch (status) {
        case STKAudioPlayerStopReasonNone:
            return @"None";
        case STKAudioPlayerStopReasonEof:
            return @"EOF";
        case STKAudioPlayerStopReasonUserAction:
            return @"User Action";
        case STKAudioPlayerStopReasonPendingNext:
            return @"Pending Next";
        case STKAudioPlayerStopReasonDisposed:
            return @"Disposed";
        case STKAudioPlayerStopReasonError:
            return @"Error";
    }
}

- (NSString *)stringForErrorCode:(STKAudioPlayerErrorCode)status {
    switch (status) {
        case STKAudioPlayerErrorNone:
            return @"None";
        case STKAudioPlayerErrorDataSource:
            return @"Data Source";
        case STKAudioPlayerErrorStreamParseBytesFailed:
            return @"Stream Parse Bytes Failed";
        case STKAudioPlayerErrorAudioSystemError:
            return @"Audio System Error";
        case STKAudioPlayerErrorCodecError:
            return @"Codec Error";
        case STKAudioPlayerErrorDataNotFound:
            return @"Data Not Found";
        case STKAudioPlayerErrorOther:
            return @"Other";
    }
}

- (void)updateStatusBar {
    if (self.buffering) {
        self.uiStatusLabel.hidden = NO;
        self.uiStatusLabel.stringValue = @"Buffering";
    }
    else {
        self.uiStatusLabel.hidden = YES;
    }
}

/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId {
    DDLogInfo(@"[audioPlayer] didStartPlayingQueueItemId: %@", queueItemId);
    
    NSInteger index = [self.playbackQueue indexOfObject:queueItemId];
    _currentIndex = index;
    
    [self.trackStarted execute:self.currentItem];
    
//    self.currentTrackHasBeenScrobbled = NO;
}

/// Raised when an item has finished buffering (may or may not be the currently playing item)
/// This event may be raised multiple times for the same item if seek is invoked on the player
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId {
    DDLogInfo(@"[audioPlayer] didFinishBufferingSourceWithQueueItemId: %@", queueItemId);
}

/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState {
    DDLogInfo(@"[audioPlayer] stateChanged: %@ previousState: %@", [self stringForStatus:state], [self stringForStatus:previousState]);
    [self updateStatusBar];
    
    [self.stateChanged execute:self];
}

/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer
didFinishPlayingQueueItemId:(NSObject*)queueItemId
         withReason:(STKAudioPlayerStopReason)stopReason
        andProgress:(double)progress
        andDuration:(double)duration {
    DDLogInfo(@"[audioPlayer] didFinishPlayingQueueItemId: %@ withReason: %@ andProgress: %f andDuration: %f", queueItemId, [self stringForStopReason:stopReason], progress, duration);
}

/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer
    unexpectedError:(STKAudioPlayerErrorCode)errorCode {
    DDLogInfo(@"[audioPlayer] unexpectedError: %@", [self stringForErrorCode:errorCode]);
}

/// Optionally implemented to get logging information from the STKAudioPlayer (used internally for debugging)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer
            logInfo:(NSString*)line {
    DDLogInfo(@"[audioPlayer] logInfo: %@", line);
}

/// Raised when items queued items are cleared (usually because of a call to play, setDataSource or stop)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer
didCancelQueuedItems:(NSArray*)queuedItems {
    DDLogInfo(@"[audioPlayer] didCancelQueuedItems: %@", queuedItems);
}

@end
