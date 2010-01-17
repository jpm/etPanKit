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

@synthesize messageID = _messageID;
@synthesize reference = _reference;
@synthesize inReplyTo = _inReplyTo;
@synthesize from = _from;
@synthesize to = _to;
@synthesize cc = _cc;
@synthesize bcc = _bcc;
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
	[super dealloc];
}

- (void) parseData:(NSData *)data
{
#warning should be implemented
}

- (void) parseString:(NSString *)stringValue
{
#warning should be implemented
}

- (NSString *) stringValue
{
	return [[self data] LEPUTF8String];
}

- (NSData *) data
{
#warning should be implemented
	return nil;
}

@end
