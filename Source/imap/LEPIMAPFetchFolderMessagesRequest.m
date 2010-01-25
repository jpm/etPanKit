//
//  LEPIMAPFetchFolderMessagesRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 20/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPFetchFolderMessagesRequest.h"

@implementation LEPIMAPFetchFolderMessagesRequest

@synthesize fromUID = _fromUID;
@synthesize toUID = _toUID;
@synthesize messages = _messages;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
    [_messages release];
	[super dealloc];
}

@end
