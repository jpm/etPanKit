//
//  LEPSMTPSession.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 06/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPSMTPSession.h"


@implementation LEPSMTPSession

- (id) init
{
	self = [super init];
	
	_queue = [[NSOperationQueue alloc] init];
	[_queue setMaxConcurrentOperationCount:1];
	
	return self;
}

- (void) dealloc
{
	[_queue release];
	[_error release];
	
	[super dealloc];
}

- (void) queueOperation:(LEPSMTPRequest *)request
{
#warning needs to be implemented
}

@end
