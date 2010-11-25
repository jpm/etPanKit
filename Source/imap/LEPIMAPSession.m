//
//  LEPIMAPSession.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 06/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"
#import "LEPUtils.h"
#import "LEPError.h"
#import "LEPIMAPRequest.h"
#import "LEPIMAPFolder.h"
#import "LEPIMAPFolderPrivate.h"
#import "LEPIMAPMessage.h"
#import "LEPIMAPMessagePrivate.h"
#import "LEPAddress.h"
#import "LEPMessageHeader.h"
#import "LEPMessageHeaderPrivate.h"
#import "LEPIMAPAttachment.h"
#import "LEPIMAPAttachmentPrivate.h"
#import <libetpan/libetpan.h>
#import "LEPCertificateUtils.h"

#define MAX_IDLE_DELAY (28 * 60)

struct lepData {
	mailimap * imap;
};

#define _imap ((struct lepData *) _lepData)->imap
#define get_imap(session) ((struct lepData *) session->_lepData)->imap

enum {
	STATE_DISCONNECTED,
	STATE_CONNECTED,
	STATE_LOGGEDIN,
	STATE_SELECTED,
};

#pragma mark fetch helper

static int fetch_bodystructure(mailimap * session,
							   uint32_t msgid, struct mailimap_body ** result)
{
	int r;
	clist * fetch_list;
	struct mailimap_fetch_att * fetch_att;
	struct mailimap_fetch_type * fetch_type;
	struct mailimap_set * set;
	struct mailimap_msg_att * msg_att;
	int res;
	int found;
	clistiter * cur;
	
	fetch_att = mailimap_fetch_att_new_bodystructure();
	fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	set = mailimap_set_new_single(msgid);
	
	r = mailimap_uid_fetch(session, set, fetch_type, &fetch_list);
	
	mailimap_set_free(set);
	mailimap_fetch_type_free(fetch_type);
	
	if (r != MAILIMAP_NO_ERROR) {
		res = r;
		goto err;
	}
	
	if (clist_isempty(fetch_list)) {
		res = MAILIMAP_ERROR_FETCH;
		goto free;
	}
	
	msg_att = (struct mailimap_msg_att *) clist_begin(fetch_list)->data;
	
	if (clist_isempty(msg_att->att_list)) {
		res = MAILIMAP_ERROR_FETCH;
		goto free;
	}
	
	found = 0;
	for(cur = clist_begin(msg_att->att_list) ; cur != NULL ; cur = clist_next(cur)) {
		struct mailimap_msg_att_item * item;
		
		item = clist_content(cur);
		
		if (item->att_type != MAILIMAP_MSG_ATT_ITEM_STATIC) {
			continue;
		}
		if (item->att_data.att_static->att_type != MAILIMAP_MSG_ATT_BODYSTRUCTURE) {
			continue;
		}
		
		* result = item->att_data.att_static->att_data.att_bodystructure;
		item->att_data.att_static->att_data.att_bodystructure = NULL;
		found = 1;
	}
	
	if (!found) {
		res = MAILIMAP_ERROR_FETCH;
		goto free;
	}
	
	mailimap_fetch_list_free(fetch_list);
	
	return MAILIMAP_NO_ERROR;
	
free:
	mailimap_fetch_list_free(fetch_list);
err:
	return res;
}

static int
fetch_imap(mailimap * imap, uint32_t uid,
		   struct mailimap_fetch_type * fetch_type,
		   char ** result, size_t * result_len)
{
	int r;
	struct mailimap_msg_att * msg_att;
	struct mailimap_msg_att_item * msg_att_item;
	clist * fetch_result;
	struct mailimap_set * set;
	char * text;
	size_t text_length;
	clistiter * cur;
	
	set = mailimap_set_new_single(uid);
	r = mailimap_uid_fetch(imap, set, fetch_type, &fetch_result);
	
	mailimap_set_free(set);
	
	switch (r) {
		case MAILIMAP_NO_ERROR:
			break;
		default:
			return r;
	}
	
	if (clist_begin(fetch_result) == NULL) {
		mailimap_fetch_list_free(fetch_result);
		return MAILIMAP_ERROR_FETCH;
	}
	
	msg_att = clist_begin(fetch_result)->data;
	
	text = NULL;
	text_length = 0;
	
	for(cur = clist_begin(msg_att->att_list) ; cur != NULL ;
		cur = clist_next(cur)) {
		msg_att_item = clist_content(cur);
		
		if (msg_att_item->att_type == MAILIMAP_MSG_ATT_ITEM_STATIC) {
			
			if (msg_att_item->att_data.att_static->att_type ==
				MAILIMAP_MSG_ATT_BODY_SECTION) {
				text = msg_att_item->att_data.att_static->att_data.att_body_section->sec_body_part;
				msg_att_item->att_data.att_static->att_data.att_body_section->sec_body_part = NULL;
				text_length =
				msg_att_item->att_data.att_static->att_data.att_body_section->sec_length;
			}
		}
	}
	
	mailimap_fetch_list_free(fetch_result);
	
	if (text == NULL)
		return MAILIMAP_ERROR_FETCH;
	
	* result = text;
	* result_len = text_length;
	
	return MAILIMAP_NO_ERROR;
}

