//
//  LEPIMAPFetchFolderMessagesUIDRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 25/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPFetchFolderMessagesUIDRequest.h"


@implementation LEPIMAPFetchFolderMessagesUIDRequest

@synthesize fromUID = _fromUID;
@synthesize toUID = _toUID;
@synthesize messagesUIDs = _messagesUIDs;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
    [_messagesUIDs release];
	[super dealloc];
}

@end
