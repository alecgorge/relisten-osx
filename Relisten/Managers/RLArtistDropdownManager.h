//
//  RLArtistDropdownManager.h
//  Relisten
//
//  Created by Alec Gorge on 9/3/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLArtistDropdownManager : NSObject

@property (nonatomic) NSPopUpButton *popUpButton;
@property (nonatomic) RACCommand *artistChanged;

- (instancetype)initWithPopUpButton:(NSPopUpButton *)popCell;
- (void)refresh;

@end
