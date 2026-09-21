//
//  MCOIMAPFetchMessagesOperation.m
//  mailcore2
//
//  Created by DINH Viêt Hoà on 3/25/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import "MCOIMAPFetchMessagesOperation.h"

#include "MCAsyncIMAP.h"

#import "MCOOperation+Private.h"
#import "MCOUtils.h"

typedef void (^CompletionType)(NSError *error, NSArray * messages, MCOIndexSet * vanishedMessages);

@implementation MCOIMAPFetchMessagesOperation {
    CompletionType _completionBlock;
    MCOIMAPBaseOperationItemProgressBlock _progress;
}

@synthesize progress = _progress;

#define nativeType mailcore::IMAPFetchMessagesOperation

+ (void) load
{
    MCORegisterClass(self, &typeid(nativeType));
}

+ (NSObject *) mco_objectWithMCObject:(mailcore::Object *)object
{
    nativeType * op = (nativeType *) object;
    return [[[self alloc] initWithMCOperation:op] autorelease];
}

- (void) dealloc
{
    [_completionBlock release];
    [_progress release];
    [super dealloc];
}

- (void) start:(void (^)(NSError *error, NSArray * messages, MCOIndexSet * vanishedMessages))completionBlock
{
    _completionBlock = [completionBlock copy];
    [self start];
}

- (void) cancel
{
    [_completionBlock release];
    _completionBlock = nil;
    [super cancel];
}

- (void) operationCompleted
{
    if (_completionBlock == NULL)
        return;
    
    nativeType *op = MCO_NATIVE_INSTANCE;
    if (op->error() == mailcore::ErrorNone) {
        _completionBlock(nil, MCO_TO_OBJC(op->messages()), MCO_TO_OBJC(op->vanishedMessages()));
    } else if (op->error() == mailcore::ErrorParse) {
        // A parse failure aborts the response part-way through, but the messages
        // decoded before that point are complete. Hand them over with the error so
        // the caller can keep them and work out which message broke the parser.
        // Callers that only check the error are unaffected.
        _completionBlock([NSError mco_errorWithErrorCode:op->error()], MCO_TO_OBJC(op->messages()), nil);
    } else {
        _completionBlock([NSError mco_errorWithErrorCode:op->error()], nil, nil);
    }
    [_completionBlock release];
    _completionBlock = nil;
}

- (void) itemProgress:(unsigned int)current maximum:(unsigned int)maximum
{
    if (_progress != NULL) {
        _progress(current);
    }
}

- (void)setExtraHeaders:(NSArray *)extraHeaders {
    MCO_NATIVE_INSTANCE->setExtraHeaders(MCO_FROM_OBJC(mailcore::Array, extraHeaders));
}

- (NSArray *)extraHeaders {
    return MCO_TO_OBJC(MCO_NATIVE_INSTANCE->extraHeaders());
}

@end
