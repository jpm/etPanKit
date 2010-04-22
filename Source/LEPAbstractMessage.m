//
//  LEPAbstractMessage.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPAbstractMessage.h"
#import "LEPMessageHeader.h"
#import "LEPMessageHeaderPrivate.h"
#import "LEPUtils.h"
#import "LEPAbstractAttachment.h"

@interface LEPAbstractMessage ()

- (id) _initForCopy;

@end

@implementation LEPAbstractMessage

@synthesize header = _header;

- (id) init
{
	self = [super init];
	
	_header = [[LEPMessageHeader alloc] init];
	
	return self;
} 

- (id) _initForCopy
{
	self = [super init];
	
	_header = [[LEPMessageHeader alloc] _initForCopy];
	
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

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	
	_header = [[decoder decodeObjectForKey:@"header"] retain];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_header forKey:@"header"];
}

- (id) copyWithZone:(NSZone *)zone
{
    LEPAbstractMessage * message;
    
    message = [[[self class] alloc] _initForCopy];
    
    [message->_header release];
    message->_header = [[self header] retain];
    
    return message;
}

@end
