//
//  LEPIMAPAccount.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPAccount.h"
#import "LEPIMAPAccount+Gmail.h"

#import "LEPIMAPSession.h"
#import "LEPUtils.h"
#import "LEPIMAPFetchSubscribedFoldersRequest.h"
#import "LEPIMAPFetchAllFoldersRequest.h"
#import "LEPIMAPCreateFolderRequest.h"
#import "LEPError.h"
#import "LEPIMAPFolder.h"
#import "LEPIMAPFolderPrivate.h"
#import <libetpan/libetpan.h>

@interface LEPIMAPAccount ()

- (void) _setupRequest:(LEPIMAPRequest *)request;
- (void) _setupSession;
- (void) _unsetupSession;

@end

@implementation LEPIMAPAccount

@synthesize host = _host;
@synthesize port = _port;
@synthesize login = _login;
@synthesize password = _password;
@synthesize authType = _authType;
@synthesize realm = _realm;
@synthesize sessionsCount = _sessionsCount;

@synthesize idleEnabled = _idleEnabled;

+ (void) setTimeoutDelay:(NSTimeInterval)timeout
{
    mailstream_network_delay.tv_sec = (time_t) timeout;
    mailstream_network_delay.tv_usec = (suseconds_t) (timeout - mailstream_network_delay.tv_sec) * 1000000;
}

+ (NSTimeInterval) timeoutDelay
{
    return (NSTimeInterval) mailstream_network_delay.tv_sec + ((NSTimeInterval) mailstream_network_delay.tv_usec) / 1000000.;
}

- (id) init
{
    NSMutableDictionary * mailboxes;
    
	self = [super init];
	
    mailboxes = [[NSMutableDictionary alloc] init];
    [mailboxes setObject:@"[Google Mail]/All Mail" forKey:@"allmail"];
    [mailboxes setObject:@"[Google Mail]/Drafts" forKey:@"drafts"];
    [mailboxes setObject:@"[Google Mail]/Sent Mail" forKey:@"sentmail"];
    [mailboxes setObject:@"[Google Mail]/Spam" forKey:@"spam"];
    [mailboxes setObject:@"[Google Mail]/Starred" forKey:@"starred"];
    [mailboxes setObject:@"[Google Mail]/Trash" forKey:@"trash"];
    [self setGmailMailboxNames:mailboxes];
    [mailboxes release];
    
    _sessionsCount = 1;
    
	return self;
} 

- (void) dealloc
{
    for(LEPIMAPSession * session in _sessions) {
        [session logout];
    }
    [self _unsetupSession];
	[_realm release];
    [_host release];
    [_login release];
    [_password release];
	[super dealloc];
}

- (LEPIMAPFetchFoldersRequest *) fetchSubscribedFoldersRequest
{
	LEPIMAPFetchSubscribedFoldersRequest * request;
	
	request = [[LEPIMAPFetchSubscribedFoldersRequest alloc] init];
	[request setAccount:self];
	
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPFetchFoldersRequest *) fetchAllFoldersRequest
{
	LEPIMAPFetchAllFoldersRequest * request;
	
	request = [[LEPIMAPFetchAllFoldersRequest alloc] init];
	[request setAccount:self];
    
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPRequest *) createFolderRequest:(NSString *)path
{
	LEPIMAPCreateFolderRequest * request;
	
	request = [[LEPIMAPCreateFolderRequest alloc] init];
    [request setPath:path];
    
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (void) _setupSession
{
#if 0
	LEPLog(@"setup session");
	LEPAssert(_session == nil);
	
	_session = [[LEPIMAPSession alloc] init];
	[_session setHost:[self host]];
	[_session setPort:[self port]];
	[_session setLogin:[self login]];
	[_session setPassword:[self password]];
	[_session setAuthType:[self authType]];
	[_session setRealm:[self realm]];
#else
	LEPLog(@"setup session");
	LEPAssert(_sessions == nil);
    
    _sessions = [[NSMutableArray alloc] init];
    for(unsigned int i = 0 ; i < _sessionsCount ; i ++) {
        LEPIMAPSession * session;
        
        session = [[LEPIMAPSession alloc] init];
        [session setHost:[self host]];
        [session setPort:[self port]];
        [session setLogin:[self login]];
        [session setPassword:[self password]];
        [session setAuthType:[self authType]];
        [session setRealm:[self realm]];
        [_sessions addObject:session];
        [session release];
    }
#endif
}

- (void) _unsetupSession
{
#if 0
	LEPLog(@"unsetup session");
	[_session release];
	_session = nil;
#else
    [_sessions release];
    _sessions = nil;
#endif
}

- (void) _removeSession:(LEPIMAPSession *)session
{
    [session logout];
    [_sessions removeObject:session];
}

- (void) _setupRequest:(LEPIMAPRequest *)request
{
#if 0
    if (_session == nil) {
        [self _setupSession];
    }
#else
    if (_sessions == nil) {
        [self _setupSession];
    }
#endif
    
    LEPIMAPSession * session;
    unsigned int lowestPending;
    
    session = nil;
    lowestPending = 0;
    for(LEPIMAPSession * currentSession in _sessions) {
        if (session == nil) {
            session = currentSession;
            lowestPending = [session pendingRequestsCount];
        }
        else if ([currentSession pendingRequestsCount] < lowestPending) {
            session = currentSession;
            lowestPending = [session pendingRequestsCount];
        }
    }
    
    [request setSession:session];
    
	if ([session error] != nil) {
		if (([[session error] code] == LEPErrorConnection) || ([[session error] code] == LEPErrorParse)) {
			[self _removeSession:session];
		}
	}
}

- (LEPIMAPFolder *) inboxFolder
{
	LEPIMAPFolder * folder;
	
	folder = [[LEPIMAPFolder alloc] init];
	[folder _setPath:@"INBOX"];
	[folder _setAccount:self];
	
	return [folder autorelease];
}

@end
