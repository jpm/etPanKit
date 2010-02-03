//
//  LEPIMAPMessage.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPMessage.h"

@interface LEPIMAPMessage ()

@end

@implementation LEPIMAPMessage

@synthesize flags = _flags;
@synthesize uid = _uid;
@synthesize folder = _folder;
@synthesize attachments = _attachments;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
	[_attachments release];
    [_folder release];
	[super dealloc];
}

- (void) _setUid:(uint32_t)uid
{
	_uid = uid;
}

- (void) _setFlags:(LEPIMAPMessageFlag)flags
{
	_flags = flags;
}

- (void) _setFolder:(LEPIMAPFolder *)folder
{
    [_folder release];
    _folder = [folder retain];
}

- (LEPIMAPFetchMessageStructureRequest *) fetchMessageStructureRequest;
{
#warning should be implemented
    return nil;
}

- (LEPIMAPFetchMessageRequest *) fetchMessageRequest;
{
#warning should be implemented
    return nil;
}

@end
