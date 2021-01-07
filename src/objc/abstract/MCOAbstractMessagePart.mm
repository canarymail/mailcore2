//
//  MCOAbstractMessagePart.m
//  mailcore2
//
//  Created by DINH Viêt Hoà on 3/10/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import "MCOAbstractMessagePart.h"

#import "NSObject+MCO.h"
#import "MCOMessageHeader.h"

#include "MCAbstractMessagePart.h"
#include "MCMessageHeader.h"

@implementation MCOAbstractMessagePart

#define nativeType mailcore::AbstractMessagePart

MCO_OBJC_SYNTHESIZE(MessageHeader, setHeader, header)
MCO_OBJC_SYNTHESIZE(AbstractMessagePart, setMainPart, mainPart)

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [self initWithMCPart:new nativeType()]) {
        [self updateWithDict:dict];
    }
    return self;
}

- (void)updateWithDict:(NSDictionary *)dict {
    [super updateWithDict:dict];
    if (dict[@"mainPart"]) {
        self.mainPart = [[MCOAbstractPart alloc] initWithDict:dict[@"mainPart"]];
    }
    if (dict[@"header"]) {
        self.header = [[MCOMessageHeader alloc] initWithDict:dict[@"header"]];
    }
}

- (NSDictionary *)toDict {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    
    if (self.mainPart) {
        ret[@"mainPart"] = [self.mainPart toDict];
    }
    if (self.header) {
        ret[@"header"] = [self.header toDict];
    }
    
    return ret;
}

@end