static int fetch_rfc822(mailimap * session,
						uint32_t msgid, char ** result)
{
	int r;
	clist * fetch_list;
	struct mailimap_section * section;
	struct mailimap_fetch_att * fetch_att;
	struct mailimap_fetch_type * fetch_type;
	struct mailimap_set * set;
	struct mailimap_msg_att * msg_att;
	struct mailimap_msg_att_item * item;
	int res;
    clistiter * cur;
	
	section = mailimap_section_new(NULL);
	fetch_att = mailimap_fetch_att_new_body_peek_section(section);
	fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	
	set = mailimap_set_new_single(msgid);
	
	r = mailimap_uid_fetch(session, set, fetch_type, &fetch_list);
	
	mailimap_set_free(set);
	mailimap_fetch_type_free(fetch_type);
	
	if (r != MAILIMAP_NO_ERROR) {
		res = r;
		goto err;
	}
	
	if (clist_isempty(fetch_list)) {
		res = MAILIMAP_ERROR_FETCH;
		goto free;
	}
	
	msg_att = (struct mailimap_msg_att *) clist_begin(fetch_list)->data;
	
    for(cur = clist_begin(msg_att->att_list) ; cur != NULL ; cur = clist_next(cur)) {
        item = (struct mailimap_msg_att_item *) clist_content(cur);
        
        if (item->att_type != MAILIMAP_MSG_ATT_ITEM_STATIC) {
            continue;
        }
        if (item->att_data.att_static->att_type != MAILIMAP_MSG_ATT_BODY_SECTION) {
            continue;
        }
        
        * result = item->att_data.att_static->att_data.att_body_section->sec_body_part;
        item->att_data.att_static->att_data.att_body_section->sec_body_part = NULL;
        mailimap_fetch_list_free(fetch_list);
        
        return MAILIMAP_NO_ERROR;
    }
	
    res = MAILIMAP_ERROR_FETCH;
	
free:
	mailimap_fetch_list_free(fetch_list);
err:
	return res;
}

#pragma mark mailbox flags conversion

static int imap_mailbox_flags_to_flags(struct mailimap_mbx_list_flags * imap_flags)
{
    int flags;
    clistiter * cur;
    
    flags = 0;
    if (imap_flags->mbf_type == MAILIMAP_MBX_LIST_FLAGS_SFLAG) {
        switch (imap_flags->mbf_sflag) {
            case MAILIMAP_MBX_LIST_SFLAG_MARKED:
                flags |= LEPIMAPMailboxFlagMarked;
                break;
            case MAILIMAP_MBX_LIST_SFLAG_NOSELECT:
                flags |= LEPIMAPMailboxFlagNoSelect;
                break;
            case MAILIMAP_MBX_LIST_SFLAG_UNMARKED:
                flags |= LEPIMAPMailboxFlagUnmarked;
                break;
        }
    }
    
    for(cur = clist_begin(imap_flags->mbf_oflags) ; cur != NULL ;
        cur = clist_next(cur)) {
        struct mailimap_mbx_list_oflag * oflag;
        
        oflag = clist_content(cur);
        
        switch (oflag->of_type) {
            case MAILIMAP_MBX_LIST_OFLAG_NOINFERIORS:
                flags |= LEPIMAPMailboxFlagNoInferiors;
                break;
        }
    }
    
    return flags;
}

#pragma mark message flags conversion

/*
 LEPIMAPMessageFlagSeen          = 1 << 0,
 LEPIMAPMessageFlagAnswered      = 1 << 1,
 LEPIMAPMessageFlagFlagged       = 1 << 2,
 LEPIMAPMessageFlagDeleted       = 1 << 3,
 LEPIMAPMessageFlagDraft         = 1 << 4,
 LEPIMAPMessageFlagRecent        = 1 << 5,
 LEPIMAPMessageFlagMDNSent       = 1 << 6,
 LEPIMAPMessageFlagForwarded     = 1 << 7,
 LEPIMAPMessageFlagSubmitPending = 1 << 8,
 LEPIMAPMessageFlagSubmitted     = 1 << 9,
 */

static struct mailimap_flag_list * flags_to_lep(LEPIMAPMessageFlag value)
{
    struct mailimap_flag_list * flag_list;
    
    flag_list = mailimap_flag_list_new_empty();
    
    if ((value & LEPIMAPMessageFlagSeen) != 0) {
        mailimap_flag_list_add(flag_list, mailimap_flag_new_seen());
    }
    
    if ((value & LEPIMAPMessageFlagFlagged) != 0) {
        mailimap_flag_list_add(flag_list, mailimap_flag_new_flagged());
    }
    
    if ((value & LEPIMAPMessageFlagDeleted) != 0) {
        mailimap_flag_list_add(flag_list, mailimap_flag_new_deleted());
    }
    
    if ((value & LEPIMAPMessageFlagAnswered) != 0) {
        mailimap_flag_list_add(flag_list, mailimap_flag_new_answered());
    }
    
    if ((value & LEPIMAPMessageFlagDraft) != 0) {
        mailimap_flag_list_add(flag_list, mailimap_flag_new_draft());
    }
    
    if ((value & LEPIMAPMessageFlagForwarded) != 0) {
        mailimap_flag_list_add(flag_list, mailimap_flag_new_flag_keyword(strdup("$Forwarded")));
    }
    
    if ((value & LEPIMAPMessageFlagMDNSent) != 0) {
        mailimap_flag_list_add(flag_list, mailimap_flag_new_flag_keyword(strdup("$MDNSent")));
    }
    
    if ((value & LEPIMAPMessageFlagSubmitPending) != 0) {
        mailimap_flag_list_add(flag_list, mailimap_flag_new_flag_keyword(strdup("$SubmitPending")));
    }
    
    if ((value & LEPIMAPMessageFlagSubmitted) != 0) {
        mailimap_flag_list_add(flag_list, mailimap_flag_new_flag_keyword(strdup("$Submitted")));
    }
    
    return flag_list;
}

