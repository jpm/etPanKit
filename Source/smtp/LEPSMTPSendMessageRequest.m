//
//  LEPSMTPSendMessageRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 02/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPSMTPSendMessageRequest.h"

#import "LEPAddress.h"
#import "LEPSMTPSession.h"
#import "LEPSMTPSessionPrivate.h"
#import "LEPUtils.h"

@implementation LEPSMTPSendMessageRequest

@synthesize messageData = _messageData;
@synthesize from = _from;
@synthesize recipient = _recipient;

- (id) init
{
	self = [super init];
	
	return self;
}

- (void) dealloc
{
	[_messageData release];
	[_from release];
	[_recipient release];
	[super dealloc];
}

- (void) mainRequest
{
	LEPLog(@"smtp request");
	[_session _sendMessage:_messageData from:_from recipient:_recipient];
}

@end
