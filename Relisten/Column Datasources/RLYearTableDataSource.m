//
//  RLYearTableDataSource.m
//  Relisten
//
//  Created by Alec Gorge on 9/3/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import "RLYearTableDataSource.h"

@interface RLYearTableDataSource ()

@property (nonatomic) NSArray *shows;
@property (nonatomic) IGYear *year;

@end

@implementation RLYearTableDataSource

- (instancetype)initWithTableView:(NSTableView *)tableView {
    if (self = [super init]) {
        _tableView = tableView;
        _showSelected = [RACCommand.alloc initWithSignalBlock:^RACSignal *(IGShow *show) {
            return [RACSignal return:show];
        }];
    }
    
    return self;
}

- (void)refreshForYear:(IGYear *)year {
    self.year = year;
    
    [IGAPIClient.sharedInstance year:year.year
                             success:^(IGYear *completeYear) {
                                 self.shows = completeYear.shows;
                                 [self.tableView reloadData];
                             }
                           forArtist:year.artist];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [[notification object] selectedRow];
    
    if(row < 0) {
        return;
    }
    
    IGShow *show = self.shows[row];
    
    DDLogVerbose(@"show selected: %@", show);
    
    [self.showSelected execute:show];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.shows.count;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    NSTextField *label = nil;
    
    label = [tableView makeViewWithIdentifier:@"show"
                                        owner:self];
    
    return label;
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row {
    IGShow *show = self.shows[row];
    
    return show.displayDate;
}

@end