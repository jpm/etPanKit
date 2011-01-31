//
//  LEPIMAPFetchFolderMessagesRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 20/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPFetchFolderMessagesRequest.h"

#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"
#import "LEPUtils.h"

@interface LEPIMAPFetchFolderMessagesRequest () <LEPIMAPSessionProgressDelegate>

@property (nonatomic, assign, readwrite) unsigned int progressCount;

@end

@implementation LEPIMAPFetchFolderMessagesRequest

@synthesize path = _path;
@synthesize fromUID = _fromUID;
@synthesize toUID = _toUID;
@synthesize messages = _messages;
@synthesize fetchKind = _fetchKind;
@synthesize folder = _folder;
@synthesize progressCount = _progressCount;
@synthesize workaround = _workaround;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
    [_messages release];
    [_path release];
	[_folder release];
	[super dealloc];
}

- (void) mainRequest
{
	LEPLog(@"request messages");
    if ((_workaround & LEPIMAPWorkaroundYahoo) != 0) {
        if ((_fetchKind & LEPIMAPMessagesRequestKindHeaders) != 0) {
            _fetchKind &= ~LEPIMAPMessagesRequestKindHeaders;
            _fetchKind |= LEPIMAPMessagesRequestKindFullHeaders;
        }
    }
    if ((_workaround & LEPIMAPWorkaroundGmail) != 0) {
        if ((_fetchKind & LEPIMAPMessagesRequestKindHeaders) != 0) {
            _fetchKind |= LEPIMAPMessagesRequestKindHeaderSubject;
        }
    }
    
    _messages = [[_session _fetchFolderMessages:_path fromUID:_fromUID toUID:_toUID kind:_fetchKind folder:_folder
                               progressDelegate:self] retain];
}

- (void) LEPIMAPSession:(LEPIMAPSession *)session bodyProgressWithCurrent:(size_t)current maximum:(size_t)maximum
{
    // do nothing
}

- (void) LEPIMAPSession:(LEPIMAPSession *)session itemsProgressWithCurrent:(size_t)current maximum:(size_t)maximum
{
    [self setProgressCount:current];
}

@end
