//
//  RLYearsTableDataSource.h
//  Relisten
//
//  Created by Alec Gorge on 9/3/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IGAPIClient.h"

@interface RLYearsTableDataSource : NSObject<NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, readonly) NSTableView *tableView;
@property (nonatomic, readonly) RACCommand *yearSelected;

- (instancetype)initWithTableView:(NSTableView *)tableView;

- (void)refreshForArtist:(IGArtist *)artist;

@end
