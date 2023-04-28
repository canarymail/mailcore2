//
//  MCOIMAPMessage.m
//  mailcore2
//
//  Created by DINH Viêt Hoà on 3/23/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import "MCOIMAPMessage.h"

#include "MCIMAP.h"

#import "MCOUtils.h"
#import "MCOAbstractMessageRendererCallback.h"
#import "MCOHTMLRendererDelegate.h"
#import "MCOHTMLRendererIMAPDelegate.h"

@implementation MCOIMAPMessage

#define nativeType mailcore::IMAPMessage

+ (void) load
{
    MCORegisterClass(self, &typeid(nativeType));
}

- (instancetype) init
{
    mailcore::IMAPMessage * msg = new mailcore::IMAPMessage();
    self = [self initWithMCMessage:msg];
    msg->release();
    return self;
}

+ (NSObject *) mco_objectWithMCObject:(mailcore::Object *)object
{
    mailcore::IMAPMessage * msg = (mailcore::IMAPMessage *) object;
    return [[[self alloc] initWithMCMessage:msg] autorelease];
}

MCO_SYNTHESIZE_NSCODING

MCO_OBJC_SYNTHESIZE_SCALAR(uint32_t, uint32_t, setUid, uid)
MCO_OBJC_SYNTHESIZE_SCALAR(uint32_t, uint32_t, setSequenceNumber, sequenceNumber)
MCO_OBJC_SYNTHESIZE_SCALAR(uint32_t, uint32_t, setSize, size)
MCO_OBJC_SYNTHESIZE_SCALAR(MCOMessageFlag, mailcore::MessageFlag, setFlags, flags)
MCO_OBJC_SYNTHESIZE_SCALAR(MCOMessageFlag, mailcore::MessageFlag, setOriginalFlags, originalFlags)
MCO_OBJC_SYNTHESIZE_ARRAY(setCustomFlags, customFlags)
MCO_OBJC_SYNTHESIZE_SCALAR(uint64_t, uint64_t, setModSeqValue, modSeqValue)
MCO_OBJC_SYNTHESIZE(AbstractPart, setMainPart, mainPart)
MCO_OBJC_SYNTHESIZE_ARRAY(setGmailLabels, gmailLabels)
MCO_OBJC_SYNTHESIZE_SCALAR(uint64_t, uint64_t, setGmailThreadID, gmailThreadID)
MCO_OBJC_SYNTHESIZE_SCALAR(uint64_t, uint64_t, setGmailMessageID, gmailMessageID)

- (NSData *)rfc822Data {
    return MCO_TO_OBJC(MCO_NATIVE_INSTANCE->rfc822Data());
}

- (void)setRfc822Data:(NSData *)rfc822Data {
    return MCO_NATIVE_INSTANCE->setRFCData([rfc822Data mco_mcData]);
}

- (MCOAbstractPart *) partForPartID:(NSString *)partID
{
    return MCO_TO_OBJC(MCO_NATIVE_INSTANCE->partForPartID([partID mco_mcString]));
}

- (NSString *) htmlRenderingWithFolder:(NSString *)folder
                              delegate:(id <MCOHTMLRendererIMAPDelegate>)delegate
{
    MCOAbstractMessageRendererCallback * htmlRenderCallback = new MCOAbstractMessageRendererCallback(self, delegate, delegate);
    NSString * result = MCO_TO_OBJC(MCO_NATIVE_INSTANCE->htmlRendering([folder mco_mcString], htmlRenderCallback, htmlRenderCallback));
    htmlRenderCallback->release();
    
    return result;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [self initWithMCMessage:new nativeType()]) {
        [self updateWithDict:dict];
    }
    return self;
}

- (void)updateWithDict:(NSDictionary *)dict {
    [super updateWithDict:dict];
    if (dict[@"modSeqValue"]) {
        self.modSeqValue = [dict[@"modSeqValue"] unsignedLongLongValue];
    }
    if (dict[@"uid"]) {
        self.uid = [dict[@"uid"] unsignedIntValue];
    }
    if (dict[@"size"]) {
        self.size = [dict[@"size"] unsignedIntValue];
    }
    if (dict[@"flags"]) {
        self.flags = [dict[@"flags"] unsignedIntValue];
    }
    if (dict[@"originalFlags"]) {
        self.originalFlags = [dict[@"originalFlags"] unsignedIntValue];
    }
    if (dict[@"customFlags"]) {
        self.customFlags = dict[@"customFlags"];
    }
    if (dict[@"mainPart"]) {
        self.mainPart = (id)[MCOSerializableUtils objectFromDict:dict[@"mainPart"]];
    }
    if (dict[@"gmailLabels"]) {
        self.gmailLabels = dict[@"gmailLabels"];
    }
    if (dict[@"gmailMessageID"]) {
        self.gmailMessageID = [dict[@"gmailMessageID"] unsignedLongLongValue];
    }
    if (dict[@"gmailThreadID"]) {
        self.gmailThreadID = [dict[@"gmailThreadID"] unsignedLongLongValue];
    }
}

- (NSDictionary *)toDict {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    [ret addEntriesFromDictionary:[super toDict]];
    ret[@"modSeqValue"] = @(self.modSeqValue);
    ret[@"uid"] = @(self.uid);
    ret[@"size"] = @(self.size);
    ret[@"flags"] = @(self.flags);
    ret[@"originalFlags"] = @(self.originalFlags);
    if (self.customFlags.count > 0) {
        ret[@"customFlags"] = self.customFlags;
    }
    if (self.mainPart) {
        ret[@"mainPart"] = [MCOSerializableUtils dictFromObject:(id)self.mainPart];
    }
    if (self.gmailLabels) {
        ret[@"gmailLabels"] = self.gmailLabels;
    }
    if (self.gmailMessageID) {
        ret[@"gmailMessageID"] = @(self.gmailMessageID);
    }
    if (self.gmailThreadID) {
        ret[@"gmailThreadID"] = @(self.gmailThreadID);
    }
    return ret;
}

- (instancetype) initWithSerializableDictionary:(NSDictionary *)dict {
    mailcore::HashMap * serializable = MCO_FROM_OBJC(mailcore::HashMap, dict);
    self = MCO_TO_OBJC(mailcore::Object::objectWithSerializable(serializable));
    [self retain];
    return self;
}

- (NSDictionary *) serializableDictionary {
    return MCO_TO_OBJC(MCO_FROM_OBJC(nativeType, self)->serializable());
}

@end
