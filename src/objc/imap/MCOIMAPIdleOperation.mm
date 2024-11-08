//
//  MCOIMAPIdleOperation.m
//  mailcore2
//
//  Created by DINH Viêt Hoà on 3/25/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import "MCOIMAPIdleOperation.h"

#include "MCAsyncIMAP.h"

#import "MCOOperation+Private.h"
#import "MCOUtils.h"

typedef void (^CompletionType)(NSData *response, NSError *error);

@interface MCOIMAPIdleOperation ()

@end

@implementation MCOIMAPIdleOperation {
    CompletionType _completionBlock;
}

#define nativeType mailcore::IMAPIdleOperation

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
    [super dealloc];
}

- (void) start:(void (^)(NSData *response, NSError *error))completionBlock
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
    if (op->isInterrupted()) {
        _completionBlock(nil, [NSError mco_errorWithErrorCode:mailcore::ErrorIdleInterrupted]);
    } else if (op->error() == mailcore::ErrorNone) {
        _completionBlock([NSData mco_dataWithMCData:op->response()], nil);
    } else {
        _completionBlock(nil, [NSError mco_errorWithErrorCode:op->error()]);
    }
    [_completionBlock release];
    _completionBlock = nil;
}

- (void) interruptIdle
{
    MCO_NATIVE_INSTANCE->interruptIdle();
}

@end
