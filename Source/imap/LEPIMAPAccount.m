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
#import "LEPError.h"

@interface LEPIMAPAccount ()

@property (nonatomic, retain) NSArray * subscribedFolders;
@property (nonatomic, retain) NSArray * allFolders;

- (void) _setupRequest:(LEPIMAPRequest *)request;

@end

@implementation LEPIMAPAccount

@synthesize host = _host;
@synthesize port = _port;
@synthesize login = _login;
@synthesize password = _password;
@synthesize authType = _authType;
@synthesize realm = _realm;

@synthesize subscribedFolders = _subscribedFolders;
@synthesize allFolders = _allFolders;

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
    [_subscribedFolders release];
    [_allFolders release];
	[super dealloc];
}

- (LEPIMAPRequest *) fetchSubscribedFoldersRequest
{
	LEPIMAPFetchSubscribedFoldersRequest * request;
	
	request = [[LEPIMAPFetchSubscribedFoldersRequest alloc] init];
	[request setAccount:self];
	
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPRequest *) fetchAllFoldersRequest
{
	LEPIMAPFetchAllFoldersRequest * request;
	
	request = [[LEPIMAPFetchAllFoldersRequest alloc] init];
	[request setAccount:self];
    
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPRequest *) createFolderRequest:(NSString *)name
{
#warning should be implemented
    return nil;
}

- (void) _setupSession
{
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
	[_session release];
	_session = nil;
}

- (void) _setupRequest:(LEPIMAPRequest *)request
{
    if (_session == nil) {
        [self _setupSession];
    }
    
    [request setSession:_session];
    
    if (([[_session error] code] == LEPErrorConnection) || ([[_session error] code] == LEPErrorParse)) {
        [self _unsetupSession];
    }
}

- (void) _setSubscribedFolders:(NSArray * )folders
{
	[_subscribedFolders release];
	_subscribedFolders = [folders retain];
}

- (void) _setAllFolders:(NSArray * )folders
{
	[_allFolders release];
	_allFolders = [folders retain];
}

@end
