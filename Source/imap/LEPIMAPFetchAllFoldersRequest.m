//
//  LEPIMAPFetchAllFoldersRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 18/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPFetchAllFoldersRequest.h"
#import "LEPIMAPAccount.h"
#import "LEPIMAPAccountPrivate.h"
#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"

@implementation LEPIMAPFetchAllFoldersRequest

- (id) init
{
	self = [super init];
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void) mainRequest
{
	_folders = [[_session _fetchAllFoldersWithAccount:_account] retain];
}

@end
