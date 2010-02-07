//
//  LEPIMAPFetchFoldersRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 07/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "LEPIMAPFetchFoldersRequest.h"

@implementation LEPIMAPFetchFoldersRequest

@synthesize account = _account;
@synthesize folders = _folders;

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


@end
