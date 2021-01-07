//
//  MCOMessageParser.m
//  mailcore2
//
//  Created by DINH Viêt Hoà on 3/22/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import "MCOMessageParser.h"

#include "MCRFC822.h"
#include "MCRenderer.h"
#include "MCAbstractPart.h"

#import "MCOHTMLRendererDelegate.h"
#import "NSObject+MCO.h"
#import "MCOUtils.h"
#import "MCOAbstractMessageRendererCallback.h"

@implementation MCOMessageParser

#define nativeType mailcore::MessageParser

+ (void) load
{
    MCORegisterClass(self, &typeid(nativeType));
}

+ (id) mco_objectWithMCObject:(mailcore::Object *)object
{
    mailcore::MessageParser * msg = (mailcore::MessageParser *) object;
    return [[[self alloc] initWithMCMessage:msg] autorelease];
}

+ (MCOMessageParser *) messageParserWithData:(NSData *)data
{
    return [[[MCOMessageParser alloc] initWithData:data] autorelease];
}

- (instancetype) initWithData:(NSData *)data
{
    mailcore::MessageParser * message = new mailcore::MessageParser((CFDataRef) data);
    self = [super initWithMCMessage:message];
    MC_SAFE_RELEASE(message);
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (MCOAbstractPart *) mainPart
{
    return MCO_OBJC_BRIDGE_GET(mainPart);
}

- (void) setMainPart:(MCOAbstractPart *) mainPart {
    MCO_OBJC_BRIDGE_SET(setMainPart, mailcore::AbstractPart, mainPart);
}

- (NSData *) data
{
    return MCO_OBJC_BRIDGE_GET(data);
}

- (NSString *) htmlRenderingWithDelegate:(id <MCOHTMLRendererDelegate>)delegate
{
    MCOAbstractMessageRendererCallback * htmlRenderCallback = new MCOAbstractMessageRendererCallback(self, delegate, NULL);
    NSString * result = MCO_TO_OBJC(MCO_NATIVE_INSTANCE->htmlRendering(htmlRenderCallback));
    htmlRenderCallback->release();
    
    return result;
}

- (NSString *) htmlBodyRendering
{
    return MCO_OBJC_BRIDGE_GET(htmlBodyRendering);
}

- (NSString *) plainTextRendering
{
    return MCO_OBJC_BRIDGE_GET(plainTextRendering);
}

- (NSString *) plainTextBodyRendering
{
    return [self plainTextBodyRenderingAndStripWhitespace:YES];
}

- (NSString *) plainTextBodyRenderingAndStripWhitespace:(BOOL)stripWhitespace
{
    return MCO_TO_OBJC(MCO_NATIVE_INSTANCE->plainTextBodyRendering(stripWhitespace));
}

- (uint64_t)gmailMessageID {
    return MCO_NATIVE_INSTANCE->gmailMessageID();
}

- (void)setGmailMessageID:(uint64_t)gmailMessageID {
    MCO_NATIVE_INSTANCE->setGmailMessageID(gmailMessageID);
}

- (uint64_t)gmailThreadID {
    return MCO_NATIVE_INSTANCE->gmailThreadID();
}

- (void)setGmailThreadID:(uint64_t)gmailThreadID {
    MCO_NATIVE_INSTANCE->setGmailThreadID(gmailThreadID);
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [self initWithMCMessage:new nativeType()]) {
        [self updateWithDict:dict];
    }
    return self;
}

- (void)updateWithDict:(NSDictionary *)dict {
    [super updateWithDict:dict];
    if (dict[@"mainPart"]) {
        [self setMainPart:(id)[MCOSerializableUtils objectFromDict:dict[@"mainPart"]]];
    }
}

- (NSDictionary *)toDict {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    [ret addEntriesFromDictionary:[super toDict]];
    if (self.mainPart) {
        ret[@"mainPart"] = [MCOSerializableUtils dictFromObject:(id)self.mainPart];
    }
    return ret;
}

@end
