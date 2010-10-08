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
	unsigned int bestScore;
	NSDictionary * bestItem;
	
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
    
	bestItem = nil;
	bestScore = 0;
    localizedMailbox = [[NSArray alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"localized-mailbox" ofType:@"plist"]];
    //LEPLog(@"%@", localizedMailbox);
    for(NSDictionary * item in localizedMailbox) {
        NSArray * mailboxNames;
        BOOL match;
		NSMutableSet * currentSet;
		
        mailboxNames = [item allValues];
        
		currentSet = [[NSMutableSet alloc] init];
		
        //match = YES;
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
				[currentSet addObject:str];
			}
        }
		
		unsigned int matchCount;
		matchCount = 0;
		match = NO;
		for(NSString * folderName in folderNameArray) {
			if ([currentSet containsObject:folderName]) {
				[currentSet removeObject:folderName];
				matchCount ++;
			}
		}
		if (matchCount > bestScore) {
			bestScore = matchCount;
			bestItem = item;
		}
		
		[currentSet release];
#if 0
		if (matchCount == [item count]) {
			match = YES;
		}
		
		[currentSet release];
		
		//NSLog(@"is google mail %u", isGoogleMail);
        //LEPLog(@"%@ %@ %u", mailboxNames, folderNameSet, match);
        if (match) {
			LEPLog(@"match %@ %@", mailboxNames, folderNameArray);
			NSMutableDictionary * gmailMailboxes;
			
			gmailMailboxes = [[NSMutableDictionary alloc] init];
			for(NSString * key in item) {
				NSString * name;
				
				name = [item objectForKey:key];
				//NSLog(@"%@ -> %@", key, name);
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
				//NSLog(@"%@ -> %@", key, name);
				[gmailMailboxes setObject:name forKey:key];
			}
            [_account setGmailMailboxNames:gmailMailboxes];
			[gmailMailboxes release];
            break;
        }
#endif
    }
	
	if (bestItem != nil) {
		//LEPLog(@"match %@ %@", mailboxNames, folderNameArray);
		NSMutableDictionary * gmailMailboxes;
		
		gmailMailboxes = [[NSMutableDictionary alloc] init];
		for(NSString * key in bestItem) {
			NSString * name;
			
			name = [bestItem objectForKey:key];
			//NSLog(@"%@ -> %@", key, name);
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
			//NSLog(@"%@ -> %@", key, name);
			[gmailMailboxes setObject:name forKey:key];
		}
		//NSLog(@"%@", gmailMailboxes);
		[_account setGmailMailboxNames:gmailMailboxes];
		[gmailMailboxes release];
	}
	
    [localizedMailbox release];
    
    //[folderNameSet release];
	[folderNameArray release];
}

@end