static LEPIMAPMessageFlag flag_from_lep(struct mailimap_flag * flag)
{
    switch (flag->fl_type) {
        case MAILIMAP_FLAG_ANSWERED:
            return LEPIMAPMessageFlagAnswered;
        case MAILIMAP_FLAG_FLAGGED:
            return LEPIMAPMessageFlagFlagged;
        case MAILIMAP_FLAG_DELETED:
            return LEPIMAPMessageFlagDeleted;
        case MAILIMAP_FLAG_SEEN:
            return LEPIMAPMessageFlagSeen;
        case MAILIMAP_FLAG_DRAFT:
            return LEPIMAPMessageFlagDraft;
        case MAILIMAP_FLAG_KEYWORD:
            if (strcasecmp(flag->fl_data.fl_keyword, "$Forwarded") == 0) {
                return LEPIMAPMessageFlagForwarded;
            }
            else if (strcasecmp(flag->fl_data.fl_keyword, "$MDNSent") == 0) {
                return LEPIMAPMessageFlagMDNSent;
            }
            else if (strcasecmp(flag->fl_data.fl_keyword, "$SubmitPending") == 0) {
                return LEPIMAPMessageFlagSubmitPending;
            }
            else if (strcasecmp(flag->fl_data.fl_keyword, "$Submitted") == 0) {
                return LEPIMAPMessageFlagSubmitted;
            }
    }
    
    return 0;
}

static LEPIMAPMessageFlag flags_from_lep(struct mailimap_flag_list * flag_list)
{
    LEPIMAPMessageFlag flags;
    clistiter * iter;
    
    flags = 0;
    for(iter = clist_begin(flag_list->fl_list) ;iter != NULL ; iter = clist_next(iter)) {
        struct mailimap_flag * flag;
        
        flag = clist_content(iter);
        flags |= flag_from_lep(flag);
    }
    
    return flags;
}

static LEPIMAPMessageFlag flags_from_lep_att_dynamic(struct mailimap_msg_att_dynamic * att_dynamic)
{
    LEPIMAPMessageFlag flags;
    clistiter * iter;
    
    if (att_dynamic->att_list == NULL)
        return 0;
    
    flags = 0;
    for(iter = clist_begin(att_dynamic->att_list) ;iter != NULL ; iter = clist_next(iter)) {
        struct mailimap_flag_fetch * flag_fetch;
        struct mailimap_flag * flag;
        
        flag_fetch = clist_content(iter);
        if (flag_fetch->fl_type != MAILIMAP_FLAG_FETCH_OTHER) {
            continue;
        }
        
        flag = flag_fetch->fl_flag;
        flags |= flag_from_lep(flag);
    }
    
    return flags;
}

#pragma mark set conversion

static NSArray * arrayFromSet(struct mailimap_set * imap_set)
{
    NSMutableArray * result;
    clistiter * iter;
    
    result = [NSMutableArray array];
    for(iter = clist_begin(imap_set->set_list) ; iter != NULL ; iter = clist_next(iter)) {
        struct mailimap_set_item * item;
        unsigned long i;
        
        item = clist_content(iter);
        for(i = item->set_first ; i <= item->set_last ; i ++) {
            NSNumber * nb;
            
            nb = [NSNumber numberWithLong:i];
            [result addObject:nb];
        }
    }
    
    return result;
}

static struct mailimap_set * setFromArray(NSArray * array)
{
    unsigned int currentIndex;
    unsigned int currentFirst;
    unsigned int currentValue;
    unsigned int lastValue;
    struct mailimap_set * imap_set;
    
    currentFirst = 0;
    currentValue = 0;
    lastValue = 0;
	currentIndex = 0;
    
	array = [array sortedArrayUsingSelector:@selector(compare:)];
    imap_set = mailimap_set_new_empty();
	
	while (currentIndex < [array count]) {
        currentValue = [[array objectAtIndex:currentIndex] unsignedLongValue];
        if (currentFirst == 0) {
            currentFirst = currentValue;
        }
        
        if ((lastValue != 0) && (currentValue != lastValue + 1)) {
			mailimap_set_add_interval(imap_set, currentFirst, lastValue);
			currentFirst = 0;
			lastValue = 0;
        }
        else {
            lastValue = currentValue;
            currentIndex ++;
        }
    }
	if (currentFirst != 0) {
		mailimap_set_add_interval(imap_set, currentFirst, lastValue);
	}
	
    return imap_set;
}


@interface LEPIMAPSession ()

@property (nonatomic, copy) NSError * error;

- (void) _setup;
- (void) _unsetup;

- (void) _connectIfNeeded;
- (void) _connect;
- (void) _loginIfNeeded;
- (void) _login;
- (void) _selectIfNeeded:(NSString *)mailbox;
- (void) _select:(NSString *)mailbox;
- (void) _logout;

@end

@implementation LEPIMAPSession

@synthesize host = _host;
@synthesize port = _port;
@synthesize login = _login;
@synthesize password = _password;
@synthesize authType = _authType;
@synthesize realm = _realm;

@synthesize error = _error;
@synthesize resultUidSet = _resultUidSet;
@synthesize uidValidity = _uidValidity;
@synthesize uidNext = _uidNext;

- (id) init
{
	self = [super init];
	
    _idleDone[0] = -1;
    _idleDone[1] = -1;
	_lepData = calloc(1, sizeof(struct lepData));
	_queue = [[NSOperationQueue alloc] init];
	[_queue setMaxConcurrentOperationCount:1];
    
	return self;
}

- (void) dealloc
{
	[self _unsetup];
	
    [_resultUidSet release];
    
	[_realm release];
    [_host release];
    [_login release];
    [_password release];
	
	[_queue release];
	
	[_currentMailbox release];
	[_error release];
	free(_lepData);
	
	[super dealloc];
}

- (void) _setup
{
	LEPAssert(_imap == NULL);
	
	_imap = mailimap_new(0, NULL);
}

- (void) _unsetup
{
	if (_imap != NULL) {
		mailimap_free(_imap);
		_imap = NULL;
	}
}

- (void) queueOperation:(LEPIMAPRequest *)request
{
	if (_imap == NULL) {
		[self _setup];
	}
	
    LEPLog(@"queue operation %@", request);
	//[request setSession:self];
	[_queue addOperation:request];
}

