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
#import <libetpan/libetpan.h>

struct lepData {
	mailimap * imap;
};

#define _imap ((struct lepData *) _lepData)->imap

enum {
	STATE_DISCONNECTED,
	STATE_CONNECTED,
	STATE_LOGGEDIN,
	STATE_SELECTED,
};

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
- (void) _disconnect;

@end

@implementation LEPIMAPSession

@synthesize host = _host;
@synthesize port = _port;
@synthesize login = _login;
@synthesize password = _password;
@synthesize authType = _authType;
@synthesize realm = _realm;

@synthesize error = _error;

- (id) init
{
	self = [super init];
	
	_queue = [[NSOperationQueue alloc] init];
	[_queue setMaxConcurrentOperationCount:1];
	
	return self;
}

- (void) dealloc
{
	[self _unsetup];
	
	[_realm release];
    [_host release];
    [_login release];
    [_password release];
	
	[_queue release];
	
	[_currentMailbox release];
	[_error release];
	
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
	
	[request setSession:self];
	
	[self setError:nil];
}

- (void) _connectIfNeeded
{
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

- (void) _connect
{
	int r;
	
	LEPAssert(_state == STATE_DISCONNECTED);
	
    switch (_authType) {
		case LEPAuthTypeStartTLS:
			r = mailimap_socket_connect(_imap, [[self host] UTF8String], [self port]);
			if (r != MAILIMAP_NO_ERROR) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				
				return;
			}
			
			r = mailimap_socket_starttls(_imap);
			if (r != MAILIMAP_NO_ERROR) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorStartTLSNotAvailable userInfo:nil];
				[self setError:error];
				[error release];
				
				return;
			}
			
			break;
			
		case LEPAuthTypeTLS:
			r = mailimap_ssl_connect(_imap, [[self host] UTF8String], [self port]);
			if (r != MAILIMAP_NO_ERROR) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			
			break;
			
		default:
			r = mailimap_socket_connect(_imap, [[self host] UTF8String], [self port]);
			if (r != MAILIMAP_NO_ERROR) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			
			break;
    }
	
	_state = STATE_CONNECTED;
}

- (void) _login
{
	int r;
	
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
			if (r != MAILIMAP_NO_ERROR) {
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
    else if (r != MAILIMAP_NO_ERROR) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorAuthentication userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    
	_state = STATE_LOGGEDIN;
}

- (void) _select:(NSString *)mailbox
{
	int r;
	
	LEPAssert(_state == STATE_LOGGEDIN);
	
	r = mailimap_select(_imap, [mailbox UTF8String]);
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
	else if (r != MAILIMAP_NO_ERROR) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorNonExistantMailbox userInfo:nil];
		[self setError:error];
		[error release];
		return;
	}
	
	[_currentMailbox release];
	_currentMailbox = [mailbox copy];
	
	_state = STATE_SELECTED;
}

- (void) _disconnect
{
	mailimap_logout(_imap);
	_state = STATE_DISCONNECTED;
}

static int imap_flags_to_flags(struct mailimap_mbx_list_flags * imap_flags)
{
    int flags;
    clistiter * cur;
    
    flags = 0;
    if (imap_flags->mbf_type == MAILIMAP_MBX_LIST_FLAGS_SFLAG) {
        switch (imap_flags->mbf_sflag) {
            case MAILIMAP_MBX_LIST_SFLAG_MARKED:
                flags |= LEPMailboxFlagMarked;
                break;
            case MAILIMAP_MBX_LIST_SFLAG_NOSELECT:
                flags |= LEPMailboxFlagNoSelect;
                break;
            case MAILIMAP_MBX_LIST_SFLAG_UNMARKED:
                flags |= LEPMailboxFlagUnmarked;
                break;
        }
    }
    
    for(cur = clist_begin(imap_flags->mbf_oflags) ; cur != NULL ;
        cur = clist_next(cur)) {
        struct mailimap_mbx_list_oflag * oflag;
        
        oflag = clist_content(cur);
        
        switch (oflag->of_type) {
            case MAILIMAP_MBX_LIST_OFLAG_NOINFERIORS:
                flags |= LEPMailboxFlagNoInferiors;
                break;
        }
    }
    
    return flags;
}

- (NSArray *) _getResultsFromError:(int)r list:(clist *)list
{
    clistiter * cur;
	clist * imap_folders;
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
	else if (r != MAILIMAP_NO_ERROR) {
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
            flags = imap_flags_to_flags(mb_list->mb_flag);
        
        folder = [[LEPIMAPFolder alloc] init];
        [folder _setPath:[NSString stringWithUTF8String:mb_list->mb_name]];
        [folder _setDelimiter:mb_list->mb_delimiter];
        [folder _setFlags:flags];
        
        [result addObject:folder];
        
        [folder release];
    }
    
	mailimap_list_result_free(imap_folders);
	
	return result;
}

- (NSArray *) _fetchSubscribedFolders
{
    int r;
    clist * imap_folders;
    
	[self _loginIfNeeded];
	if ([self error] != nil)
        return nil;
    
	r = mailimap_lsub(_imap, "", "*", &imap_folders);
    return [self _getResultsFromError:r list:imap_folders];
}

- (NSArray *) _fetchAllFolders
{
    int r;
    clist * imap_folders;
    
	[self _loginIfNeeded];
	if ([self error] != nil)
        return nil;
	
	r = mailimap_list(_imap, "", "*", &imap_folders);
    return [self _getResultsFromError:r list:imap_folders];
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
	else if (r != MAILIMAP_NO_ERROR) {
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
	else if (r != MAILIMAP_NO_ERROR) {
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
	else if (r != MAILIMAP_NO_ERROR) {
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
	else if (r != MAILIMAP_NO_ERROR) {
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
	else if (r != MAILIMAP_NO_ERROR) {
		NSError * error;
		
		error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorUnsubscribe userInfo:nil];
		[self setError:error];
		[error release];
        return;
	}
}

@end
