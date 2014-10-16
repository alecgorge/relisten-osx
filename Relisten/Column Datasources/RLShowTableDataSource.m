//
//  RLShowTableDataSource.m
//  Relisten
//
//  Created by Alec Gorge on 9/3/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import "RLShowTableDataSource.h"

#import "IGDurationHelper.h"
#import "RLPlaybackManager.h"
#import "IGMediaItem.h"

@interface RLShowTableDataSource ()

@property (nonatomic) NSTableCellView *keyValueRowView;

@property (nonatomic) IGShow *slimShow;
@property (nonatomic) NSArray *recordings;
@property (nonatomic) NSInteger selectedRecordingIndex;
@property (nonatomic, readonly) IGShow *selectedRecording;

@end

@implementation RLShowTableDataSource

- (instancetype)initWithTableView:(NSTableView *)tableView {
    if (self = [super init]) {
        _tableView = tableView;
        _trackSelected = [RACCommand.alloc initWithSignalBlock:^RACSignal *(IGTrack *track) {
            return [RACSignal return:track];
        }];
        
        [_tableView setTarget:self];
        [_tableView setDoubleAction:@selector(doubleClickRow:)];
        
        self.keyValueRowView = [tableView makeViewWithIdentifier:@"keyValue"
                                                           owner:self];
    }
    
    return self;
}

- (void)setSourceManager:(RLSourceDropdownManager *)sourceManager {
	_sourceManager = sourceManager;
	
	[self.sourceManager.selectedSourceChanged.executionSignals subscribeNext:^(RACSignal *s) {
		[s subscribeNext:^(IGShow *recording) {
			self.recordings = @[recording];
			[self.tableView reloadData];
		}];
	}];
}

- (IGShow *)selectedRecording {
    return self.recordings[self.selectedRecordingIndex];
}

- (IGTrack *)trackForRow:(NSInteger)row {
    IGShow *recording = self.selectedRecording;
    IGTrack *track = recording.tracks[row];

    return track;
}

- (void)doubleClickRow:(NSTableView *)tableView {
    NSInteger row = tableView.selectedRow;
    
    IGTrack *track = [self trackForRow:row];
    
    DDLogVerbose(@"track double clicked: %@", track);
    
    NSArray *mediaItems = [self.selectedRecording.tracks map:^id(IGTrack *object) {
        IGMediaItem *i = [IGMediaItem.alloc initWithTrack:object
                                                  andShow:self.selectedRecording];
        
        return i;
    }];
    
    RLPlaybackManager *rlpm = [RLPlaybackManager sharedManagerForView:nil];
    [rlpm replaceQueueWithItems:mediaItems
                     startIndex:row];
    
    [self.trackSelected execute:track];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [[notification object] selectedRow];

    IGTrack *track = [self trackForRow:row];
    
    DDLogVerbose(@"track selected: %@", track);
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if(!self.recordings) {
        return 0;
    }
    
    return self.selectedRecording.tracks.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 30.0f;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    NSView *v = [tableView makeViewWithIdentifier:@"track"
                                        owner:self];
        
	NSTextField *title = [v viewWithTag:1];
	NSTextField *duration = [v viewWithTag:2];
	NSTextField *pos = [v viewWithTag:3];
	
	IGTrack *track = [self trackForRow:row];
	
	pos.stringValue = @(track.track).stringValue;
	title.stringValue = track.title;
	duration.stringValue = [IGDurationHelper formattedTimeWithInterval:track.length];
	
    
    return v;
}

@end
