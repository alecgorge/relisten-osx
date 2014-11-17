//
//  RLQueueViewController.m
//  Relisten
//
//  Created by Alec Gorge on 11/17/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import "RLQueueViewController.h"

#import "RLPlaybackManager.h"
#import "RLQueueRowView.h"

@interface RLQueueViewController ()

@property (nonatomic) RLPlaybackManager *playback;

@end

@implementation RLQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.playback = [RLPlaybackManager sharedManagerForView:nil];
    
    [self.tableView registerForDraggedTypes:@[@"public.text"]];
    self.tableView.target = self;
    self.tableView.doubleAction = @selector(uiPlayTrack:);
}

- (void)uiPlayTrack:(id) sender {
    NSInteger row = self.tableView.selectedRow;
    
    self.playback.currentIndex = row;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.playback.playbackQueue.count;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    AGMediaItem *i = self.playback.playbackQueue[row];
    
    RLQueueRowView *v = [tableView makeViewWithIdentifier:@"q"
                                                    owner:self];
    
    if(!v) {
        NSArray *top;
        [NSBundle.mainBundle loadNibNamed:@"RLQueueRowView"
                                    owner:self
                          topLevelObjects:&top];
        
        for (id obj in top) {
            if([obj isKindOfClass:RLQueueRowView.class]) {
                v = obj;
                break;
            }
        }
        
        v.identifier = @"q";
    }
    
    v.uiTitleTextField.stringValue = i.displaySubText;
    v.uiSubtitleTextField.stringValue = i.displayText;
    
    return v;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 55.0f;
}

- (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row {
    NSPasteboardItem *pboardItem = NSPasteboardItem.alloc.init;
    
    [pboardItem setString:[NSString stringWithFormat:@"%d", (int)row]
                  forType:@"public.text"];
    
    return pboardItem;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView
                validateDrop:(id < NSDraggingInfo >)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)operation {
    return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)tableView
       acceptDrop:(id<NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)dropOperation {
    NSPasteboard *p = [info draggingPasteboard];
    NSInteger oldRow  = [[p stringForType:@"public.text"] integerValue];
    
    AGMediaItem *i = self.playback.playbackQueue[oldRow];
    [self.playback.playbackQueue removeObjectAtIndex:oldRow];
    [self.playback.playbackQueue insertObject:i
                                      atIndex:row];
    
    return YES;
}

@end
