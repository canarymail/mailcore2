//
//  IMAPIdleOperation.cc
//  mailcore2
//
//  Created by DINH Viêt Hoà on 1/12/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#include "MCIMAPIdleOperation.h"

#include "MCIMAPSession.h"
#include "MCIMAPAsyncConnection.h"

using namespace mailcore;

IMAPIdleOperation::IMAPIdleOperation()
{
    mLastKnownUid = 0;
    mSetupSuccess = false;
    mInterrupted = false;
    mResponse = NULL;
    pthread_mutex_init(&mLock, NULL);
}

IMAPIdleOperation::~IMAPIdleOperation()
{
    pthread_mutex_destroy(&mLock);
}

void IMAPIdleOperation::setLastKnownUID(uint32_t uid)
{
    mLastKnownUid = uid;
}

uint32_t IMAPIdleOperation::lastKnownUID()
{
    return mLastKnownUid;
}

void IMAPIdleOperation::prepare(void * data)
{
    if (isInterrupted()) {
        mSetupSuccess = false;
        return;
    }

    mSetupSuccess = session()->session()->setupIdle();
}

void IMAPIdleOperation::unprepare(void * data)
{
    if (mSetupSuccess) {
        session()->session()->unsetupIdle();
    }
}

bool IMAPIdleOperation::isInterrupted() {
    pthread_mutex_lock(&mLock);
    bool interrupted = mInterrupted;
    pthread_mutex_unlock(&mLock);
    
    return interrupted;
}

void IMAPIdleOperation::main()
{
    if (isInterrupted()) {
        return;
    }
    
    ErrorCode error;
    Data * response;
    session()->session()->selectIfNeeded(folder(), &error);
    if (error != ErrorNone) {
        setError(error);
        return;
    }
    
    performMethodOnCallbackThread((Object::Method) &IMAPIdleOperation::prepare, NULL, true);
    
    if (!mSetupSuccess) {
        setError(ErrorIdleSetupFailure);
        return;
    }
    
    session()->session()->idle(folder(), mLastKnownUid, &response, &error);
    setError(error);
//    mResponse = response;
//    MC_SAFE_RETAIN(mResponse);
    
    performMethodOnCallbackThread((Object::Method) &IMAPIdleOperation::unprepare, NULL, true);
}

Data * IMAPIdleOperation::response()
{
    return mResponse;
}

void IMAPIdleOperation::interruptIdle()
{
    pthread_mutex_lock(&mLock);
    mInterrupted = true;
    pthread_mutex_unlock(&mLock);
    if (mSetupSuccess) {
        session()->session()->interruptIdle();
    }
}

