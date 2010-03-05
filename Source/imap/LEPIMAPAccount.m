//
//  LEPIMAPAccount.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPAccount.h"

#import "LEPIMAPSession.h"
#import "LEPUtils.h"
#import "LEPIMAPFetchSubscribedFoldersRequest.h"
#import "LEPIMAPFetchAllFoldersRequest.h"
#import "LEPIMAPCreateFolderRequest.h"
#import "LEPError.h"
#import "LEPIMAPFolder.h"
#import "LEPIMAPFolderPrivate.h"

@interface LEPIMAPAccount ()

- (void) _setupRequest:(LEPIMAPRequest *)request;

@end

@implementation LEPIMAPAccount

@synthesize host = _host;
@synthesize port = _port;
@synthesize login = _login;
@synthesize password = _password;
@synthesize authType = _authType;
@synthesize realm = _realm;

@synthesize idleEnabled = _idleEnabled;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
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
	LEPLog(@"setup session");
	LEPAssert(_session == nil);
	
	_session = [[LEPIMAPSession alloc] init];
	[_session setHost:[self host]];
	[_session setPort:[self port]];
	[_session setLogin:[self login]];
	[_session setPassword:[self password]];
	[_session setAuthType:[self authType]];
	[_session setRealm:[self realm]];
}

- (void) _unsetupSession
{
	LEPLog(@"unsetup session");
	[_session release];
	_session = nil;
}

- (void) _setupRequest:(LEPIMAPRequest *)request
{
    if (_session == nil) {
        [self _setupSession];
    }
    
    [request setSession:_session];
    
	if ([_session error] != nil) {
		if (([[_session error] code] == LEPErrorConnection) || ([[_session error] code] == LEPErrorParse)) {
			[self _unsetupSession];
		}
	}
}

- (LEPIMAPSession *) _session
{
    return _session;
}

- (LEPIMAPFolder *) inboxFolder
{
	LEPIMAPFolder * folder;
	
	folder = [[LEPIMAPFolder alloc] init];
	[folder _setPath:@"INBOX"];
	[folder _setAccount:self];
	
	return [folder autorelease];
}

- (void) _setGmailMailboxNames:(NSDictionary *)gmailMailboxNames
{
    [_gmailMailboxNames release];
    _gmailMailboxNames = [gmailMailboxNames retain];
}

@end
