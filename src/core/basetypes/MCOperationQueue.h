#ifndef MAILCORE_MCOPERATIONQUEUE_H

#define MAILCORE_MCOPERATIONQUEUE_H

#include <pthread.h>
#include <semaphore.h>
#include <MailCore/MCObject.h>
#include <MailCore/MCLibetpanTypes.h>

#ifdef __cplusplus

namespace mailcore {
    
    class Operation;
    class OperationQueueCallback;
    class Array;
    
    class MAILCORE_EXPORT OperationQueue : public Object {
    public:
        OperationQueue();
        virtual ~OperationQueue();
        
        virtual void addOperation(Operation * op);
        virtual void cancelAllOperations();
        
        virtual unsigned int count();
        
        virtual void setCallback(OperationQueueCallback * callback);
        virtual OperationQueueCallback * callback();
        
#ifdef __APPLE__
        virtual void setDispatchQueue(dispatch_queue_t dispatchQueue);
        virtual dispatch_queue_t dispatchQueue();
#endif
        
    private:
        Array * mOperations;
        pthread_mutex_t mLock;
        OperationQueueCallback * mCallback;
        
        dispatch_queue_t mDispatchQueue;
        dispatch_queue_t mRunningQueue;
        
        bool mRunning;
        
        void runNextOperation();
        void opStarted();
        void opStopped();
        void beforeMain(Operation * op);
        void callbackOnMainThread(Operation * op);
        void stoppedOnMainThread(void * context);
        void performOnCallbackThread(Operation * op, Method method, void * context, bool waitUntilDone);
    };
    
}

#endif

#endif
