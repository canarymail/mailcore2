//
//  MCIMAPReconnectOperation.hpp
//  mailcore2
//
//  Created by Dev Sanghani on 11/20/18.
//  Copyright © 2018 MailCore. All rights reserved.
//

#ifndef MAILCORE_MCIMAPRECONNECTOPERATION_H

#define MAILCORE_MCIMAPRECONNECTOPERATION_H

#include <MailCore/MCBaseTypes.h>
#include <MailCore/MCAbstract.h>
#include <MailCore/MCIMAPOperation.h>

#ifdef __cplusplus

namespace mailcore {
    
    class MAILCORE_EXPORT IMAPReconnectOperation : public IMAPOperation {
    public:
        IMAPReconnectOperation();
        virtual ~IMAPReconnectOperation();
        
    public: // subclass behavior
        virtual void main();
    };
    
}

#endif

#endif