- (void) _connectIfNeeded
{
    LEPLog(@"request had error ? %@ %@", self, [self error]);
    if ([self error] != nil) {
        LEPLog(@"*** request had error %@", [self error]);
        if ([[[self error] domain] isEqualToString:LEPErrorDomain]) {
            if (([[self error] code] == LEPErrorConnection) || ([[self error] code] == LEPErrorParse)) {
                [self _logout];
                _state = STATE_DISCONNECTED;
                LEPLog(@"disconnect because of error");
            }
        }
    }
    
    [self setError:nil];
    
	if (_state == STATE_DISCONNECTED) {	
		[self _connect];
	}
}

- (void) _loginIfNeeded
{
	[self _connectIfNeeded];
	if ([self error] != nil)
		return;
	
	if (_state == STATE_CONNECTED) {
		[self _login];
	}
}

- (void) _selectIfNeeded:(NSString *)mailbox
{
	[self _loginIfNeeded];
	if ([self error] != nil)
		return;
	
	if (_state == STATE_LOGGEDIN) {
		[self _select:mailbox];
	}
	if (_state == STATE_SELECTED) {
		if (![_currentMailbox isEqualToString:mailbox]) {
			[self _select:mailbox];
		}
	}
}

- (BOOL) _hasError:(int)errorCode
{
	return ((errorCode != MAILIMAP_NO_ERROR) && (errorCode != MAILIMAP_NO_ERROR_AUTHENTICATED) &&
			(errorCode != MAILIMAP_NO_ERROR_NON_AUTHENTICATED));
}

- (BOOL) _checkCertificate
{
    return lepCheckCertificate(_imap->imap_stream, [self host]);
}

- (void) _connect
{
	int r;
	
	LEPLog(@"connect %@", self);
	
	LEPAssert(_state == STATE_DISCONNECTED);
	
    switch (_authType) {
		case LEPAuthTypeStartTLS:
            LEPLog(@"STARTTLS connect");
			r = mailimap_socket_connect(_imap, [[self host] UTF8String], [self port]);
			if ([self _hasError:r]) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				
				return;
			}
			
			r = mailimap_socket_starttls(_imap);
			if ([self _hasError:r]) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorStartTLSNotAvailable userInfo:nil];
				[self setError:error];
				[error release];
				
				return;
			}
			if (![self _checkCertificate]) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorCertificate userInfo:nil];
				[self setError:error];
				[error release];
                return;
            }
			
			break;
			
		case LEPAuthTypeTLS:
			r = mailimap_ssl_connect(_imap, [[self host] UTF8String], [self port]);
			LEPLog(@"ssl connect %@ %u %u", [self host], [self port], r);
			if ([self _hasError:r]) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			if (![self _checkCertificate]) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorCertificate userInfo:nil];
				[self setError:error];
				[error release];
                return;
            }
            
			break;
			
		default:
            LEPLog(@"socket connect");
			r = mailimap_socket_connect(_imap, [[self host] UTF8String], [self port]);
            LEPLog(@"socket connect %i", r);
			if ([self _hasError:r]) {
				NSError * error;
				
                LEPLog(@"connect error %i", r);
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			
			break;
    }
	
	_state = STATE_CONNECTED;
	LEPLog(@"connect ok");
}

- (void) _login
{
	int r;
	
	LEPLog(@"login");
	
	LEPAssert(_state == STATE_CONNECTED);
	
	switch ([self authType]) {
		case LEPAuthTypeClear:
		case LEPAuthTypeStartTLS:
		case LEPAuthTypeTLS:
		default:
			r = mailimap_login(_imap, [[self login] UTF8String], [[self password] UTF8String]);
			break;
			
		case LEPAuthTypeSASLCRAMMD5:
			r = mailimap_authenticate(_imap, "CRAM-MD5",
									  NULL,
									  NULL,
									  NULL,
									  [[self login] UTF8String], [[self login] UTF8String],
									  [[self password] UTF8String], NULL);
			break;
			
		case LEPAuthTypeSASLPlain:
			r = mailimap_authenticate(_imap, "PLAIN",
									  NULL,
									  NULL,
									  NULL,
									  [[self login] UTF8String], [[self login] UTF8String],
									  [[self password] UTF8String], NULL);
			break;
			
		case LEPAuthTypeSASLGSSAPI:
			// needs to be tested
			r = mailimap_authenticate(_imap, "GSSAPI",
									  [[self host] UTF8String],
									  NULL,
									  NULL,
									  [[self login] UTF8String], [[self login] UTF8String],
									  [[self password] UTF8String], NULL);
			break;
			
		case LEPAuthTypeSASLDIGESTMD5:
			r = mailimap_authenticate(_imap, "DIGEST-MD5",
									  [[self host] UTF8String],
									  NULL,
									  NULL,
									  [[self login] UTF8String], [[self login] UTF8String],
									  [[self password] UTF8String], NULL);
			if ([self _hasError:r]) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorAuthentication userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			break;

		case LEPAuthTypeSASLLogin:
			r = mailimap_authenticate(_imap, "LOGIN",
									  NULL,
									  NULL,
									  NULL,
									  [[self login] UTF8String], [[self login] UTF8String],
									  [[self password] UTF8String], NULL);
			break;
			
		case LEPAuthTypeSASLSRP:
			r = mailimap_authenticate(_imap, "SRP",
									  NULL,
									  NULL,
									  NULL,
									  [[self login] UTF8String], [[self login] UTF8String],
									  [[self password] UTF8String], NULL);
			break;
			
		case LEPAuthTypeSASLNTLM:
			r = mailimap_authenticate(_imap, "NTLM",
									  [[self host] UTF8String],
									  NULL,
									  NULL,
									  [[self login] UTF8String], [[self login] UTF8String],
									  [[self password] UTF8String], [[self realm] UTF8String]);
			break;
			
		case LEPAuthTypeSASLKerberosV4:
			r = mailimap_authenticate(_imap, "KERBEROS_V4",
									  [[self host] UTF8String],
									  NULL,
									  NULL,
									  [[self login] UTF8String], [[self login] UTF8String],
									  [[self password] UTF8String], NULL);
			break;
	}
    if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if ([self _hasError:r]) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorAuthentication userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    
	_state = STATE_LOGGEDIN;
	LEPLog(@"login ok");
}

