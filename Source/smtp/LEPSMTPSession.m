//
//  LEPSMTPSession.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 06/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPSMTPSession.h"

#import "LEPSMTPRequest.h"
#import "LEPUtils.h"
#import "LEPError.h"
#import "LEPAddress.h"
#import <libetpan/libetpan.h>
#import "LEPCertificateUtils.h"
#import "LEPSMTPSessionPrivate.h"

struct lepData {
	mailsmtp * smtp;
};

#define _smtp ((struct lepData *) _lepData)->smtp

@interface LEPSMTPSession ()

@property (nonatomic, copy) NSError * error;

- (void) _setup;
- (void) _unsetup;

- (void) _connect;
- (void) _login;
- (void) _disconnect;

- (void) _progressWithCurrent:(size_t)current maximum:(size_t)maximum;

@end

@implementation LEPSMTPSession

@synthesize host = _host;
@synthesize port = _port;
@synthesize login = _login;
@synthesize password = _password;
@synthesize authType = _authType;
@synthesize realm = _realm;
@synthesize error = _error;
@synthesize checkCertificate = _checkCertificate;

- (id) init
{
	self = [super init];
	
	_lepData = calloc(1, sizeof(struct lepData));
	_queue = [[NSOperationQueue alloc] init];
	[_queue setMaxConcurrentOperationCount:1];
	_checkCertificate = YES;
    
	return self;
}

- (void) dealloc
{
	[_host release];
	[_login release];
	[_password release];
	[_queue release];
	[_error release];
	free(_lepData);
	
	[super dealloc];
}

- (void) queueOperation:(LEPSMTPRequest *)request
{
	LEPLog(@"queue operation");

	[_queue addOperation:request];
}

static void progress(size_t current, size_t maximum, void * context)
{
    LEPSMTPSession * session;
    
    session = context;
    [session _progressWithCurrent:current maximum:maximum];
}

- (void) _setup
{
	LEPAssert(_smtp == NULL);
	
	_smtp = mailsmtp_new(0, NULL);
    
    mailsmtp_set_progress_callback(_smtp, progress, self);
}

- (void) _unsetup
{
	if (_smtp != NULL) {
		mailsmtp_free(_smtp);
		_smtp = NULL;
	}
}

- (BOOL) _checkCertificate
{
    if (!_checkCertificate)
        return YES;
    
    return lepCheckCertificate(_smtp->stream, [self host]);
}

- (void) _connect
{
	int r;
	
    switch (_authType & LEPAuthTypeConnectionMask) {
		case LEPAuthTypeStartTLS:
			LEPLog(@"connect %@ %u", [self host], (unsigned int) [self port]);
			r = mailsmtp_socket_connect(_smtp, [[self host] UTF8String], [self port]);
			if (r != MAILSMTP_NO_ERROR) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				
				return;
			}
			
			LEPLog(@"init");
			r = mailsmtp_init(_smtp);
			if (r == MAILSMTP_ERROR_STREAM) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			else if (r != MAILSMTP_NO_ERROR) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			
			LEPLog(@"start TLS");
			r = mailsmtp_socket_starttls(_smtp);
			if (r != MAILSMTP_NO_ERROR) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorStartTLSNotAvailable userInfo:nil];
				[self setError:error];
				[error release];
				
				return;
			}
			LEPLog(@"done");
			if (![self _checkCertificate]) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorCertificate userInfo:nil];
				[self setError:error];
				[error release];
                return;
            }
			
			LEPLog(@"init after starttls");
			r = mailsmtp_init(_smtp);
			if (r == MAILSMTP_ERROR_STREAM) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			else if (r != MAILSMTP_NO_ERROR) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
            
			break;
			
		case LEPAuthTypeTLS:
			r = mailsmtp_ssl_connect(_smtp, [[self host] UTF8String], [self port]);
			if (r != MAILSMTP_NO_ERROR) {
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
			
			LEPLog(@"init");
			r = mailsmtp_init(_smtp);
			if (r == MAILSMTP_ERROR_STREAM) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			else if (r != MAILSMTP_NO_ERROR) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			
			break;
			
		default:
			r = mailsmtp_socket_connect(_smtp, [[self host] UTF8String], [self port]);
			if (r != MAILIMAP_NO_ERROR) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			
			LEPLog(@"init");
			r = mailsmtp_init(_smtp);
			if (r == MAILSMTP_ERROR_STREAM) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			else if (r != MAILSMTP_NO_ERROR) {
				NSError * error;
				
				error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
				[self setError:error];
				[error release];
				return;
			}
			
			break;
    }
}

