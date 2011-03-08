//
//  LEPIMAPFetchAttachmentRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPFetchAttachmentRequest.h"

#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"
#import "LEPUtils.h"
#include <libetpan/libetpan.h>
#import "LEPError.h"
#import "LEPAttachment.h"
#import "LEPAttachmentPrivate.h"

@interface LEPIMAPFetchAttachmentRequest () <LEPIMAPSessionProgressDelegate>

@property (nonatomic, assign, readwrite) size_t currentProgress;
@property (nonatomic, assign, readwrite) size_t maximumProgress;

@end

@implementation LEPIMAPFetchAttachmentRequest

@synthesize data = _data;
@synthesize path = _path;
@synthesize partID = _partID;
@synthesize uid = _uid;
@synthesize encoding = _encoding;
@synthesize size = _size;
@synthesize workaround = _workaround;
@synthesize currentProgress = _currentProgress;
@synthesize maximumProgress = _maximumProgress;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
	[_data release];
	[_path release];
	[_partID release];
	[super dealloc];
}

- (void) mainRequest
{
	LEPLog(@"fetch %@ %u", _partID, _uid);
	_data = [[_session _fetchAttachmentWithPartID:_partID UID:_uid path:_path encoding:_encoding
                                     expectedSize:_size
                                 progressDelegate:self] retain];
    if ([_session error] == nil)
        return;
    if (![[[_session error] domain] isEqualToString:LEPErrorDomain])
        return;
    if ([[_session error] code] != LEPErrorFetch)
        return;
    
    if (_workaround & LEPIMAPWorkaroundGmail) {
        NSString * currentPartID;
        
        currentPartID = _partID;
        while (1) {
            NSArray * partIDs;
            
            partIDs = [currentPartID componentsSeparatedByString:@"."];
            if ([currentPartID length] == 0) {
                NSData * messageData;
                
                messageData = [_session _fetchMessageWithUID:_uid path:_path
                                     progressDelegate:nil];
                if ([_session error] != nil)
                    return;
                
                _data = [[LEPAttachment dataForPartID:_partID encoding:_encoding messageData:messageData] retain];
                if (_data == nil) {
                    [_session _setError:[NSError errorWithDomain:LEPErrorDomain code:LEPErrorFetch userInfo:nil]];
                    return;
                }
                
                return;
            }
            
            NSString * contentType;
            
            partIDs = [partIDs subarrayWithRange:NSMakeRange(0, [partIDs count] - 1)];
            currentPartID = [partIDs componentsJoinedByString:@"."];
            contentType = [_session _fetchContentTypeWithPartID:currentPartID UID:_uid path:_path];
            if (![[contentType lowercaseString] isEqualToString:@"message/rfc822"]) {
                continue;
            }
            
            NSData * messageData;
            
            messageData = [_session _fetchAttachmentWithPartID:currentPartID
                                                           UID:_uid
                                                          path:_path
                                                      encoding:MAILMIME_MECHANISM_8BIT
                                                  expectedSize:0
                                              progressDelegate:self];
            
            NSString * subPartID;
            subPartID = [_partID substringFromIndex:[currentPartID length] + 1];
            _data = [[LEPAttachment dataForPartID:subPartID encoding:_encoding messageData:messageData] retain];
            if (_data == nil) {
                [_session _setError:[NSError errorWithDomain:LEPErrorDomain code:LEPErrorFetch userInfo:nil]];
                return;
            }
            return;
        }
    }
	LEPLog(@"fetch -> %p %u", _data, [_data length]);
}

- (void) LEPIMAPSession:(LEPIMAPSession *)session bodyProgressWithCurrent:(size_t)current maximum:(size_t)maximum
{
    [self setCurrentProgress:current];
    [self setMaximumProgress:maximum];
}

- (void) LEPIMAPSession:(LEPIMAPSession *)session itemsProgressWithCurrent:(size_t)current maximum:(size_t)maximum
{
    // do nothing
}

@end
