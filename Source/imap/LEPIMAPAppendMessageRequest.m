//
//  LEPIMAPAppendMessageRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 22/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPAppendMessageRequest.h"
#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"

@implementation LEPIMAPAppendMessageRequest

@synthesize data = _data;
@synthesize path = _path;
@synthesize flags = _flags;

- (id) init
{
	self = [super init];
	
    _flags = LEPIMAPMessageFlagSeen;
    
	return self;
}

- (void) dealloc
{
    [_data release];
    [_path release];
	[super dealloc];
}

- (void) mainRequest
{
	[_session _appendMessageData:_data flags:_flags toPath:_path];
}

@end
