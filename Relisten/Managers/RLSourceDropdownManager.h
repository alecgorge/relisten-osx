//
//  RLSourceDropdownManager.h
//  Relisten
//
//  Created by Alec Gorge on 10/16/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IGShow.h"

@interface RLSourceDropdownManager : NSObject

@property (nonatomic) NSPopUpButton *popUpButton;
@property (nonatomic) RACCommand *selectedSourceChanged;

- (instancetype)initWithPopUpButton:(NSPopUpButton *)popCell;
- (void)refreshForShow:(IGShow *)show;

@end
