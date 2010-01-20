//
//  LEPIMAPRenameFolderRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 20/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPRenameFolderRequest.h"
#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"

@implementation LEPIMAPRenameFolderRequest

@synthesize oldPath = _oldPath;
@synthesize newPath = _newPath;

- (id) init
{
	self = [super init];
	
	return self;
}

- (void) dealloc
{
    [_oldPath release];
    [_newPath release];
	[super dealloc];
}

- (void) mainRequest
{
	[_session _renameFolder:[self oldPath] withNewPath:[self newPath]];
}

@end
