//
//  LEPIMAPAttachment.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPAttachment.h"

@implementation LEPIMAPAttachment

@synthesize filename = _filename;
@synthesize mimeType = _mimeType;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
	[super dealloc];
}

- (LEPIMAPFetchAttachmentRequest *) fetchRequest
{
#warning should be implemented
    return nil;
}

@end

@implementation LEPIMAPFetchAttachmentRequest

@synthesize data = _data;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
	[super dealloc];
}

@end
