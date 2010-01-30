//
//  LEPIMAPFetchFolderMessagesRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 20/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPFetchFolderMessagesRequest.h"

#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"

@implementation LEPIMAPFetchFolderMessagesRequest

@synthesize path = _path;
@synthesize fromUID = _fromUID;
@synthesize toUID = _toUID;
@synthesize messages = _messages;
@synthesize fetchKind = _fetchKind;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
    [_messages release];
    [_path release];
	[super dealloc];
}

- (void) mainRequest
{
	_messages = [[_session _fetchFolderMessages:_path fromUID:_fromUID toUID:_toUID kind:_fetchKind] retain];
}

@end
