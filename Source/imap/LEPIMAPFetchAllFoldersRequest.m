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
#import "LEPIMAPFolder.h"
#import "LEPUtils.h"

@implementation LEPIMAPFetchAllFoldersRequest

- (void) mainRequest
{
	_folders = [[_session _fetchAllFoldersWithAccount:_account] retain];
}

- (void) mainFinished
{
    NSArray * localizedMailbox;
    NSMutableSet * folderNameSet;
    
    LEPLog(@"finished ! %@", _folders);
    
    folderNameSet = [[NSMutableSet alloc] init];
    
    for(LEPIMAPFolder * folder in _folders) {
        NSString * str;
        
        str = nil;
        if ([[folder path] hasPrefix:@"[Gmail]/"]) {
            str = [[folder path] substringFromIndex:8];
        }
        else if ([[folder path] hasPrefix:@"[Google Mail]/"]) {
            str = [[folder path] substringFromIndex:14];
        }
        if (str != nil) {
            [folderNameSet addObject:str];
        }
    }
    
    localizedMailbox = [[NSArray alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"localized-mailbox" ofType:@"plist"]];
    //LEPLog(@"%@", localizedMailbox);
    for(NSDictionary * item in localizedMailbox) {
        NSArray * mailboxNames;
        BOOL match;
        
        mailboxNames = [item allValues];
        
        match = YES;
        for(NSString * name in mailboxNames) {
            NSString * str;
            
            str = nil;
            if ([name hasPrefix:@"[Gmail]/"]) {
                str = [name substringFromIndex:8];
            }
            else if ([name hasPrefix:@"[Google Mail]/"]) {
                str = [name substringFromIndex:14];
            }
            
            if (str != nil) {
                if (![folderNameSet containsObject:str]) {
                    match = NO;
                    continue;
                }
            }
        }
        
        LEPLog(@"%@ %@ %u", mailboxNames, folderNameSet, match);
        if (match) {
            [_account _setGmailMailboxNames:item];
            break;
        }
    }
    [localizedMailbox release];
    
    [folderNameSet release];
}

@end