- (void) _select:(NSString *)mailbox
{
	int r;
	
	LEPLog(@"select");
	LEPAssert(_state == STATE_LOGGEDIN || _state == STATE_SELECTED);
	
	r = mailimap_select(_imap, [mailbox UTF8String]);
    LEPLog(@"select error : %i", r);
    if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        LEPLog(@"select error : %@ %@", self, error);
        [error release];
        return;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorNonExistantMailbox userInfo:nil];
		[self setError:error];
		[error release];
        [_currentMailbox release];
        _currentMailbox = nil;
		return;
	}
	
	[_currentMailbox release];
	_currentMailbox = [mailbox copy];
	if (_imap->imap_selection_info != NULL) {
		_uidValidity = _imap->imap_selection_info->sel_uidvalidity;
		_uidNext = _imap->imap_selection_info->sel_uidnext;
	}
	
	_state = STATE_SELECTED;
	LEPLog(@"select ok");
}

- (NSArray *) _getResultsFromError:(int)r list:(clist *)list account:(LEPIMAPAccount *)account
{
    clistiter * cur;
    NSMutableArray * result;
	
    result = [NSMutableArray array];
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return nil;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return nil;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorNonExistantMailbox userInfo:nil];
		[self setError:error];
		[error release];
        return nil;
	}
	
    for(cur = clist_begin(list) ; cur != NULL ; cur = cur->next) {
        struct mailimap_mailbox_list * mb_list;
        int flags;
        LEPIMAPFolder * folder;
        
        mb_list = cur->data;
        
        flags = 0;
        if (mb_list->mb_flag != NULL)
            flags = imap_mailbox_flags_to_flags(mb_list->mb_flag);
        
        folder = [[LEPIMAPFolder alloc] init];
        [folder _setPath:[NSString stringWithUTF8String:mb_list->mb_name]];
        [folder _setDelimiter:mb_list->mb_delimiter];
        [folder _setFlags:flags];
        [folder _setAccount:account];
		
        [result addObject:folder];
        
        [folder release];
    }
    
	mailimap_list_result_free(list);
	
	return result;
}

- (NSArray *) _fetchSubscribedFoldersWithAccount:(LEPIMAPAccount *)account
{
    int r;
    clist * imap_folders;
    
	LEPLog(@"fetch subscribed");
	[self _loginIfNeeded];
	if ([self error] != nil)
        return nil;
    
	r = mailimap_lsub(_imap, "", "*", &imap_folders);
	LEPLog(@"fetch subscribed %u", r);
    return [self _getResultsFromError:r list:imap_folders account:account];
}

- (NSArray *) _fetchAllFoldersWithAccount:(LEPIMAPAccount *)account
{
    int r;
    clist * imap_folders;
    
	[self _loginIfNeeded];
	if ([self error] != nil)
        return nil;
	
	r = mailimap_list(_imap, "", "*", &imap_folders);
    return [self _getResultsFromError:r list:imap_folders account:account];
}

- (void) _renameFolder:(NSString *)path withNewPath:(NSString *)newPath
{
    int r;
    
    [self _selectIfNeeded:@"INBOX"];
	if ([self error] != nil)
        return;
    
    r = mailimap_rename(_imap, [path UTF8String], [newPath UTF8String]);
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorRename userInfo:nil];
		[self setError:error];
		[error release];
        return;
	}
}

- (void) _deleteFolder:(NSString *)path
{
    int r;
    
    [self _selectIfNeeded:@"INBOX"];
	if ([self error] != nil)
        return;
    
    r = mailimap_delete(_imap, [path UTF8String]);
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorDelete userInfo:nil];
		[self setError:error];
		[error release];
        return;
	}
}

- (void) _createFolder:(NSString *)path
{
    int r;
    
    [self _selectIfNeeded:@"INBOX"];
	if ([self error] != nil)
        return;
    
    r = mailimap_create(_imap, [path UTF8String]);
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorCreate userInfo:nil];
		[self setError:error];
		[error release];
        return;
	}
    
    [self _subscribeFolder:path];
}

- (void) _subscribeFolder:(NSString *)path
{
    int r;
    
    r = mailimap_subscribe(_imap, [path UTF8String]);
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorSubscribe userInfo:nil];
		[self setError:error];
		[error release];
        return;
	}
}

- (void) _unsubscribeFolder:(NSString *)path
{
    int r;
    
    r = mailimap_unsubscribe(_imap, [path UTF8String]);
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorUnsubscribe userInfo:nil];
		[self setError:error];
		[error release];
        return;
	}
}

- (void) _appendMessageData:(NSData *)messageData flags:(LEPIMAPMessageFlag)flags toPath:(NSString *)path
{
    int r;
    struct mailimap_flag_list * flag_list;
    uint32_t uidvalidity;
	uint32_t uidresult;
    
    flag_list = NULL;
    flag_list = flags_to_lep(flags);
    r = mailimap_uidplus_append(_imap, [path UTF8String], flag_list, NULL, [messageData bytes], [messageData length],
								&uidvalidity, &uidresult);
    mailimap_flag_list_free(flag_list);
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorAppend userInfo:nil];
		[self setError:error];
		[error release];
        return;
	}
	[_resultUidSet release];
	_resultUidSet = nil;
	if (uidresult != 0) {
		_resultUidSet = [[NSArray arrayWithObject:[NSNumber numberWithLong:uidresult]] retain];
	}
}

