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

- (void) mainRequest
{
	_folders = [[_session _fetchSubscribedFoldersWithAccount:_account] retain];
}

@end
