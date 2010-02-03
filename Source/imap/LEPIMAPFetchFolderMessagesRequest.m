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
@synthesize folder = _folder;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
    [_messages release];
    [_path release];
	[_folder release];
	[super dealloc];
}

- (void) mainRequest
{
	_messages = [[_session _fetchFolderMessages:_path fromUID:_fromUID toUID:_toUID kind:_fetchKind folder:_folder] retain];
}

@end