- (void) _copyMessages:(NSArray *)uidSet fromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    int r;
    struct mailimap_set * set;
	struct mailimap_set * src_uid;
	struct mailimap_set * dest_uid;
    uint32_t uidvalidity;
	
    [self _selectIfNeeded:fromPath];
	if ([self error] != nil)
        return;
    
    set = setFromArray(uidSet);
    //r = mailimap_uid_copy(_imap, set, [toPath UTF8String]);
    r = mailimap_uidplus_uid_copy(_imap, set, [toPath UTF8String],
								  &uidvalidity, &src_uid, &dest_uid);
    mailimap_set_free(set);
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorCopy userInfo:nil];
		[self setError:error];
		[error release];
        return;
	}
	
	if (src_uid != NULL) {
		mailimap_set_free(src_uid);
	}
	[_resultUidSet release];
	_resultUidSet = nil;
	if (dest_uid != NULL) {
		_resultUidSet = [arrayFromSet(dest_uid) retain];
		mailimap_set_free(dest_uid);
	}
}

- (void) _expunge:(NSString *)path
{
    int r;
    
    [self _selectIfNeeded:path];
	if ([self error] != nil)
        return;
    
    r = mailimap_expunge(_imap);
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorExpunge userInfo:nil];
		[self setError:error];
		[error release];
        return;
	}
}

- (NSArray *) _fetchFolderMessages:(NSString *)path fromUID:(uint32_t)fromUID toUID:(uint32_t)toUID kind:(LEPIMAPMessagesRequestKind)kind folder:(LEPIMAPFolder *)folder
{
    struct mailimap_set * imap_set;
    struct mailimap_fetch_type * fetch_type;
    clist * fetch_result;
    NSMutableArray * result;
    struct mailimap_fetch_att * fetch_att;
    int r;
    clistiter * iter;
    
    [self _selectIfNeeded:path];
	if ([self error] != nil)
        return nil;
    
    result = [NSMutableArray array];    
    
    imap_set = mailimap_set_new_interval(fromUID, toUID);
    fetch_type = mailimap_fetch_type_new_fetch_att_list_empty();
    fetch_att = mailimap_fetch_att_new_uid();
    mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
    if ((kind & LEPIMAPMessagesRequestKindFlags) != 0) {
		LEPLog(@"request flags");
        fetch_att = mailimap_fetch_att_new_flags();
        mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
    }
    if ((kind & LEPIMAPMessagesRequestKindHeaders) != 0) {
        clist * hdrlist;
        char * header;
        struct mailimap_header_list * imap_hdrlist;
        struct mailimap_section * section;
        
		LEPLog(@"request envelope");
        // envelope
        fetch_att = mailimap_fetch_att_new_envelope();
        mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
        
        // references header
        hdrlist = clist_new();
        header = strdup("References");
        clist_append(hdrlist, header);
        header = strdup("Subject");
        clist_append(hdrlist, header);
        imap_hdrlist = mailimap_header_list_new(hdrlist);
        section = mailimap_section_new_header_fields(imap_hdrlist);
        fetch_att = mailimap_fetch_att_new_body_peek_section(section);
        mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
    }
	if ((kind & LEPIMAPMessagesRequestKindStructure) != 0) {
		// message structure
		LEPLog(@"request bodystructure");
		fetch_att = mailimap_fetch_att_new_bodystructure();
        mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
	}
	if ((kind & LEPIMAPMessagesRequestKindInternalDate) != 0) {
		// internal date
		fetch_att = mailimap_fetch_att_new_internaldate();
        mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);
	}
    
    r = mailimap_uid_fetch(_imap, imap_set, fetch_type, &fetch_result);
    mailimap_fetch_type_free(fetch_type);
    mailimap_set_free(imap_set);
    
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        LEPLog(@"error stream");
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return nil;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        LEPLog(@"error parse");
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return nil;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
        LEPLog(@"error fetch");
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorFetch userInfo:nil];
		[self setError:error];
		[error release];
        return nil;
	}
    
    for(iter = clist_begin(fetch_result) ; iter != NULL ; iter = clist_next(iter)) {
        struct mailimap_msg_att * msg_att;
        clistiter * item_iter;
        uint32_t uid;
        LEPIMAPMessage * msg;
        
        msg = [[LEPIMAPMessage alloc] init];
        [msg setFolder:folder];
		
        msg_att = clist_content(iter);
        uid = 0;
        for(item_iter = clist_begin(msg_att->att_list) ; item_iter != NULL ; item_iter = clist_next(item_iter)) {
            struct mailimap_msg_att_item * att_item;
            
            att_item = clist_content(item_iter);
            if (att_item->att_type == MAILIMAP_MSG_ATT_ITEM_DYNAMIC) {
				LEPIMAPMessageFlag flags;
				
				flags = flags_from_lep_att_dynamic(att_item->att_data.att_dyn);
				[msg setFlags:flags];
				[msg setOriginalFlags:flags];
            }
            else if (att_item->att_type == MAILIMAP_MSG_ATT_ITEM_STATIC) {
                struct mailimap_msg_att_static * att_static;
                
                att_static = att_item->att_data.att_static;
                if (att_static->att_type == MAILIMAP_MSG_ATT_UID) {
                    uid = att_static->att_data.att_uid;
                }
                else if (att_static->att_type == MAILIMAP_MSG_ATT_ENVELOPE) {
                    struct mailimap_envelope * env;
                    
					LEPLog(@"parse envelope %lu", (unsigned long) uid);
                    env = att_static->att_data.att_env;
					[[msg header] setFromIMAPEnvelope:env];
                }
                else if (att_static->att_type == MAILIMAP_MSG_ATT_BODY_SECTION) {
                    char * references;
                    size_t ref_size;
                    
                    // references
                    references = att_static->att_data.att_body_section->sec_body_part;
                    ref_size = att_static->att_data.att_body_section->sec_length;
					
					[[msg header] setFromIMAPReferences:[NSData dataWithBytes:references length:ref_size]];
					
				}
				else if (att_static->att_type == MAILIMAP_MSG_ATT_BODYSTRUCTURE) {
					NSArray * attachments;
					
					// bodystructure
					attachments = [LEPIMAPAttachment attachmentsWithIMAPBody:att_static->att_data.att_body];
					[msg _setAttachments:attachments];
				}
				else if (att_static->att_type == MAILIMAP_MSG_ATT_INTERNALDATE) {
					[[msg header] _setFromInternalDate:att_static->att_data.att_internal_date];
				}
            }
        }
		
		if (uid < fromUID) {
			uid = 0;
		}
		
        if (uid != 0) {
            [msg _setUid:uid];
        }
		else {
			[msg release];
			continue;
		}
		
		[result addObject:msg];
		[msg release];
    }
    
    mailimap_fetch_list_free(fetch_result);
    
    return result;
}

