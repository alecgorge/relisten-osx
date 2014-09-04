//
//  RLYearsTableDataSource.m
//  Relisten
//
//  Created by Alec Gorge on 9/3/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import "RLYearsTableDataSource.h"

@interface RLYearsTableDataSource ()

@property (nonatomic) NSArray *years;

@end

@implementation RLYearsTableDataSource

- (instancetype)initWithTableView:(NSTableView *)tableView {
    if (self = [super init]) {
        _tableView = tableView;
        _yearSelected = [RACCommand.alloc initWithSignalBlock:^RACSignal *(IGYear *year) {
            return [RACSignal return:year];
        }];
    }
    
    return self;
}

- (void)refreshForArtist:(IGArtist *)artist {
    [IGAPIClient.sharedInstance years:^(NSArray *years) {
        self.years = years;
        [self.tableView reloadData];
    }
                            forArtist:artist];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [[notification object] selectedRow];
    if(row < 0) {
        return;
    }
    
    IGYear *year = self.years[row];
    
    DDLogVerbose(@"year selected: %@", year);
    
    [self.yearSelected execute:year];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.years.count;
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row {
    IGYear *year = self.years[row];
    
    if([tableColumn.identifier isEqualToString:@"year"]) {
        return @(year.year).stringValue;
    }
    else {
        return @(year.recordingCount).stringValue;
    }
    
    return @"";
}

@end
