//
//  LEPIMAPFolder.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPFolder.h"
#import "LEPIMAPFolderPrivate.h"

#import "LEPIMAPAccount.h"
#import "LEPIMAPAccountPrivate.h"
#import "LEPIMAPRenameFolderRequest.h"
#import "LEPIMAPDeleteFolderRequest.h"
#import "LEPIMAPSubscribeFolderRequest.h"
#import "LEPIMAPUnsubscribeFolderRequest.h"
#import "LEPIMAPAppendMessageRequest.h"
#import "LEPIMAPCopyMessageRequest.h"
#import "LEPIMAPMessage.h"
#import "LEPMessage.h"
#import "LEPError.h"
#import "LEPUtils.h"

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
    return [[self path] componentsSeparatedByString:[NSString stringWithFormat:@"%c", _delimiter]];
}

- (void) _setupRequest:(LEPIMAPRequest *)request
{
    if ([_account _session] == nil) {
        [_account _setupSession];
    }
    
    [request setSession:[_account _session]];
    
    if (([[[_account _session] error] code] == LEPErrorConnection) || ([[[_account _session] error] code] == LEPErrorParse)) {
        [_account _unsetupSession];
    }
}

- (LEPIMAPRequest *) deleteRequest
{
	LEPIMAPDeleteFolderRequest * request;
	
	request = [[LEPIMAPDeleteFolderRequest alloc] init];
    [request setPath:[self path]];
    
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPRequest *) renameRequestWithNewPath:(NSString *)newPath
{
	LEPIMAPRenameFolderRequest * request;
	
	request = [[LEPIMAPRenameFolderRequest alloc] init];
    [request setOldPath:[self path]];
    [request setNewPath:newPath];
    
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPRequest *) subscribeRequest
{
	LEPIMAPSubscribeFolderRequest * request;
	
	request = [[LEPIMAPSubscribeFolderRequest alloc] init];
    [request setPath:[self path]];
    
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPRequest *) unsubscribeRequest
{
	LEPIMAPUnsubscribeFolderRequest * request;
	
	request = [[LEPIMAPUnsubscribeFolderRequest alloc] init];
    [request setPath:[self path]];
    
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPRequest *) appendMessageRequest:(LEPMessage *)message;
{
	LEPIMAPAppendMessageRequest * request;
	
	request = [[LEPIMAPAppendMessageRequest alloc] init];
    [request setData:[message data]];
    [request setPath:[self path]];
    
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPRequest *) copyMessages:(NSArray * /* LEPIMAPMessage */)messages toFolder:(LEPIMAPFolder *)toFolder;
{
	LEPIMAPCopyMessageRequest * request;
	LEPIMAPAccount * account;
    LEPIMAPFolder * sourceFolder;
    NSMutableArray * uidSet;
    
    LEPAssert([messages count] > 0);
    
    uidSet = [[NSMutableArray alloc] init];
    sourceFolder = [[messages objectAtIndex:0] folder];
    LEPAssert([sourceFolder account] == account);
    for(LEPIMAPMessage * message in messages) {
        LEPAssert([message folder] == sourceFolder);
        [uidSet addObject:[message uid]];
    }
    
	request = [[LEPIMAPCopyMessageRequest alloc] init];
    [request setUidSet:uidSet];
    [request setFromPath:[self path]];
    [request setToPath:[toFolder path]];
    
    [self _setupRequest:request];
    
    [uidSet release];
    
    return [request autorelease];
}

- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequest
{
#warning should be implemented
    return nil;
}

- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequestFromUID:(uint32_t)uid
{
#warning should be implemented
    return nil;
}

- (LEPIMAPFetchFolderMessagesUIDRequest *) fetchMessagesUIDRequestToUID:(uint32_t)uid;
{
#warning should be implemented
    return nil;
}

@end

