#include <MailCore/MCIMAPAsyncSession.h>
#include <MailCore/MCIMAPOperation.h>
#include <MailCore/MCIMAPSession.h>
#include <MailCore/MCAutoreleasePool.h>
#include "../src/async/imap/MCIMAPAsyncConnection.h"

#include <cstdio>
#include <stdexcept>

using namespace mailcore;

class ObservedSession : public IMAPAsyncSession {
public:
    ObservedSession(bool * destroyed, int * completions) : mDestroyed(destroyed), mCompletions(completions) {}
    ~ObservedSession() { *mDestroyed = true; }
    void automaticConfigurationDone(IMAPSession * session) { ++*mCompletions; }
private:
    bool * mDestroyed;
    int * mCompletions;
};

class ConfiguredSession : public IMAPSession {
public:
    explicit ConfiguredSession(bool configured) : mConfigured(configured) {}
    bool isAutomaticConfigurationDone() { return mConfigured; }
    void resetAutomaticConfigurationDone() { mConfigured = false; }
private:
    bool mConfigured;
};

class ObservedConnection : public IMAPAsyncConnection {
public:
    explicit ObservedConnection(bool configured) : mSession(new ConfiguredSession(configured)) {}
    ~ObservedConnection() { mSession->release(); }
    IMAPSession * session() { return mSession; }
private:
    IMAPSession * mSession;
};

static void testCompletionLifetime(bool reconnect, bool configured)
{
    bool destroyed = false;
    int completions = 0;
    AutoreleasePool * pool = new AutoreleasePool();
    ObservedSession * owner = new ObservedSession(&destroyed, &completions);
    IMAPAsyncConnection * connection = new ObservedConnection(configured);
    connection->setOwner(owner);
    IMAPOperation * operation = reconnect ? connection->reconnectOperation() : connection->disconnectOperation();
    operation->retain();
    pool->release();

    // Model a queued completion after both the caller and queue release the owner.
    operation->retain();
    operation->release();
    connection->release();
    owner->release();
    if (destroyed) {
        operation->release();
        throw std::runtime_error("session destroyed before deferred completion");
    }

    // This consumes the completion's retain, as afterMain() does in production.
    operation->afterMainOnMainThread();
    if (!destroyed) {
        throw std::runtime_error("session leaked after operation completion");
    }
    if (completions != (configured ? 1 : 0)) {
        throw std::runtime_error("incorrect automatic configuration callback count");
    }
}

int main()
{
    int failures = 0;
    for (int reconnect = 0; reconnect < 2; ++reconnect) {
        for (int configured = 0; configured < 2; ++configured) {
            try {
                testCompletionLifetime(reconnect != 0, configured != 0);
                std::printf("%s completion lifetime (configured=%d): PASS\n", reconnect ? "reconnect" : "disconnect", configured);
            } catch (const std::exception & error) {
                std::fprintf(stderr, "%s completion lifetime (configured=%d): FAIL: %s\n", reconnect ? "reconnect" : "disconnect", configured, error.what());
                ++failures;
            }
        }
    }
    return failures == 0 ? 0 : 1;
}
