//
//  IGArtist.h
//  Relisten
//
//  Created by Alec Gorge on 9/3/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import "JSONModel.h"

@interface IGArtist : JSONModel

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, assign) NSInteger recording_count;

@end
