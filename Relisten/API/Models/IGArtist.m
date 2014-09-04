//
//  IGArtist.m
//  Relisten
//
//  Created by Alec Gorge on 9/3/14.
//  Copyright (c) 2014 Relisten Team. All rights reserved.
//

#import "IGArtist.h"

@implementation IGArtist

+ (JSONKeyMapper*)keyMapper {
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

@end
