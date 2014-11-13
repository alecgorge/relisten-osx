//
//  RLSourceDropdownManager.m
//  Relisten
//
//  Created by Alec Gorge on 10/16/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import "RLSourceDropdownManager.h"

#import "IGDurationHelper.h"
#import "IGAPIClient.h"

@interface RLSourceDropdownManager ()

@property (nonatomic) NSInteger selectedSourceIndex;
@property (nonatomic) IGShow *show;
@property (nonatomic) NSArray *sources;

@end

@implementation RLSourceDropdownManager

- (instancetype)initWithPopUpButton:(NSPopUpButton *)popCell {
	if (self = [super init]) {
		self.popUpButton = popCell;
		((NSPopUpButtonCell*)self.popUpButton.cell).enabled = NO;
	}
	
	return self;
}

- (void)setPopUpButton:(NSPopUpButton *)popUpButton {
	_popUpButton = popUpButton;
	
	_popUpButton.rac_command = [RACCommand.alloc initWithSignalBlock:^RACSignal *(id input) {
		IGShow *show = self.sources[_popUpButton.indexOfSelectedItem];
        
        self.currentSource = show;
		
		DDLogVerbose(@"changed source: %@", show);
		
		return [RACSignal return:show];
	}];
	
	self.selectedSourceChanged = _popUpButton.rac_command;
}

- (void)refreshForShow:(IGShow *)show {
	if(show == nil) {
		((NSPopUpButtonCell*)self.popUpButton.cell).enabled = NO;
	}
	
	((NSPopUpButtonCell*)self.popUpButton.cell).enabled = YES;

	self.show = show;
	
	[IGAPIClient.sharedInstance showsOn:show.displayDate
								success:^(NSArray *recordings) {
									self.sources = recordings;
									self.selectedSourceIndex = 0;
									[self.popUpButton removeAllItems];
									[self.popUpButton addItemsWithTitles:[self.sources map:^id(IGShow *recording) {
										return [NSString stringWithFormat:@"%@ — %@", [IGDurationHelper formattedTimeWithInterval:recording.duration], recording.source];
									}]];
									
									[self.popUpButton selectItemAtIndex:0];
									[self.popUpButton.rac_command execute:self];
								}
							  forArtist:show.artist];
}

@end
