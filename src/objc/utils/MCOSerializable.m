//
//  MCOSerializable.m
//  mailcore2
//
//  Created by Dev on 07/01/21.
//  Copyright © 2021 MailCore. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCOSerializable.h"

@implementation MCOSerializableUtils

+ (id<MCOSerializable>)objectFromDict:(NSDictionary *)dict {
    NSString *classStr = dict[@"class"];
    Class<MCOSerializable> klass = NSClassFromString(classStr);
    id item = [[klass alloc] initWithDict:dict];
    return item;
}

- (NSDictionary *)dictFromObject:(id<MCOSerializable>)item {
    NSMutableDictionary *itemDict = [[NSMutableDictionary alloc] init];
    itemDict[@"class"] = NSStringFromClass(item.class);
    [itemDict addEntriesFromDictionary:item.toDict];
    return itemDict;
}

@end

@implementation NSArray (MCOSerializable)

+ (instancetype)fromSerialized:(NSArray *)items {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (NSDictionary *itemDict in items) {
        [ret addObject:[MCOSerializableUtils objectFromDict:itemDict]];
    }
    return ret;
}

- (NSArray *)toSerialized {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (id<MCOSerializable> item in self) {
        [ret addObject:[MCOSerializableUtils dictFromObject:item]];
    }
    return ret;
}

@end