- (NSData *) _fetchMessageWithUID:(uint32_t)uid path:(NSString *)path
{
	char * rfc822;
	int r;
	NSData * data;
	
    [self _selectIfNeeded:path];
	if ([self error] != nil)
        return nil;
	
    rfc822 = NULL;
	r = fetch_rfc822(_imap, uid, &rfc822);
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return nil;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return nil;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorFetch userInfo:nil];
		[self setError:error];
		[error release];
        return nil;
	}
	
	data = [NSData dataWithBytes:rfc822 length:strlen(rfc822)];
    
	mailimap_nstring_free(rfc822);
	
	return data;
}

- (NSArray *) _fetchMessageStructureWithUID:(uint32_t)uid path:(NSString *)path message:(LEPIMAPMessage *)message
{
	struct mailimap_body * body;
	int r;
	NSArray * attachments;
	
    [self _selectIfNeeded:path];
	if ([self error] != nil)
        return nil;
	
	LEPLog(@"fetch bodystructure");
	r =  fetch_bodystructure(_imap, uid, &body);
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
		LEPLog(@"fetch stream");
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return nil;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
		LEPLog(@"fetch parse");
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return nil;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		LEPLog(@"fetch other %u", r);
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorFetch userInfo:nil];
		[self setError:error];
		[error release];
        return nil;
	}
	
	attachments = [LEPIMAPAttachment attachmentsWithIMAPBody:body];
	for(LEPAbstractAttachment * attachment in attachments) {
		[attachment setMessage:message];
	}
	
	mailimap_body_free(body);
	
	return attachments;
}

- (NSData *) _fetchAttachmentWithPartID:(NSString *)partID UID:(uint32_t)uid path:(NSString *)path encoding:(int)encoding
{
	struct mailimap_fetch_type * fetch_type;
    struct mailimap_fetch_att * fetch_att;
    struct mailimap_section * section;
	struct mailimap_section_part * section_part;
	clist * sec_list;
	NSArray * partIDArray;
	int r;
	char * text;
	size_t text_length;
	NSData * data;
	
    [self _selectIfNeeded:path];
	if ([self error] != nil)
        return nil;
	
	partIDArray = [partID componentsSeparatedByString:@"."];
	sec_list = clist_new();
	for(NSString * element in partIDArray) {
		uint32_t * value;
		
		value = malloc(sizeof(* value));
		* value = [element integerValue];
		clist_append(sec_list, value);
	}
	section_part = mailimap_section_part_new(sec_list);
	section = mailimap_section_new_part(section_part);
	fetch_att = mailimap_fetch_att_new_body_peek_section(section);
	fetch_type = mailimap_fetch_type_new_fetch_att(fetch_att);
	
	r = fetch_imap(_imap, uid, fetch_type, &text, &text_length);
	mailimap_fetch_type_free(fetch_type);
	
    LEPLog(@"had error : %i", r);
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return nil;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return nil;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorFetch userInfo:nil];
		[self setError:error];
		[error release];
        return nil;
	}
	
	switch (encoding) {
		case MAILIMAP_BODY_FLD_ENC_7BIT:
		case MAILIMAP_BODY_FLD_ENC_8BIT:
		case MAILIMAP_BODY_FLD_ENC_BINARY:
		case MAILIMAP_BODY_FLD_ENC_OTHER:
		{
			data = [NSData dataWithBytes:text length:text_length];
			break;
		}
		case MAILIMAP_BODY_FLD_ENC_BASE64:
		case MAILIMAP_BODY_FLD_ENC_QUOTED_PRINTABLE:
		{
			char * decoded;
			size_t decoded_length;
			size_t cur_token;
			int mime_encoding;
			
			switch (encoding) {
				case MAILIMAP_BODY_FLD_ENC_BASE64:
					mime_encoding = MAILMIME_MECHANISM_BASE64;
					break;
				case MAILIMAP_BODY_FLD_ENC_QUOTED_PRINTABLE:
					mime_encoding = MAILMIME_MECHANISM_QUOTED_PRINTABLE;
					break;
			}
			
			cur_token = 0;
			mailmime_part_parse(text, text_length, &cur_token,
								mime_encoding, &decoded, &decoded_length);
			data = [NSData dataWithBytes:decoded length:decoded_length];
			mailmime_decoded_part_free(decoded);
			break;
		}
	}
	
	mailimap_nstring_free(text);
	
	return data;
}

