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
@synthesize charset = _charset;
@synthesize inlineAttachment = _inlineAttachment;
@synthesize message = _message;
@synthesize contentID = _contentID;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
    [_contentID release];
	[_charset release];
	[_filename release];
	[_mimeType release];
	[super dealloc];
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"<%@: 0x%p %@ %@>", [self class], self, [self mimeType], [self filename]];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	
    _filename = [[decoder decodeObjectForKey:@"filename"] retain];
    _mimeType = [[decoder decodeObjectForKey:@"mimeType"] retain];
	_charset = [[decoder decodeObjectForKey:@"charset"] retain];
	_inlineAttachment = [decoder decodeBoolForKey:@"inlineAttachment"];
	_contentID = [[decoder decodeObjectForKey:@"contentID"] retain];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_filename forKey:@"filename"];
	[encoder encodeObject:_mimeType forKey:@"mimeType"];
	[encoder encodeObject:_charset forKey:@"charset"];
	[encoder encodeBool:_inlineAttachment forKey:@"inlineAttachment"];
    [encoder encodeObject:_contentID forKey:@"contentID"];
}

@end
