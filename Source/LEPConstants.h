/*
 *  LEPConstants.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 04/01/2010.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

typedef enum {
	LEPAuthTypeClear             = 1 << 0,
	LEPAuthTypeStartTLS          = 1 << 1,
	LEPAuthTypeTLS               = 1 << 2,
	LEPAuthTypeSASLCRAMMD5       = 1 << 8,
	LEPAuthTypeSASLPlain         = 1 << 9,
	LEPAuthTypeSASLGSSAPI        = 1 << 10,
	LEPAuthTypeSASLDIGESTMD5     = 1 << 11,
	LEPAuthTypeSASLLogin         = 1 << 12,
	LEPAuthTypeSASLSRP           = 1 << 13,
	LEPAuthTypeSASLNTLM          = 1 << 14,
	LEPAuthTypeSASLKerberosV4    = 1 << 15,
	LEPAuthTypeConnectionMask    = LEPAuthTypeClear | LEPAuthTypeStartTLS | LEPAuthTypeTLS,
	LEPAuthTypeMechanismMask     = ~LEPAuthTypeConnectionMask,
} LEPAuthType;

typedef enum {
    LEPIMAPMailboxFlagMarked      = 1 << 0,
    LEPIMAPMailboxFlagUnmarked    = 1 << 1,
    LEPIMAPMailboxFlagNoSelect    = 1 << 2,
    LEPIMAPMailboxFlagNoInferiors = 1 << 3,
    LEPIMAPMailboxFlagInbox       = 1 << 4,
    LEPIMAPMailboxFlagSentMail    = 1 << 5,
    LEPIMAPMailboxFlagStarred     = 1 << 6,
    LEPIMAPMailboxFlagAllMail     = 1 << 7,
    LEPIMAPMailboxFlagTrash       = 1 << 8,
    LEPIMAPMailboxFlagDrafts      = 1 << 9,
    LEPIMAPMailboxFlagSpam        = 1 << 10,
    LEPIMAPMailboxFlagImportant   = 1 << 11,
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
    LEPIMAPMessagesRequestKindStructure     = 1 << 2,
	LEPIMAPMessagesRequestKindInternalDate  = 1 << 3,
    LEPIMAPMessagesRequestKindFullHeaders   = 1 << 4,
    LEPIMAPMessagesRequestKindHeaderSubject = 1 << 5,
} LEPIMAPMessagesRequestKind;

typedef enum {
	LEPIMAPStoreFlagsRequestKindAdd,
	LEPIMAPStoreFlagsRequestKindRemove,
	LEPIMAPStoreFlagsRequestKindSet,
} LEPIMAPStoreFlagsRequestKind;

typedef enum {
    LEPIMAPWorkaroundGmail = 1 << 0,
    LEPIMAPWorkaroundYahoo = 1 << 1,
} LEPIMAPWorkaround;

typedef enum {
    LEPIMAPCapabilityACL,
    LEPIMAPCapabilityBinary,
    LEPIMAPCapabilityCatenate,
    LEPIMAPCapabilityChildren,
    LEPIMAPCapabilityCompressDeflate,
    LEPIMAPCapabilityCondstore,
    LEPIMAPCapabilityEnable,
    LEPIMAPCapabilityIdle,
    LEPIMAPCapabilityLiteralPlus,
    LEPIMAPCapabilityMultiAppend,
    LEPIMAPCapabilityNamespace,
    LEPIMAPCapabilityQResync,
    LEPIMAPCapabilityQuota,
    LEPIMAPCapabilitySort,
    LEPIMAPCapabilityStartTLS,
    LEPIMAPCapabilityThreadOrderedSubject,
    LEPIMAPCapabilityThreadReferences,
    LEPIMAPCapabilityUIDPlus,
    LEPIMAPCapabilityUnselect,
    LEPIMAPCapabilityXList,
    LEPIMAPCapabilityAuthAnonymous,
    LEPIMAPCapabilityAuthCRAMMD5,
    LEPIMAPCapabilityAuthDigestMD5,
    LEPIMAPCapabilityAuthExternal,
    LEPIMAPCapabilityAuthGSSAPI,
    LEPIMAPCapabilityAuthKerberosV4,
    LEPIMAPCapabilityAuthLogin,
    LEPIMAPCapabilityAuthNTLM,
    LEPIMAPCapabilityAuthOTP,
    LEPIMAPCapabilityAuthPlain,
    LEPIMAPCapabilityAuthSKey,
    LEPIMAPCapabilityAuthSRP,
} LEPIMAPCapability;

#define LEPIMAPNamespacePersonal @"LEPIMAPNamespacePersonal"
#define LEPIMAPNamespaceOther @"LEPIMAPNamespaceOther"
#define LEPIMAPNamespaceShared @"LEPIMAPNamespaceShared"
