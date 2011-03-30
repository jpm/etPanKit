//
//  LEPIMAPFetchAllFoldersRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 18/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPFetchAllFoldersRequest.h"
#import "LEPIMAPAccount.h"
#import "LEPIMAPAccount+Gmail.h"
#import "LEPIMAPAccountPrivate.h"
#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"
#import "LEPIMAPFolder.h"
#import "LEPIMAPFolderPrivate.h"
#import "LEPUtils.h"

@implementation LEPIMAPFetchAllFoldersRequest

@synthesize useXList = _useXList;

- (void) mainRequest
{
	_folders = [[_session _fetchAllFoldersWithAccount:_account usingXList:_useXList] retain];
}

- (void) mainFinished
{
    NSMutableArray * paths;
    
    paths = [[NSMutableArray alloc] init];
    for(LEPIMAPFolder * folder in _folders) {
        [paths addObject:[folder path]];
        if ([[folder path] isEqualToString:@"INBOX"]) {
            [_account _setDefaultDelimiter:[folder _delimiter]];
        }
    }
    [_account setupWithFoldersPaths:paths];
    [paths release];
}

@end
