//
//  LEPIMAPSession.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 06/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPSession.h"
#import "LEPUtils.h"
#import "LEPError.h"
#import "LEPIMAPRequest.h"
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
			if (r != MAILIMAP_NO_ERROR) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorAuthentication userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			break;
			
		case LEPAuthTypeSASLCRAMMD5:
			r = mailimap_authenticate(_imap, "CRAM-MD5",
									  NULL,
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
			
		case LEPAuthTypeSASLPlain:
			r = mailimap_authenticate(_imap, "PLAIN",
									  NULL,
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
			
		case LEPAuthTypeSASLGSSAPI:
			// needs to be tested
			r = mailimap_authenticate(_imap, "GSSAPI",
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
			if (r != MAILIMAP_NO_ERROR) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorAuthentication userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			break;
			
		case LEPAuthTypeSASLSRP:
			r = mailimap_authenticate(_imap, "SRP",
									  NULL,
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
			
		case LEPAuthTypeSASLNTLM:
			r = mailimap_authenticate(_imap, "NTLM",
									  [[self host] UTF8String],
									  NULL,
									  NULL,
									  [[self login] UTF8String], [[self login] UTF8String],
									  [[self password] UTF8String], [[self realm] UTF8String]);
			if (r != MAILIMAP_NO_ERROR) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorAuthentication userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			break;
			
		case LEPAuthTypeSASLKerberosV4:
			r = mailimap_authenticate(_imap, "KERBEROS_V4",
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
	}
	_state = STATE_LOGGEDIN;
}

- (void) _select:(NSString *)mailbox
{
	int r;
	
	LEPAssert(_state == STATE_LOGGEDIN);
	
	r = mailimap_select(_imap, [mailbox UTF8String]);
	if (r != MAILIMAP_NO_ERROR) {
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

- (NSArray *) _fetchSubscribedFolders
{
	clist * imap_folders;
	
	[self _loginIfNeeded];
	
	r = mailimap_lsub(_imap, "", "*", &imap_folders);
	
	folder = [[LEPIMAPFolder alloc] init];
	[folder release];
	
	mailimap_list_result_free(imap_folders);
	
	return nil;
}

- (NSArray *) _fetchAllFolders
{
	[self _loginIfNeeded];
#warning should be implemented
	return nil;
}

@end
