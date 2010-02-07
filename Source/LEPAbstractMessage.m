//
//  LEPAbstractMessage.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPAbstractMessage.h"
#import "LEPMessageHeader.h"
#import "LEPUtils.h"

@implementation LEPAbstractMessage

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

- (NSString *) description
{
	return [NSString stringWithFormat:@"<%@: 0x%p %@ %@>", [self class], self, [[self header] from], [[self header] subject]];
}

@end