- (void) _storeFlags:(LEPIMAPMessageFlag)flags kind:(LEPIMAPStoreFlagsRequestKind)kind messagesUids:(NSArray *)uids path:(NSString *)path
{
	struct mailimap_set * imap_set;
	struct mailimap_store_att_flags * store_att_flags;
	struct mailimap_flag_list * flag_list;
	int r;
	
    [self _selectIfNeeded:path];
	if ([self error] != nil)
        return;
	
	imap_set = setFromArray(uids);
	
	flag_list = mailimap_flag_list_new_empty();
	if ((flags & LEPIMAPMessageFlagSeen) != 0) {
		struct mailimap_flag * f;
		
		f = mailimap_flag_new_seen();
		mailimap_flag_list_add(flag_list, f);
	}
	if ((flags & LEPIMAPMessageFlagAnswered) != 0) {
		struct mailimap_flag * f;
		
		f = mailimap_flag_new_answered();
		mailimap_flag_list_add(flag_list, f);
	}
	if ((flags & LEPIMAPMessageFlagFlagged) != 0) {
		struct mailimap_flag * f;
		
		f = mailimap_flag_new_flagged();
		mailimap_flag_list_add(flag_list, f);
	}
	if ((flags & LEPIMAPMessageFlagDeleted) != 0) {
		struct mailimap_flag * f;
		
		f = mailimap_flag_new_deleted();
		mailimap_flag_list_add(flag_list, f);
	}
	if ((flags & LEPIMAPMessageFlagDraft) != 0) {
		struct mailimap_flag * f;
		
		f = mailimap_flag_new_draft();
		mailimap_flag_list_add(flag_list, f);
	}
	if ((flags & LEPIMAPMessageFlagMDNSent) != 0) {
		struct mailimap_flag * f;
		
		f = mailimap_flag_new_flag_keyword(strdup("$MDNSent"));
		mailimap_flag_list_add(flag_list, f);
	}
	if ((flags & LEPIMAPMessageFlagForwarded) != 0) {
		struct mailimap_flag * f;
		
		f = mailimap_flag_new_flag_keyword(strdup("$Forwarded"));
		mailimap_flag_list_add(flag_list, f);
	}
	if ((flags & LEPIMAPMessageFlagSubmitPending) != 0) {
		struct mailimap_flag * f;
		
		f = mailimap_flag_new_flag_keyword(strdup("$SubmitPending"));
		mailimap_flag_list_add(flag_list, f);
	}
	if ((flags & LEPIMAPMessageFlagSubmitted) != 0) {
		struct mailimap_flag * f;
		
		f = mailimap_flag_new_flag_keyword(strdup("$Submitted"));
		mailimap_flag_list_add(flag_list, f);
	}
	
	switch (kind) {
		case LEPIMAPStoreFlagsRequestKindRemove:
			store_att_flags = mailimap_store_att_flags_new_remove_flags_silent(flag_list);
			break;
		case LEPIMAPStoreFlagsRequestKindAdd:
			store_att_flags = mailimap_store_att_flags_new_add_flags_silent(flag_list);
			break;
		case LEPIMAPStoreFlagsRequestKindSet:
			store_att_flags = mailimap_store_att_flags_new_set_flags_silent(flag_list);
			break;
	}
	r = mailimap_uid_store(_imap, imap_set, store_att_flags);
	mailimap_store_att_flags_free(store_att_flags);
	
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorStore userInfo:nil];
		[self setError:error];
		[error release];
        return;
	}
}

- (void) _logout
{
    if (_imap == NULL)
        return;
    
    if (_imap->imap_stream != NULL) {
        // fast logout
        mailstream_close(_imap->imap_stream);
        _imap->imap_stream = NULL;
        _imap->imap_state = MAILIMAP_STATE_DISCONNECTED;
    }
}

- (void) _idlePath:(NSString *)path
{
    int r;
    
    [self _selectIfNeeded:path];
	if ([self error] != nil)
        return;
    
    r = mailimap_idle(_imap);
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorIdle userInfo:nil];
		[self setError:error];
		[error release];
        return;
	}
    
    int fd;
    int maxfd;
    fd_set readfds;
    struct timeval delay;
    
    fd = mailimap_idle_get_fd(_imap);
    LEPLog(@"wait %i %i", fd, _idleDone[0]);
    
    FD_ZERO(&readfds);
    FD_SET(fd, &readfds);
    FD_SET(_idleDone[0], &readfds);
    maxfd = fd;
    if (_idleDone[0] > maxfd) {
        maxfd = _idleDone[0];
    }
    delay.tv_sec = MAX_IDLE_DELAY;
    delay.tv_usec = 0;
    
    r = select(maxfd + 1, &readfds, NULL, NULL, &delay);
    if (r == 0) {
        // timeout
    }
    else if (r == -1) {
        // do nothing
    }
    else {
        if (FD_ISSET(fd, &readfds)) {
            // has something on socket
            
            LEPLog(@"something on the socket");
        }
        if (FD_ISSET(_idleDone[0], &readfds)) {
            // idle done by user
            char ch;
            
            LEPLog(@"idle done requested");
            read(_idleDone[0], &ch, 1);
        }
    }
    
    r = mailimap_idle_done(_imap);
	if (r == MAILIMAP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if (r == MAILIMAP_ERROR_PARSE) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorParse userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if ([self _hasError:r]) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorIdle userInfo:nil];
		[self setError:error];
		[error release];
        return;
	}
}

- (void) _idlePrepare
{
    LEPAssert(!_idling);
    
    _idling = YES;
    pipe(_idleDone);
}

- (void) _idleDone
{
    int r;
    char c;
    
    c = 0;
    r = write(_idleDone[1], &c, 1);
}

- (void) _idleUnprepare
{
    close(_idleDone[1]);
    close(_idleDone[0]);
    _idleDone[1] = -1;
    _idleDone[0] = -1;
    _idling = NO;
}

- (unsigned int) pendingRequestsCount
{
    return [[_queue operations] count];
}

@end
