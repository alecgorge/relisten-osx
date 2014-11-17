//
//  RLQueueRowView.h
//  Relisten
//
//  Created by Alec Gorge on 11/17/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RLQueueRowView : NSTableRowView

@property (weak) IBOutlet NSTextField *uiTitleTextField;
@property (weak) IBOutlet NSTextField *uiSubtitleTextField;

@end
