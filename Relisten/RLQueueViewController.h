//
//  RLQueueViewController.h
//  Relisten
//
//  Created by Alec Gorge on 11/17/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RLQueueViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *tableView;

@end
