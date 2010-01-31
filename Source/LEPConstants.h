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
    LEPIMAPMailboxFlagMarked      = 1,
    LEPIMAPMailboxFlagUnmarked    = 2,
    LEPIMAPMailboxFlagNoSelect    = 4,
    LEPIMAPMailboxFlagNoInferiors = 8,
} LEPMailboxFlags;

typedef enum {
	LEPIMAPMessageFlagSeen          = 1 << 0,
	LEPIMAPMessageFlagAnswered      = 1 << 1,
	LEPIMAPMessageFlagFlagged       = 1 << 2,
	LEPIMAPMessageFlagDeleted       = 1 << 3,
	LEPIMAPMessageFlagDraft         = 1 << 4,
	LEPIMAPMessageFlagMDNSent       = 1 << 5,
	LEPIMAPMessageFlagForwarded     = 1 << 6,
	LEPIMAPMessageFlagSubmitPending = 1 << 7,
	LEPIMAPMessageFlagSubmitted     = 1 << 8,
} LEPIMAPMessageFlag;

typedef enum {
    LEPIMAPMessagesRequestKindFlags         = 1 << 0,
    LEPIMAPMessagesRequestKindHeaders       = 1 << 1,
    LEPIMAPMessagesRequestKindStructure     = 1 << 3,
} LEPIMAPMessagesRequestKind;
