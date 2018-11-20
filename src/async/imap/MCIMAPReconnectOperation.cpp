//
//  MCIMAPReconnectOperation.cpp
//  mailcore2
//
//  Created by Dev Sanghani on 11/20/18.
//  Copyright © 2018 MailCore. All rights reserved.
//

#include "MCIMAPReconnectOperation.h"

#include "MCIMAPAsyncConnection.h"
#include "MCIMAPSession.h"

using namespace mailcore;

IMAPReconnectOperation::IMAPReconnectOperation()
{
}

IMAPReconnectOperation::~IMAPReconnectOperation()
{
}

void IMAPReconnectOperation::main()
{
    ErrorCode error;
    session()->session()->reconnect(&error);
    setError(error);
}
