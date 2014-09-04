//
//  RLArtistDropdownManager.m
//  Relisten
//
//  Created by Alec Gorge on 9/3/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import "RLArtistDropdownManager.h"

#import "IGAPIClient.h"

@interface RLArtistDropdownManager ()

@property (nonatomic) NSArray *artists;

@end

@implementation RLArtistDropdownManager

- (instancetype)initWithPopUpButton:(NSPopUpButton *)popCell {
    if (self = [super init]) {
        self.popUpButton = popCell;
    }
    
    return self;
}

- (void)setPopUpButton:(NSPopUpButton *)popUpButton {
    _popUpButton = popUpButton;
    
    _popUpButton.rac_command = [RACCommand.alloc initWithSignalBlock:^RACSignal *(id input) {
        IGArtist *artist = self.artists[_popUpButton.indexOfSelectedItem];
        
        DDLogVerbose(@"changed artist: %@", artist);
        
        return [RACSignal return:artist];
    }];
    
    self.artistChanged = _popUpButton.rac_command;
}

- (void)refresh {
    [IGAPIClient.sharedInstance artists:^(NSArray *artists) {
        self.artists = [artists sortedArrayUsingComparator:^NSComparisonResult(IGArtist *obj1, IGArtist *obj2) {
            return [obj1.name localizedCaseInsensitiveCompare:obj2.name];
        }];
        
        [self.popUpButton removeAllItems];
        [self.popUpButton addItemsWithTitles:[self.artists map:^id(IGArtist *object) {
            return object.name;
        }]];
        
        ((NSPopUpButtonCell*)self.popUpButton.cell).enabled = YES;

        NSString *slug = [NSUserDefaults.standardUserDefaults objectForKey:@"last_selected_artist_slug"];
        if(slug) {
            NSInteger index = [[self.artists valueForKeyPath:@"slug"] indexOfObject:slug];
            
            if(index >= 0 && index < self.artists.count) {
                [self.popUpButton selectItemAtIndex: index];
                [self.popUpButton.rac_command execute:self];
            }
        }
    }];
}

@end