- (void) _login
{
	int r;
	
	if (([self login] == nil) || ([self password] == nil)) {
		return;
	}
	
    if (([self authType] & LEPAuthTypeMechanismMask) == 0) {
        if (_smtp->auth & MAILSMTP_AUTH_DIGEST_MD5) {
            [self setAuthType:[self authType] | LEPAuthTypeSASLDIGESTMD5];
        }
        else if (_smtp->auth & MAILSMTP_AUTH_CRAM_MD5) {
            [self setAuthType:[self authType] | LEPAuthTypeSASLCRAMMD5];
        }
        else if (_smtp->auth & MAILSMTP_AUTH_GSSAPI) {
            [self setAuthType:[self authType] | LEPAuthTypeSASLGSSAPI];
        }
        else if (_smtp->auth & MAILSMTP_AUTH_SRP) {
            [self setAuthType:[self authType] | LEPAuthTypeSASLSRP];
        }
        else if (_smtp->auth & MAILSMTP_AUTH_NTLM) {
            [self setAuthType:[self authType] | LEPAuthTypeSASLNTLM];
        }
        else if (_smtp->auth & MAILSMTP_AUTH_KERBEROS_V4) {
            [self setAuthType:[self authType] | LEPAuthTypeSASLKerberosV4];
        }
        else if (_smtp->auth & MAILSMTP_AUTH_PLAIN) {
            [self setAuthType:[self authType] | LEPAuthTypeSASLPlain];
        }
        else if (_smtp->auth & MAILSMTP_AUTH_LOGIN) {
            [self setAuthType:[self authType] | LEPAuthTypeSASLLogin];
        }
    }
    
	switch ([self authType] & LEPAuthTypeMechanismMask) {
        case 0:
		default:
			r = mailesmtp_auth_sasl(_smtp, "PLAIN",
									[[self host] UTF8String],
									NULL,
									NULL,
									[[self login] UTF8String], [[self login] UTF8String],
									[[self password] UTF8String], NULL);
			break;
			
		case LEPAuthTypeSASLCRAMMD5:
			r = mailesmtp_auth_sasl(_smtp, "CRAM-MD5",
									[[self host] UTF8String],
									NULL,
									NULL,
									[[self login] UTF8String], [[self login] UTF8String],
									[[self password] UTF8String], NULL);
			break;
			
		case LEPAuthTypeSASLPlain:
			r = mailesmtp_auth_sasl(_smtp, "PLAIN",
									[[self host] UTF8String],
									NULL,
									NULL,
									[[self login] UTF8String], [[self login] UTF8String],
									[[self password] UTF8String], NULL);
			break;
			
		case LEPAuthTypeSASLGSSAPI:
			// needs to be tested
			r = mailesmtp_auth_sasl(_smtp, "GSSAPI",
									[[self host] UTF8String],
									NULL,
									NULL,
									[[self login] UTF8String], [[self login] UTF8String],
									[[self password] UTF8String], [[self realm] UTF8String]);
			break;
			
		case LEPAuthTypeSASLDIGESTMD5:
			r = mailesmtp_auth_sasl(_smtp, "DIGEST-MD5",
									[[self host] UTF8String],
									NULL,
									NULL,
									[[self login] UTF8String], [[self login] UTF8String],
									[[self password] UTF8String], NULL);
			break;
			
		case LEPAuthTypeSASLLogin:
			r = mailesmtp_auth_sasl(_smtp, "LOGIN",
									[[self host] UTF8String],
									NULL,
									NULL,
									[[self login] UTF8String], [[self login] UTF8String],
									[[self password] UTF8String], NULL);
			break;
			
		case LEPAuthTypeSASLSRP:
			r = mailesmtp_auth_sasl(_smtp, "SRP",
									[[self host] UTF8String],
									NULL,
									NULL,
									[[self login] UTF8String], [[self login] UTF8String],
									[[self password] UTF8String], NULL);
			break;
			
		case LEPAuthTypeSASLNTLM:
			r = mailesmtp_auth_sasl(_smtp, "NTLM",
									[[self host] UTF8String],
									NULL,
									NULL,
									[[self login] UTF8String], [[self login] UTF8String],
									[[self password] UTF8String], [[self realm] UTF8String]);
			break;
			
		case LEPAuthTypeSASLKerberosV4:
			r = mailesmtp_auth_sasl(_smtp, "KERBEROS_V4",
									[[self host] UTF8String],
									NULL,
									NULL,
									[[self login] UTF8String], [[self login] UTF8String],
									[[self password] UTF8String], [[self realm] UTF8String]);
			break;
	}
    if (r == MAILSMTP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
    else if (r != MAILSMTP_NO_ERROR) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorAuthentication userInfo:nil];
        [self setError:error];
        [error release];
        return;
    }
}

