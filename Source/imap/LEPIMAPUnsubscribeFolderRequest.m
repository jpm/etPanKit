//
//  LEPIMAPUnsubscribeFolderRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 20/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPUnsubscribeFolderRequest.h"
#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"

@implementation LEPIMAPUnsubscribeFolderRequest

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
	[_session _unsubscribeFolder:_path];
}

@end
