//
//  LEPIMAPFetchSubscribedFoldersRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 06/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPFetchSubscribedFoldersRequest.h"
#import "LEPIMAPAccount.h"
#import "LEPIMAPAccountPrivate.h"
#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"

@implementation LEPIMAPFetchSubscribedFoldersRequest

@synthesize account = _account;

- (id) init
{
	self = [super init];
	
	return self;
}

- (void) dealloc
{
	[_account release];
	[_folders release];
	[super dealloc];
}

- (void) mainRequest
{
	_folders = [_session _fetchSubscribedFolders];
}

- (void) mainFinished
{
	[_account _setSubscribedFolders:_folders];
}

@end
