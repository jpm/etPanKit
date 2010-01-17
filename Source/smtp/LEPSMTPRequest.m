//
//  LEPSMTPRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 05/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPSMTPRequest.h"

@implementation LEPSMTPRequest

@synthesize delegate = _delegate;
@synthesize error = _error;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
	[super dealloc];
}

- (void) startRequest
{
#warning should be implemented
}

- (void) cancel
{
#warning should be implemented
}

@end
