/*
 *  LEPConstants.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 04/01/2010.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

typedef enum {
	LEPAuthTypeClear,
	LEPAuthTypeStartTLS,
	LEPAuthTypeTLS,
	LEPAuthTypeSASLCRAMMD5,
	LEPAuthTypeSASLPlain,
	LEPAuthTypeSASLGSSAPI,
	LEPAuthTypeSASLDIGESTMD5,
	LEPAuthTypeSASLLogin,
	LEPAuthTypeSASLSRP,
	LEPAuthTypeSASLNTLM,
	LEPAuthTypeSASLKerberosV4,
} LEPAuthType;

typedef enum {
    LEPMailboxFlagMarked      = 1,
    LEPMailboxFlagUnmarked    = 2,
    LEPMailboxFlagNoSelect    = 4,
    LEPMailboxFlagNoInferiors = 8,
} LEPMailboxFlags;
