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

@interface LEPIMAPAccount ()

@property (nonatomic, copy) NSArray * subscribedFolders;
@property (nonatomic, copy) NSArray * allFolders;

@end

@implementation LEPIMAPAccount

@synthesize host = _host;
@synthesize port = _port;
@synthesize login = _login;
@synthesize password = _password;
@synthesize authType = _authType;

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
    [_host release];
    [_login release];
    [_password release];
    [_subscribedFolders release];
    [_allFolders release];
	[super dealloc];
}

- (LEPIMAPRequest *) fetchSubscribedFoldersRequest
{
#warning should be implemented
    return nil;
}

- (LEPIMAPRequest *) fetchAllFoldersRequest
{
#warning should be implemented
    return nil;
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
}

- (void) _unsetupSession
{
	[_session release];
	_session = nil;
}

@end
