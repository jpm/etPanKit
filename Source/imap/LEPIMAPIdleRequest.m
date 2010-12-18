//
//  LEPIMAPIdleRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 11/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPIdleRequest.h"
#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"

@implementation LEPIMAPIdleRequest

@synthesize path = _path;
@synthesize lastUID = _lastUID;

- (id) init
{
	self = [super init];
	
    _lastUID = -1;
    
	return self;
}

- (void) dealloc
{
    [_path release];
	[super dealloc];
}

- (void) startRequest
{
    [_session _idlePrepare];
    [super startRequest];
}

- (void) mainRequest
{
	[_session _idlePath:_path lastUID:_lastUID];
}

- (void) mainFinished
{
}

- (void) done
{
    [_session _idleDone];
    [_session _idleUnprepare];
}

@end
