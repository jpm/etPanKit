//
//  LEPIMAPStoreFlagsRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 20/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPStoreFlagsRequest.h"
#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"

@implementation LEPIMAPStoreFlagsRequest

@synthesize path = _path;
@synthesize uids = _uids;
@synthesize kind = _kind;
@synthesize flags = _flags;

- (id) init
{
	self = [super init];
	
	return self;
}

- (void) dealloc
{
	[_uids release];
    [_path release];
	[super dealloc];
}

- (void) mainRequest
{
	[_session _storeFlags:_flags kind:_kind messagesUids:_uids path:_path];
}

@end
