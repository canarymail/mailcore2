#include "MCOperationQueue.h"

#include <libetpan/libetpan.h>

#include "MCOperation.h"
#include "MCOperationCallback.h"
#include "MCOperationQueueCallback.h"
#include "MCMainThread.h"
#include "MCUtils.h"
#include "MCArray.h"
#include "MCLog.h"
#include "MCAutoreleasePool.h"
#include "MCMainThreadAndroid.h"
#include "MCAssert.h"

using namespace mailcore;

OperationQueue::OperationQueue()
{
    mOperations = new Array();
    pthread_mutex_init(&mLock, NULL);
    mCallback = NULL;
    mRunning = false;
    mDispatchQueue = dispatch_get_main_queue();
    mRunningQueue = dispatch_queue_create("com.canary.mailcore.run", DISPATCH_QUEUE_SERIAL);
}

OperationQueue::~OperationQueue()
{
    if (mDispatchQueue != NULL) {
        dispatch_release(mDispatchQueue);
    }
    if (mRunningQueue != NULL) {
        dispatch_release(mRunningQueue);
    }
    MC_SAFE_RELEASE(mOperations);
    pthread_mutex_destroy(&mLock);
}

void OperationQueue::addOperation(Operation * op)
{
    pthread_mutex_lock(&mLock);
    mOperations->addObject(op);
    pthread_mutex_unlock(&mLock);
    opStarted();
    retain();
    dispatch_async(mRunningQueue, ^{
        runNextOperation();
        release();
    });
}

void OperationQueue::cancelAllOperations()
{
    pthread_mutex_lock(&mLock);
    for (unsigned int i = 0 ; i < mOperations->count() ; i ++) {
        Operation * op = (Operation *) mOperations->objectAtIndex(i);
        op->cancel();
    }
    pthread_mutex_unlock(&mLock);
}

void OperationQueue::opStarted()
{
    if (mCallback) {
        mCallback->queueStartRunning();
    }
    retain();
}

void OperationQueue::opStopped()
{
    if (mCallback) {
        mCallback->queueStoppedRunning();
    }
    release();
}

void OperationQueue::runNextOperation()
{
    Operation * op = NULL;
    
    AutoreleasePool * pool = new AutoreleasePool();
    
    pthread_mutex_lock(&mLock);
    if (mOperations->count() > 0) {
        op = (Operation *) mOperations->objectAtIndex(0);
        op->retain();
        mOperations->removeObjectAtIndex(0);
    }
    pthread_mutex_unlock(&mLock);
    
    if (op == NULL) {
        MCLog("stopping %p", this);
        pool->release();
        return;
    }

    op->beforeMain();
    
    if (!op->isCancelled() || op->shouldRunWhenCancelled()) {
        op->main();
    }
    
    op->afterMain();
    
    if (!op->isCancelled()) {
        op->retain();
        
        performOnCallbackThread(op, (Object::Method) &OperationQueue::callbackOnMainThread, op, true);
    }
    
    op->release();
    
    pool->release();
    
    opStopped();
}

void OperationQueue::performOnCallbackThread(Operation * op, Method method, void * context, bool waitUntilDone)
{
#if __APPLE__
    dispatch_queue_t queue = op->callbackDispatchQueue();
    if (queue == NULL) {
        queue = dispatch_get_main_queue();
    }
    performMethodOnDispatchQueue(method, context, queue, waitUntilDone);
#else
    performMethodOnMainThread(method, context, waitUntilDone);
#endif
}

void OperationQueue::beforeMain(Operation * op)
{
    op->beforeMain();
}

void OperationQueue::callbackOnMainThread(Operation * op)
{
    if (op->isCancelled()) {
        op->release();
        return;
    }
    
    if (op->callback() != NULL) {
        op->callback()->operationFinished(op);
        op->release();
    }
}

unsigned int OperationQueue::count()
{
    unsigned int count;
    
    pthread_mutex_lock(&mLock);
    count = mOperations->count();
    pthread_mutex_unlock(&mLock);
    
    return count;
}

void OperationQueue::setCallback(OperationQueueCallback * callback)
{
    mCallback = callback;
}

OperationQueueCallback * OperationQueue::callback()
{
    return mCallback;
}

void OperationQueue::setDispatchQueue(dispatch_queue_t dispatchQueue)
{
    if (mDispatchQueue != NULL) {
        dispatch_release(mDispatchQueue);
    }
    mDispatchQueue = dispatchQueue;
    if (mDispatchQueue != NULL) {
        dispatch_retain(mDispatchQueue);
    }
}

dispatch_queue_t OperationQueue::dispatchQueue()
{
    return mDispatchQueue;
}
