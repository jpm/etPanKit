//
//  LEPAbstractAttachment.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPAbstractAttachment.h"
#import "LEPUtils.h"

@implementation LEPAbstractAttachment

@synthesize filename = _filename;
@synthesize mimeType = _mimeType;
@synthesize inlineAttachment = _inlineAttachment;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
	[_filename release];
	[_mimeType release];
	[super dealloc];
}

@end
