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

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
    [_folder release];
	[super dealloc];
}

- (void) _setUid:(uint32_t)uid
{
}

- (void) _setFlags:(LEPIMAPMessageFlag)flags
{
}

- (void) _setFolder:(LEPIMAPFolder *)folder
{
    [_folder release];
    _folder = [folder retain];
}

- (LEPIMAPFetchMessageRequest *) fetchRequest
{
#warning should be implemented
    return nil;
}

- (LEPIMAPFetchMessageBodyRequest *) fetchMessageBodyRequest
{
#warning should be implemented
    return nil;
}

@end
