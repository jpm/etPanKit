/*
 *  LEPError.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 17/01/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#define LEPErrorDomain @"LEPErrorDomain"

enum {
    LEPNoError,
	LEPErrorConnection,
    LEPErrorParse,
	LEPErrorNotImplemented,
	LEPErrorStartTLSNotAvailable,
	LEPErrorAuthentication,
	LEPErrorNonExistantMailbox,
    LEPErrorRename,
    LEPErrorCreate,
    LEPErrorDelete,
    LEPErrorSubscribe,
    LEPErrorUnsubscribe,
    LEPErrorAppend,
    LEPErrorCopy,
    LEPErrorExpunge,
    LEPErrorFetch,
	LEPErrorStore,
	LEPErrorStorageLimit,
    LEPErrorIdle,
	LEPErrorCertificate,
    LEPErrorNamespace,
    LEPErrorGmailIMAPNotEnabled,
    LEPErrorGmailExceededBandwidthLimit,
};
