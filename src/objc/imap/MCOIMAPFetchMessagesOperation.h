//
//  MCOIMAPFetchMessagesOperation.h
//  mailcore2
//
//  Created by DINH Viêt Hoà on 3/25/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#ifndef MAILCORE_MCOIMAPFETCHMESSAGESOPERATION_H

#define MAILCORE_MCOIMAPFETCHMESSAGESOPERATION_H

#import <MailCore/MCOIMAPBaseOperation.h>
#import <MailCore/MCOConstants.h>

/** This class implements an operation to fetch a list of messages from a folder */

@class MCOIndexSet;

NS_ASSUME_NONNULL_BEGIN
@interface MCOIMAPFetchMessagesOperation : MCOIMAPBaseOperation

/** This block will be called each time a new message is downloaded. */
@property (nonatomic, copy) MCOIMAPBaseOperationItemProgressBlock progress;

/** Extra headers to request. Must set requestKind | IMAPMessagesRequestKindExtraHeaders */
@property (nonatomic, copy) NSArray * extraHeaders;

/** 
 Starts the asynchronous fetch operation.

 @param completionBlock Called when the operation is finished.

 - On success `error` will be nil and `messages` will be an array of MCOIMAPMessage.
   `vanishedMessages` will contain the messages removed on the server if the server supports QRESYNC and if it was a sync request
 
 - On `MCOErrorParse`, `messages` is NOT nil: the response is decoded as it streams in,
   so it holds every message that parsed cleanly before the parser gave up. Keep these
   messages -- discarding them loses the whole batch to one bad message. An empty array
   is still meaningful and is not the same as nil: it says the FETCH ran and broke
   before any message completed.

   What comes back is NOT necessarily a contiguous prefix of what was requested, and a
   uid being absent does NOT mean it is the one that broke the parser. UID sets can be
   sparse, CHANGEDSINCE returns only changed messages, and the attribute handler drops
   any message missing an attribute the request required (no `X-GM-THRID`, say). Given
   the server answers in ascending uid order, what does hold is that the malformed
   message lies above the highest uid returned -- isolate from there, not from the
   first gap.

   `messages` is nil on `MCOErrorParse` only when the failure happened before the FETCH
   was sent -- an unparseable response to the connect, login or select that precedes it.
   That is a connection- or folder-level fault with no message to attribute it to, so
   nil is the signal to treat it like any other error rather than to blame a message.

   `vanishedMessages` is always nil on this path.

 - On any other failure, `error` will be set with `MCOErrorDomain` as domain and an 
   error code available in `MCOConstants.h`, `messages` and `vanishedMessages` will be nil

   If you are not supporting QRESYNC you can safely ignore `vanishedMessages`.
*/
- (void) start:(void (^)(NSError * __nullable error, NSArray * /* MCOIMAPMessage */ __nullable messages, MCOIndexSet * __nullable vanishedMessages))completionBlock;

@end
NS_ASSUME_NONNULL_END

#endif
