//
//  LEPAbstractMessageAttachment.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPAbstractMessageAttachment.h"

#import "LEPMessageHeader.h"

@implementation LEPAbstractMessageAttachment

@synthesize header = _header;
@synthesize attachments = _attachments;

- (id) init
{
	self = [super init];
	
	_header = [[LEPMessageHeader alloc] init];
	
	return self;
}

- (void) dealloc
{
	[_attachments release];
	[_header release];
	[super dealloc];
}

- (void) setMessage:(LEPAbstractMessage *)message
{
	_message = message;
	for(LEPAbstractAttachment * attachment in _attachments) {
		[attachment setMessage:message];
	}
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	
	_attachments = [[decoder decodeObjectForKey:@"attachments"] retain];
	_header = [[decoder decodeObjectForKey:@"header"] retain];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_attachments forKey:@"attachments"];
	[encoder encodeObject:_header forKey:@"header"];
}

#if 0
- (id) copyWithZone:(NSZone *)zone
{
    LEPAbstractMessageAttachment * attachment;
    
    attachment = [super copyWithZone:zone];
    [attachment->_header release];
    attachment->_header = [self->_header retain];
    
    
}
#endif
    
@end
