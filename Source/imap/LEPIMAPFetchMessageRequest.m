//
//  LEPIMAPFetchMessageRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPFetchMessageRequest.h"

#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"

@implementation LEPIMAPFetchMessageRequest

@synthesize uid = _uid;
@synthesize path = _path;
@synthesize messageData = _messageData;

- (id) init
{
	self = [super init];
	
	return self;
}

- (void) dealloc
{
	[_messageData release];
	[_path release];
	[super dealloc];
}

- (void) mainRequest
{
	_messageData = [[_session _fetchMessageWithUID:_uid path:_path] retain];
}

@end