- (void) _disconnect
{
    if (_smtp == NULL)
        return;
    
    mailsmtp_quit(_smtp);
}

- (void) _sendMessage:(NSData *)messageData from:(LEPAddress *)from recipient:(NSArray *)recipient
     progressDelegate:(id <LEPSMTPSessionProgressDelegate>)progressDelegate
{
	clist * address_list;
	int r;
	
    _currentProgressDelegate = progressDelegate;
    [_currentProgressDelegate retain];
    [self _progressWithCurrent:0 maximum:[messageData length]];
    
	LEPLog(@"setup");
	[self _setup];
	
	LEPLog(@"connect");
	[self _connect];
	if ([self error] != nil) {
		goto unsetup;
	}
	
	LEPLog(@"login");
	[self _login];
	if ([self error] != nil) {
        goto disconnect;
	}
	
	address_list = esmtp_address_list_new();
	for(LEPAddress * addr in recipient) {
		esmtp_address_list_add(address_list, (char *) [[addr mailbox] UTF8String], 0, NULL);
	}
	LEPLog(@"send");
	r = mailesmtp_send(_smtp, [[from mailbox] UTF8String], 0, NULL,
					   address_list,
					   [messageData bytes], [messageData length]);
	clist_free(address_list);
    if (r == MAILSMTP_ERROR_STREAM) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:nil];
        [self setError:error];
        [error release];
        goto disconnect;
    }
	else if (r == MAILSMTP_ERROR_EXCEED_STORAGE_ALLOCATION) {
        NSError * error;
        
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorStorageLimit userInfo:nil];
        [self setError:error];
        [error release];
        goto disconnect;
	}
    else if (r != MAILSMTP_NO_ERROR) {
        NSError * error;
		NSMutableDictionary * userInfo; 
		
		userInfo = [[NSMutableDictionary alloc] init];
		[userInfo setObject:[NSNumber numberWithInt:r] forKey:@"LibetpanError"];
        error = [[NSError alloc] initWithDomain:LEPErrorDomain code:LEPErrorConnection userInfo:userInfo];
        [self setError:error];
        [error release];
		[userInfo release];
        goto disconnect;
    }
	
#warning should disconnect only when there are no more requests
    
    [self _progressWithCurrent:[messageData length] maximum:[messageData length]];
    
    [_currentProgressDelegate release];
    _currentProgressDelegate = nil;
    
