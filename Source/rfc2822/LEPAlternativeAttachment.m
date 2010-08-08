//
//  LEPAlternativeAttachment.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPAlternativeAttachment.h"


@implementation LEPAlternativeAttachment

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
}

- (id) copyWithZone:(NSZone *)zone
{
	LEPAlternativeAttachment * aCopy;
	
	aCopy = [super copyWithZone:zone];
	
	return aCopy;
}

@end
