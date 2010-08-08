//
//  LEPIMAPAlternativeAttachment.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPAlternativeAttachment.h"


@implementation LEPIMAPAlternativeAttachment

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
	LEPIMAPAlternativeAttachment * aCopy;
	
	aCopy = [super copyWithZone:zone];
	
	return aCopy;
}

@end