disconnect:
	LEPLog(@"disconnect");
	[self _disconnect];
unsetup:
	LEPLog(@"unsetup");
	[self _unsetup];
}

- (void) _progressWithCurrent:(size_t)current maximum:(size_t)maximum
{
    if (current > maximum) {
        current = maximum;
    }
    
    if (_currentProgressDelegate != nil) {
        NSMutableDictionary * info;
        
        info = [[NSMutableDictionary alloc] init];
        [info setObject:_currentProgressDelegate forKey:@"Delegate"];
        [info setObject:[NSNumber numberWithLongLong:current] forKey:@"Current"];
        [info setObject:[NSNumber numberWithLongLong:maximum] forKey:@"Maximum"];
        
        [self performSelectorOnMainThread:@selector(_progressOnMainThread:) withObject:info waitUntilDone:NO];
        
        [info release];
    }
}

- (void) _progressOnMainThread:(NSDictionary *)info
{
    id <LEPSMTPSessionProgressDelegate> delegate;
    size_t current;
    size_t maximum;
    
    delegate = [info objectForKey:@"Delegate"];
    current = [[info objectForKey:@"Current"] longLongValue];
    maximum = [[info objectForKey:@"Maximum"] longLongValue];
    LEPLog(@"smtp body progress %u %u", current, maximum);
    
    [delegate LEPSMTPSession:self progressWithCurrent:current maximum:maximum];
}

- (LEPAuthType) _checkConnection
{
	if (([self login] == nil) || ([self password] == nil)) {
        [self _setup];
        [self _connect];
        if ([self error] != nil) {
            [self _unsetup];
            return 0;
        }
        
        [self _disconnect];
        [self _unsetup];
        return 0;
    }
    
    int lepSmtpAuth[] = {MAILSMTP_AUTH_DIGEST_MD5, MAILSMTP_AUTH_CRAM_MD5, MAILSMTP_AUTH_PLAIN,
        MAILSMTP_AUTH_LOGIN, MAILSMTP_AUTH_SRP, MAILSMTP_AUTH_NTLM,
        MAILSMTP_AUTH_GSSAPI, MAILSMTP_AUTH_KERBEROS_V4};
    int smtpAuth[] = {LEPAuthTypeSASLDIGESTMD5, LEPAuthTypeSASLCRAMMD5, LEPAuthTypeSASLPlain,
        LEPAuthTypeSASLLogin, LEPAuthTypeSASLSRP, LEPAuthTypeSASLNTLM,
        LEPAuthTypeSASLGSSAPI, LEPAuthTypeSASLKerberosV4};
    
    LEPLog(@"setup");
    [self _setup];
    
    LEPLog(@"connect");
    [self _connect];
    if ([self error] != nil) {
        [self _unsetup];
        return 0;
    }
    
    for(unsigned int i = 0 ; i < sizeof(lepSmtpAuth) / sizeof(lepSmtpAuth[0]) ; i ++) {
        if ((_smtp->auth & lepSmtpAuth[i]) == 0) {
            continue;
        }
        
        LEPLog(@"login");
        [self setError:nil];
        
        [self setAuthType:[self authType] & ~LEPAuthTypeMechanismMask];
        [self setAuthType:[self authType] | smtpAuth[i]];
        
        [self _login];
        if ([self error] != nil) {
            if ([[[self error] domain] isEqualToString:LEPErrorDomain] &&
                (([[self error] code] == LEPErrorConnection)) || ([[self error] code] == LEPErrorParse)) {
                // disconnect
                [self _disconnect];
                [self _unsetup];
                
                // then, retry
                [self _setup];
                [self _connect];
                if ([self error] != nil) {
                    [self _unsetup];
                    break;
                }
                [self _login];
            }
        }
        
        if ([self error] == nil) {
            [self _disconnect];
            [self _unsetup];
            return smtpAuth[i];
        }
    }
    [self _disconnect];
    [self _unsetup];
    
    return 0;
}

@end
