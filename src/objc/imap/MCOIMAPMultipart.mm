//
//  MCOIMAPMultipart.m
//  mailcore2
//
//  Created by DINH Viêt Hoà on 3/23/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import "MCOIMAPMultipart.h"

#include "MCIMAP.h"

#import "MCOUtils.h"

@implementation MCOIMAPMultipart

#define nativeType mailcore::IMAPMultipart

+ (void) load
{
    MCORegisterClass(self, &typeid(nativeType));
}

+ (NSObject *) mco_objectWithMCObject:(mailcore::Object *)object
{
    mailcore::IMAPMultipart * part = (mailcore::IMAPMultipart *) object;
    return [[[self alloc] initWithMCPart:part] autorelease];
}

MCO_SYNTHESIZE_NSCODING

MCO_OBJC_SYNTHESIZE_STRING(setPartID, partID)

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [self initWithMCPart:new nativeType()]) {
        [self updateWithDict:dict];
    }
    return self;
}

- (void)updateWithDict:(NSDictionary *)dict {
    [super updateWithDict:dict];
    if (dict[@"partID"]) {
        self.partID = dict[@"partID"];
    }
}

- (NSDictionary *)toDict {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    [ret addEntriesFromDictionary:[super toDict]];
    if (self.partID) {
        ret[@"partID"] = self.partID;
    }
    return ret;
}

@end
