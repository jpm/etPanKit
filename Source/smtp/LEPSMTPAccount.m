//
//  LEPSMTPAccount.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 04/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPSMTPAccount.h"

#import "LEPUtils.h"
#import "LEPSMTPSession.h"
#import "LEPSMTPRequest.h"
#import "LEPError.h"
#import "LEPSMTPSendMessageRequest.h"
#import "LEPMessage.h"
#import "LEPMessageHeader.h"
#import "LEPSMTPCheckRequest.h"

@implementation LEPSMTPAccount

@synthesize host = _host;
@synthesize port = _port;
@synthesize login = _login;
@synthesize password = _password;
@synthesize authType = _authType;
@synthesize realm = _realm;
@synthesize checkCertificate = _checkCertificate;

- (id) init
{
	self = [super init];
	_checkCertificate = YES;
    
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

- (void) _setupSession
{
	LEPAssert(_session == nil);
	
	LEPLog(@"setup session");
	_session = [[LEPSMTPSession alloc] init];
	[_session setHost:[self host]];
	[_session setPort:[self port]];
	[_session setLogin:[self login]];
	[_session setPassword:[self password]];
	[_session setAuthType:[self authType]];
	[_session setRealm:[self realm]];
    [_session setCheckCertificate:[self checkCertificate]];
}

- (void) _unsetupSession
{
	[_session release];
	_session = nil;
}

- (void) _setupRequest:(LEPSMTPRequest *)request
{
	LEPLog(@"setup request 1");
    if (_session == nil) {
        [self _setupSession];
    }
    
	LEPLog(@"setup request 2");
    [request setSession:_session];
    
    if ([[[_session error] domain] isEqualToString:LEPErrorDomain]) {
        if (([[_session error] code] == LEPErrorConnection) || ([[_session error] code] == LEPErrorParse)) {
            LEPLog(@"setup request 3");
            [self _unsetupSession];
        }
    }
    LEPLog(@"setup request 4");
}

- (LEPSMTPRequest *) sendRequest:(LEPMessage *)message
{
	LEPSMTPSendMessageRequest * request;
	NSMutableArray * recipient;
	
	request = [[LEPSMTPSendMessageRequest alloc] init];
	
	[request setMessageData:[message dataForSending:YES]];
	[request setFrom:[[message header] from]];
	
	recipient = [[NSMutableArray alloc] init];
	[recipient addObjectsFromArray:[[message header] to]];
	[recipient addObjectsFromArray:[[message header] cc]];
	[recipient addObjectsFromArray:[[message header] bcc]];
	[request setRecipient:recipient];
	[recipient release];
	
    [self _setupRequest:request];
	
	return [request autorelease];
}

- (LEPSMTPRequest *) checkConnectionRequest
{
	LEPSMTPCheckRequest * request;
	
	request = [[LEPSMTPCheckRequest alloc] init];
	
    [self _setupRequest:request];
	
	return [request autorelease];
}

@end
