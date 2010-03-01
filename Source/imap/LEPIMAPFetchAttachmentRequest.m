//
//  LEPIMAPFetchAttachmentRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPFetchAttachmentRequest.h"

#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"
#import "LEPUtils.h"

@implementation LEPIMAPFetchAttachmentRequest

@synthesize data = _data;
@synthesize path = _path;
@synthesize partID = _partID;
@synthesize uid = _uid;
@synthesize encoding = _encoding;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
	[_data release];
	[_path release];
	[_partID release];
	[super dealloc];
}

- (void) mainRequest
{
	LEPLog(@"fetch %@ %u", _partID, _uid);
	_data = [[_session _fetchAttachmentWithPartID:_partID UID:_uid path:_path encoding:_encoding] retain];
	LEPLog(@"fetch -> %p %u", _data, [_data length]);
}

@end
