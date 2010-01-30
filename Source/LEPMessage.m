//
//  LEPMessage.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPMessage.h"
#import "NSData+LEPUTF8.h"

@implementation LEPMessage

@synthesize date = _date;
@synthesize messageID = _messageID;
@synthesize references = _references;
@synthesize inReplyTo = _inReplyTo;
@synthesize from = _from;
@synthesize to = _to;
@synthesize cc = _cc;
@synthesize bcc = _bcc;
@synthesize replyTo = _replyTo;
@synthesize subject = _subject;
@synthesize body = _body;
@synthesize attachments = _attachments;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
	[_messageID release];
	[_references release];
	[_inReplyTo release];
	[_from release];
	[_to release];
	[_cc release];
	[_bcc release];
    [_replyTo release];
	[_subject release];
	[_body release];
	[_attachments release];
    [_date release];
    
	[super dealloc];
}

- (void) parseData:(NSData *)data
{
#warning should be implemented
}

- (NSData *) data
{
#warning should be implemented
	return nil;
}

@end
