//
//  MCOAbstractMultipart.m
//  mailcore2
//
//  Created by DINH Viêt Hoà on 3/10/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import "MCOAbstractMultipart.h"

#include "MCAbstractMultipart.h"

#import "NSObject+MCO.h"

@implementation MCOAbstractMultipart

#define nativeType mailcore::AbstractMultipart

MCO_OBJC_SYNTHESIZE_ARRAY(setParts, parts)

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [self initWithMCPart:new nativeType()]) {
        [self updateWithDict:dict];
    }
    return self;
}

- (void)updateWithDict:(NSDictionary *)dict {
    [super updateWithDict:dict];
    // Older caches drop "parts" for empty multiparts; keep an empty array rather than NULL.
    self.parts = dict[@"parts"] ? [NSArray fromSerialized:dict[@"parts"]] : @[];
}

- (NSDictionary *)toDict {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    [ret addEntriesFromDictionary:[super toDict]];

    NSArray *parts = self.parts.toSerialized;
    if (parts != nil) {
        ret[@"parts"] = parts;
    }
    
    return ret;
}

@end
