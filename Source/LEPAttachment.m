//
//  LEPAttachment.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPAttachment.h"

@implementation LEPAttachment

@synthesize filename = _filename;
@synthesize mimeType = _mimeType;
@synthesize data = _data;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
    [_filename release];
    [_mimeType release];
    [_data release];
	[super dealloc];
}

@end
