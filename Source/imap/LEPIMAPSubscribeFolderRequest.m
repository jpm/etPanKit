//
//  LEPIMAPSubscribeFolderRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 20/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPSubscribeFolderRequest.h"
#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"

@implementation LEPIMAPSubscribeFolderRequest

@synthesize path = _path;

- (id) init
{
	self = [super init];
	
	return self;
}

- (void) dealloc
{
    [_path release];
	[super dealloc];
}

- (void) mainRequest
{
	[_session _subscribeFolder:_path];
}

@end
