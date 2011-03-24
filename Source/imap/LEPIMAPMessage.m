//
//  LEPIMAPMessage.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPMessage.h"

#import "LEPIMAPFetchMessageRequest.h"
#import "LEPIMAPFetchMessageStructureRequest.h"
#import "LEPIMAPFetchAttachmentRequest.h"
#import "LEPIMAPAccountPrivate.h"
#import "LEPIMAPFolder.h"
#import "LEPIMAPFolderPrivate.h"
#import "LEPError.h"
#import "LEPUtils.h"
#import "LEPMessageHeader.h"
#import "LEPAbstractAttachment.h"
#import "LEPUtils.h"
#include <libetpan/libetpan.h>

@interface LEPIMAPMessage ()

- (void) _setupRequest:(LEPIMAPRequest *)request;

@end

@implementation LEPIMAPMessage

@synthesize flags = _flags;
@synthesize originalFlags = _originalFlags;
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

- (void) _setAttachments:(NSArray *)attachments
{
	[_attachments release];
	_attachments = [attachments retain];
	for(LEPAbstractAttachment * attachment in _attachments) {
		[attachment setMessage:self];
	}
}

- (void) _setupRequest:(LEPIMAPRequest *)request
{
	LEPLog(@"setuprequest : %@ %@", _folder, [_folder account]);
	[_folder _setupRequest: request];
}

- (LEPIMAPFetchMessageStructureRequest *) fetchMessageStructureRequest;
{
	LEPIMAPFetchMessageStructureRequest * request;
	
	request = [[LEPIMAPFetchMessageStructureRequest alloc] init];
	[request setPath:[_folder path]];
	[request setUid:[self uid]];
	[request setMessage:self];
	
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPFetchMessageRequest *) fetchMessageRequest;
{
	LEPIMAPFetchMessageRequest * request;
	
	request = [[LEPIMAPFetchMessageRequest alloc] init];
	[request setPath:[_folder path]];
	[request setUid:[self uid]];
	
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPFetchAttachmentRequest *) fetchAttachmentRequestWithPartID:(NSString *)partID
{
	LEPIMAPFetchAttachmentRequest * request;
	
	request = [[LEPIMAPFetchAttachmentRequest alloc] init];
	[request setPath:[_folder path]];
	[request setUid:[self uid]];
	[request setPartID:partID];
	[request setEncoding:MAILMIME_MECHANISM_8BIT];
    [request setSize:0];
	
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"<%@: 0x%p %lu %@ %@>", [self class], self, (unsigned long) [self uid], [[self header] from], [[self header] subject]];
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	_flags = [coder decodeInt32ForKey:@"flags"];
	_originalFlags = [coder decodeInt32ForKey:@"originalFlags"];
	_uid = (uint32_t) [coder decodeInt32ForKey:@"uid"];
	[self _setAttachments:[coder decodeObjectForKey:@"attachments"]];
	//LEPLog(@"%@", [self attachments]);
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeInt32:(int32_t)_flags forKey:@"flags"];
	[encoder encodeInt32:(int32_t)_originalFlags forKey:@"originalFlags"];
	[encoder encodeInt32:(int32_t)_uid forKey:@"uid"];
	[encoder encodeObject:_attachments forKey:@"attachments"];
}

- (id) copyWithZone:(NSZone *)zone
{
    LEPIMAPMessage * message;
    
    message = [super copyWithZone:zone];
    
    [message setOriginalFlags:[self originalFlags]];
    [message setFlags:[self flags]];
    [message _setUid:[self uid]];
    [message setFolder:[self folder]];
	
	if ([self attachments] != nil) {
		NSMutableArray * attachments;
		
		attachments = [[NSMutableArray alloc] init];
		for(LEPAbstractAttachment * attachment in [self attachments]) {
			[attachments addObject:[[attachment copy] autorelease]];
		}
		[message _setAttachments:attachments];
		[attachments release];
	}
    
    return message;
}

@end
