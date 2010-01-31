//
//  LEPAbstractMessageAttachment.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPAbstractMessageAttachment.h"

#import "LEPMessageHeader.h"

@implementation LEPAbstractMessageAttachment

@synthesize header = _header;

- (id) init
{
	self = [super init];
	
	_header = [[LEPMessageHeader alloc] init];
	
	return self;
}

- (void) dealloc
{
	[_header release];
	[super dealloc];
}

@end
