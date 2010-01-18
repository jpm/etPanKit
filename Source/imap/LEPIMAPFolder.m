//
//  LEPIMAPFolder.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPFolder.h"

@implementation LEPIMAPFolder

@synthesize account = _account;
@synthesize uidValidity = _uidValidity;
@synthesize path = _path;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
    [_uidValidity release];
    [_path release];
	[super dealloc];
}

- (void) _setDelimiter:(char)delimiter
{
	_delimiter = delimiter;
}

- (void) _setPath:(NSString *)path
{
    [_path release];
    _path = [path copy];
}

- (void) _setFlags:(int)flags
{
    _flags = flags;
}

- (NSArray *) pathComponents
{
#warning should be implemented
    return nil;
}

- (LEPIMAPRequest *) createFolderRequest:(NSString *)name
{
#warning should be implemented
    return nil;
}

- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequest
{
#warning should be implemented
    return nil;
}

- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequestFromSequenceNumber:(uint32_t)sequenceNumber
{
#warning should be implemented
    return nil;
}

- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequestFromUID:(uint32_t)uid
{
#warning should be implemented
    return nil;
}

- (LEPIMAPRequest *) appendMessageRequest:(LEPAbstractMessage *)message
{
#warning should be implemented
    return nil;
}

- (LEPIMAPRequest *) appendMessagesRequest:(NSArray * /* LEPAbstractMessage */)message
{
#warning should be implemented
    return nil;
}

- (LEPIMAPRequest *) deleteRequest
{
#warning should be implemented
    return nil;
}

- (LEPIMAPRequest *) subscribeRequest
{
#warning should be implemented
    return nil;
}

- (LEPIMAPRequest *) unsubscribeRequest
{
#warning should be implemented
    return nil;
}

@end

@implementation LEPIMAPFetchFolderMessagesRequest

@synthesize messages = _messages;

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
