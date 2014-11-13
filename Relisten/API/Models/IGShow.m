//
//  IGShow.m
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGShow.h"

@implementation IGShow

+ (JSONKeyMapper*)keyMapper {
    JSONKeyMapper *k = [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
    
    return [JSONKeyMapper.alloc initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqualToString:@"description"]) {
            return @"igDescription";
        }
        return k.JSONToModelKeyBlock(keyName);
    }
                                        modelToJSONBlock:^NSString *(NSString *keyName) {
                                            if ([keyName isEqualToString:@"igDescription"]) {
                                                return @"description";
                                            }
                                            return k.modelToJSONKeyBlock(keyName);
                                        }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if([propertyName isEqualToString:@"recordingCount"]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)htmlSummary {
    NSString *format = [NSString stringWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"source"
                                                                                        ofType:@"html"]
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
    
    return [NSString stringWithFormat:format, self.taper, self.transferer, self.source, self.lineage, self.averageRating, (int)self.reviewsCount, [self.igDescription stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"], [[self.reviews map:^id(NSDictionary *review) {
        return [NSString stringWithFormat:@"<li><h4>%@</h4><h5>by %@ on %@</h5><p>%@</p>", review[@"reviewtitle"], review[@"reviewer"], review[@"reviewdate"], [[review[@"reviewbody"] stringByReplacingOccurrencesOfString:@"\\n"
 withString:@"<br/>"] stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""]];
    }] componentsJoinedByString:@"\n"]];
}

@end
