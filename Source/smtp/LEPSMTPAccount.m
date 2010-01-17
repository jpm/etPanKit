//
//  LEPSMTPAccount.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 04/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPSMTPAccount.h"


@implementation LEPSMTPAccount

@synthesize host = _host;
@synthesize port = _port;
@synthesize login = _login;
@synthesize password = _password;
@synthesize authType = _authType;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
	[super dealloc];
}

- (LEPSMTPRequest *) sendRequest:(LEPMessage *)message
{
#warning should be implemented
	return nil;
}

@end
