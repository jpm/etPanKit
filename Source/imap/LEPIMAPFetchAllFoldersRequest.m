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
#import "LEPUtils.h"

@implementation LEPIMAPFetchAllFoldersRequest

- (void) mainRequest
{
	_folders = [[_session _fetchAllFoldersWithAccount:_account] retain];
}

- (void) mainFinished
{
    NSArray * localizedMailbox;
    //NSMutableSet * folderNameSet;
	NSMutableArray * folderNameArray;
    BOOL isGoogleMail;
	
	isGoogleMail = NO;
    LEPLog(@"finished ! %@", _folders);
    
    //folderNameSet = [[NSMutableSet alloc] init];
    folderNameArray = [[NSMutableArray alloc] init];
	
    for(LEPIMAPFolder * folder in _folders) {
        NSString * str;
        
        str = nil;
        if ([[folder path] hasPrefix:@"[Gmail]/"]) {
            str = [[folder path] substringFromIndex:8];
        }
        else if ([[folder path] hasPrefix:@"[Google Mail]/"]) {
            str = [[folder path] substringFromIndex:14];
			isGoogleMail = YES;
        }
        if (str != nil) {
            //[folderNameSet addObject:str];
			[folderNameArray addObject:str];
        }
    }
    
    localizedMailbox = [[NSArray alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"localized-mailbox" ofType:@"plist"]];
    //LEPLog(@"%@", localizedMailbox);
    for(NSDictionary * item in localizedMailbox) {
        NSArray * mailboxNames;
        BOOL match;
		NSMutableSet * currentSet;
		
        mailboxNames = [item allValues];
        
		currentSet = [[NSMutableSet alloc] init];
		
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
            
#if 0
            if (str != nil) {
                if (![folderNameSet containsObject:str]) {
                    match = NO;
                    continue;
                }
            }
#endif
			if (str != nil) {
				[currentSet addObject:str];
			}
        }
		
		for(NSString * folderName in folderNameArray) {
			if (![currentSet containsObject:folderName]) {
				match = NO;
			}
		}
		
		[currentSet release];
		
        //LEPLog(@"%@ %@ %u", mailboxNames, folderNameSet, match);
        if (match) {
			LEPLog(@"match %@ %@", mailboxNames, folderNameArray);
			NSMutableDictionary * gmailMailboxes;
			
			gmailMailboxes = [[NSMutableDictionary alloc] init];
			for(NSString * key in item) {
				NSString * name;
				
				name = [item objectForKey:key];
				if ([name hasPrefix:@"[Gmail]/"]) {
					if (isGoogleMail) {
						name = [@"[Google Mail]/" stringByAppendingString:[name substringFromIndex:8]];
					}
				}
				else if ([name hasPrefix:@"[Google Mail]/"]) {
					if (!isGoogleMail) {
						name = [@"[Gmail]/" stringByAppendingString:[name substringFromIndex:14]];
					}
				}
				[gmailMailboxes setObject:name forKey:key];
			}
            [_account setGmailMailboxNames:gmailMailboxes];
			[gmailMailboxes release];
            break;
        }
    }
    [localizedMailbox release];
    
    //[folderNameSet release];
	[folderNameArray release];
}

@end
