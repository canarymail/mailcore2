//
//  MCOAbstractPart.m
//  mailcore2
//
//  Created by DINH Viêt Hoà on 3/10/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import "MCOAbstractPart.h"

#include "MCAbstractPart.h"
#include "MCAbstractMessage.h"

#import "NSString+MCO.h"
#import "NSObject+MCO.h"
#import "NSData+MCO.h"

@implementation MCOAbstractPart {
    mailcore::AbstractPart * _part;
}

#define nativeType mailcore::AbstractPart

- (mailcore::Object *) mco_mcObject
{
    return _part;
}

- (instancetype) init
{
    self = [self initWithMCPart:NULL];
    MCAssert(0);
    return nil;
}

- (instancetype) initWithMCPart:(mailcore::AbstractPart *)part
{
    self = [super init];
    
    MC_SAFE_RETAIN(part);
    _part = part;
    
    return self;
}

- (void) dealloc
{
    MC_SAFE_RELEASE(_part);
    [super dealloc];
}

- (id) copyWithZone:(NSZone *)zone
{
    nativeType * nativeObject = (nativeType *) [self mco_mcObject]->copy();
    id result = [[self class] mco_objectWithMCObject:nativeObject];
    MC_SAFE_RELEASE(nativeObject);
    return [result retain];
}

- (NSString *) description
{
    return MCO_OBJC_BRIDGE_GET(description);
}

MCO_OBJC_SYNTHESIZE_SCALAR(MCOPartType, mailcore::PartType, setPartType, partType)

MCO_OBJC_SYNTHESIZE_STRING(setFilename, filename)
MCO_OBJC_SYNTHESIZE_STRING(setMimeType, mimeType)
MCO_OBJC_SYNTHESIZE_STRING(setCharset, charset)
MCO_OBJC_SYNTHESIZE_STRING(setUniqueID, uniqueID)
MCO_OBJC_SYNTHESIZE_STRING(setContentID, contentID)
MCO_OBJC_SYNTHESIZE_STRING(setContentLocation, contentLocation)
MCO_OBJC_SYNTHESIZE_STRING(setContentDescription, contentDescription)
MCO_OBJC_SYNTHESIZE_BOOL(setInlineAttachment, isInlineAttachment)
MCO_OBJC_SYNTHESIZE_BOOL(setAttachment, isAttachment)

- (MCOAbstractPart *) partForContentID:(NSString *)contentID
{
    return MCO_TO_OBJC(MCO_NATIVE_INSTANCE->partForContentID([contentID mco_mcString]));
}

- (MCOAbstractPart *) partForUniqueID:(NSString *)uniqueID
{
    return MCO_TO_OBJC(MCO_NATIVE_INSTANCE->partForUniqueID([uniqueID mco_mcString]));
}

- (NSString *) decodedStringForData:(NSData *)data
{
    return [NSString mco_stringWithMCString:MCO_NATIVE_INSTANCE->decodedStringForData([data mco_mcData])];
}

- (void) setContentTypeParameterValue:(NSString *)value forName:(NSString *)name
{
    MCO_NATIVE_INSTANCE->setContentTypeParameter(MCO_FROM_OBJC(mailcore::String, name), MCO_FROM_OBJC(mailcore::String, value));
}

- (NSString *) contentTypeParameterValueForName:(NSString *)name
{
    return MCO_TO_OBJC(MCO_NATIVE_INSTANCE->contentTypeParameterValueForName((MCO_FROM_OBJC(mailcore::String, name))));
}
- (void) removeContentTypeParameterForName:(NSString *)name
{
    MCO_NATIVE_INSTANCE->removeContentTypeParameter(MCO_FROM_OBJC(mailcore::String, name));
}

- (NSArray * /* NSString */) allContentTypeParametersNames
{
    return MCO_TO_OBJC(MCO_NATIVE_INSTANCE->allContentTypeParametersNames());
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [self initWithMCPart:new nativeType()]) {
        [self updateWithDict:dict];
    }
    return self;
}

- (void)updateWithDict:(NSDictionary *)dict {
    self.uniqueID = dict[@"uniqueID"];
    self.filename = dict[@"filename"];
    self.mimeType = dict[@"mimeType"];
    self.charset = dict[@"charset"];
    self.contentID = dict[@"contentID"];
    self.contentLocation = dict[@"contentLocation"];
    self.contentDescription = dict[@"contentDescription"];
    if ([dict[@"inlineAttachment"] boolValue]) {
        self.inlineAttachment = YES;
    }
    if ([dict[@"attachment"] boolValue]) {
        self.attachment = YES;
    }
    NSString *partType = dict[@"partType"];
    if (partType) {
        if ([partType isEqual:@"single"]) {
            self.partType = MCOPartTypeSingle;
        }
        else if ([partType isEqual:@"message"]) {
            self.partType = MCOPartTypeMessage;
        }
        else if ([partType isEqual:@"multipart/mixed"]) {
            self.partType = MCOPartTypeMultipartMixed;
        }
        else if ([partType isEqual:@"multipart/related"]) {
            self.partType = MCOPartTypeMultipartRelated;
        }
        else if ([partType isEqual:@"multipart/alternative"]) {
            self.partType = MCOPartTypeMultipartAlternative;
        }
        else if ([partType isEqual:@"multipart/signed"]) {
            self.partType = MCOPartTypeMultipartSigned;
        }
    }
}

- (NSDictionary *)toDict {
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    if (self.uniqueID) {
        ret[@"uniqueID"] = self.uniqueID;
    }
    if (self.filename) {
        ret[@"filename"] = self.filename;
    }
    if (self.mimeType) {
        ret[@"mimeType"] = self.mimeType;
    }
    if (self.charset) {
        ret[@"charset"] = self.charset;
    }
    if (self.contentID) {
        ret[@"contentID"] = self.contentID;
    }
    if (self.contentLocation) {
        ret[@"contentLocation"] = self.contentLocation;
    }
    if (self.contentDescription) {
        ret[@"contentDescription"] = self.contentDescription;
    }
    if (self.inlineAttachment) {
        ret[@"inlineAttachment"] = @(1);
    }
    if (self.attachment) {
        ret[@"attachment"] = @(1);
    }
    NSString *partTypeStr;
    switch (self.partType) {
        default:
        case MCOPartTypeSingle:
            partTypeStr = @"single";
            break;
        case MCOPartTypeMessage:
            partTypeStr = @"message";
            break;
        case MCOPartTypeMultipartMixed:
            partTypeStr = @"multipart/mixed";
            break;
        case MCOPartTypeMultipartRelated:
            partTypeStr = @"multipart/related";
            break;
        case MCOPartTypeMultipartAlternative:
            partTypeStr = @"multipart/alternative";
            break;
        case MCOPartTypeMultipartSigned:
            partTypeStr = @"multipart/signed";
            break;
    }
    if (partTypeStr) {
        ret[@"partType"] = partTypeStr;
    }
    return ret;
}

@end
