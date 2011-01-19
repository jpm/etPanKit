//
//  LEPIMAPSelectRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 07/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "LEPIMAPSelectRequest.h"
#import "LEPIMAPFolder.h"
#import "LEPIMAPFolderPrivate.h"
#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"

@implementation LEPIMAPSelectRequest

@synthesize path = _path;
@synthesize folder = _folder;

- (id) init
{
	self = [super init];
	
	return self;
}

- (void) dealloc
{
	[_folder release];
    [_path release];
	[super dealloc];
}

- (void) mainRequest
{
	[_session _selectIfNeeded:_path];
}

- (void) mainFinished
{
    if ([self isCancelled]) {
        return;
    }
    
    if ([self error] != nil) {
        return;
    }
    
    [_folder _setUidValidity:[_session uidValidity]];
    [_folder _setUidNext:[_session uidNext]];
}

@end
