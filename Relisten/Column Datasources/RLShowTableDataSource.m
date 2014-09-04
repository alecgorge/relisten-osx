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

typedef NS_ENUM(NSInteger, RLShowRows) {
    RLShowTaperRow = 0,
    RLShowTransfererRow,
    RLShowSourceRow,
    RLShowLineageRow,
    RLShowRatingRow,
    RLShowVenueRow,
    RLShowRowCount,
};

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

- (void)refreshForShow:(IGShow *)show {
    [IGAPIClient.sharedInstance showsOn:show.displayDate
                                success:^(NSArray *recordings) {
                                    self.recordings = recordings;
                                    self.selectedRecordingIndex = 0;
                                    
                                    [self.tableView reloadData];
                                }
                              forArtist:show.artist];
}

- (IGShow *)selectedRecording {
    return self.recordings[self.selectedRecordingIndex];
}

- (IGTrack *)trackForRow:(NSInteger)row {
    if(row < RLShowRowCount) {
        return nil;
    }
    
    IGShow *recording = self.selectedRecording;
    IGTrack *track = recording.tracks[row - RLShowRowCount];

    return track;
}

- (void)doubleClickRow:(NSTableView *)tableView {
    NSInteger row = tableView.selectedRow;
    
    if(row < RLShowRowCount) {
        return;
    }
    
    IGTrack *track = [self trackForRow:row];
    
    DDLogVerbose(@"track double clicked: %@", track);
    
    NSArray *mediaItems = [self.selectedRecording.tracks map:^id(IGTrack *object) {
        IGMediaItem *i = [IGMediaItem.alloc initWithTrack:object
                                                  andShow:self.selectedRecording];
        
        return i;
    }];
    
    RLPlaybackManager *rlpm = [RLPlaybackManager sharedManagerForView:nil];
    [rlpm replaceQueueWithItems:mediaItems
                     startIndex:row - RLShowRowCount];
    
    [self.trackSelected execute:track];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [[notification object] selectedRow];

    if(row < RLShowRowCount) {
        return;
    }
    
    IGTrack *track = [self trackForRow:row];
    
    DDLogVerbose(@"track selected: %@", track);
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if(!self.recordings) {
        return 0;
    }
    
    return self.selectedRecording.tracks.count + RLShowRowCount;
}

- (NSString *)metadataFromRow:(NSInteger) row {
    if(row == RLShowTaperRow) {
        return self.selectedRecording.source;
    }
    else if(row == RLShowTransfererRow) {
        return self.selectedRecording.transferer;
    }
    else if(row == RLShowSourceRow) {
        return self.selectedRecording.source;
    }
    else if(row == RLShowLineageRow) {
        return self.selectedRecording.lineage;
    }
    else if(row == RLShowRatingRow) {
        if(self.selectedRecording.reviewsCount > 0) {
            return [NSString stringWithFormat:@"%.2f / %@ reviews", self.selectedRecording.averageRating, @(self.selectedRecording.reviewsCount)];
        }
    }
    else if(row == RLShowVenueRow) {
        return [NSString stringWithFormat:@"%@, %@", self.selectedRecording.venue.name, self.selectedRecording.venue.city];
    }
    
    return @"";
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if(row < RLShowRowCount) {
        self.keyValueRowView.frame = CGRectMake(0, 0, tableView.bounds.size.width, CGFLOAT_MAX);
        NSString *m = [self metadataFromRow:row];
        
        if (!m || m.length == 0) {
            return 0.01f;
        }
        
        NSTextField *val = [self.keyValueRowView viewWithTag:2];
        
        CGRect r = [m boundingRectWithSize:NSMakeSize(val.bounds.size.width, CGFLOAT_MAX)
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{ NSFontAttributeName : val.font }];
        
        return r.size.height + 20.0f;
    }
    
    return 30.0f;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    NSView *v = nil;
    
    if(row < RLShowRowCount) {
        v = [tableView makeViewWithIdentifier:@"keyValue"
                                        owner:self];
        
        NSTextField *key = [v viewWithTag:1];
        NSTextField *val = [v viewWithTag:2];

        if(row == RLShowTaperRow) {
            key.stringValue = @"Show";
        }
        else if(row == RLShowTransfererRow) {
            key.stringValue = @"Transferer";
        }
        else if(row == RLShowSourceRow) {
            key.stringValue = @"Source";
        }
        else if(row == RLShowLineageRow) {
            key.stringValue = @"Lineage";
        }
        else if(row == RLShowRatingRow) {
            key.stringValue = @"Rating";
        }
        else if(row == RLShowVenueRow) {
            key.stringValue = @"Venue";
        }
        
        val.stringValue = [self metadataFromRow:row];
    }
    else {
        v = [tableView makeViewWithIdentifier:@"track"
                                        owner:self];
        
        NSTextField *title = [v viewWithTag:1];
        NSTextField *duration = [v viewWithTag:2];
        NSTextField *pos = [v viewWithTag:3];
        
        IGTrack *track = [self trackForRow:row];
        
        pos.stringValue = @(track.track).stringValue;
        title.stringValue = track.title;
        duration.stringValue = [IGDurationHelper formattedTimeWithInterval:track.length];
    }
    
    return v;
}

@end
