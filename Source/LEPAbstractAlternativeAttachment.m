//
//  LEPAbstractAlternativeAttachment.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPAbstractAlternativeAttachment.h"

@implementation LEPAbstractAlternativeAttachment

@synthesize attachments = _attachments;

- (id) init
{
	self = [super init];
	
	return self;
}

- (void) dealloc
{
	[_attachments release];
	[super dealloc];
}

@end
