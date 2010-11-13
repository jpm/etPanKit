//
//  LEPIMAPAccount.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPAccount.h"
#import "LEPIMAPAccount+Gmail.h"

#import "LEPIMAPSession.h"
#import "LEPUtils.h"
#import "LEPIMAPFetchSubscribedFoldersRequest.h"
#import "LEPIMAPFetchAllFoldersRequest.h"
#import "LEPIMAPCreateFolderRequest.h"
#import "LEPError.h"
#import "LEPIMAPFolder.h"
#import "LEPIMAPFolderPrivate.h"
#import <libetpan/libetpan.h>

@interface LEPIMAPAccount ()

- (void) _setupRequest:(LEPIMAPRequest *)request;
- (void) _setupSession;
- (void) _unsetupSession;

@end

@implementation LEPIMAPAccount

@synthesize host = _host;
@synthesize port = _port;
@synthesize login = _login;
@synthesize password = _password;
@synthesize authType = _authType;
@synthesize realm = _realm;
@synthesize sessionsCount = _sessionsCount;

@synthesize idleEnabled = _idleEnabled;

+ (void) setTimeoutDelay:(NSTimeInterval)timeout
{
    mailstream_network_delay.tv_sec = (time_t) timeout;
    mailstream_network_delay.tv_usec = (suseconds_t) (timeout - mailstream_network_delay.tv_sec) * 1000000;
}

+ (NSTimeInterval) timeoutDelay
{
    return (NSTimeInterval) mailstream_network_delay.tv_sec + ((NSTimeInterval) mailstream_network_delay.tv_usec) / 1000000.;
}

- (id) init
{
    NSMutableDictionary * mailboxes;
    
	self = [super init];
	
    mailboxes = [[NSMutableDictionary alloc] init];
    [mailboxes setObject:@"[Google Mail]/All Mail" forKey:@"allmail"];
    [mailboxes setObject:@"[Google Mail]/Drafts" forKey:@"drafts"];
    [mailboxes setObject:@"[Google Mail]/Important" forKey:@"important"];
    [mailboxes setObject:@"[Google Mail]/Sent Mail" forKey:@"sentmail"];
    [mailboxes setObject:@"[Google Mail]/Spam" forKey:@"spam"];
    [mailboxes setObject:@"[Google Mail]/Starred" forKey:@"starred"];
    [mailboxes setObject:@"[Google Mail]/Trash" forKey:@"trash"];
    [self setGmailMailboxNames:mailboxes];
    [mailboxes release];
    
    _sessionsCount = 1;
    
	return self;
} 

- (void) dealloc
{
    [self _unsetupSession];
	[_realm release];
    [_host release];
    [_login release];
    [_password release];
	[super dealloc];
}

- (LEPIMAPFetchFoldersRequest *) fetchSubscribedFoldersRequest
{
	LEPIMAPFetchSubscribedFoldersRequest * request;
	
	request = [[LEPIMAPFetchSubscribedFoldersRequest alloc] init];
	[request setAccount:self];
	
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPFetchFoldersRequest *) fetchAllFoldersRequest
{
	LEPIMAPFetchAllFoldersRequest * request;
	
	request = [[LEPIMAPFetchAllFoldersRequest alloc] init];
	[request setAccount:self];
    
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPRequest *) createFolderRequest:(NSString *)path
{
	LEPIMAPCreateFolderRequest * request;
	
	request = [[LEPIMAPCreateFolderRequest alloc] init];
    [request setPath:path];
    
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (void) _setupSession
{
	LEPAssert(_sessions == nil);
    
	LEPLog(@"setup session");
	_sessions = [[NSMutableArray alloc] init];
    
	for(unsigned int i = 0 ; i < _sessionsCount ; i ++) {
        LEPIMAPSession * session;
        
        session = [[LEPIMAPSession alloc] init];
        [session setHost:[self host]];
        [session setPort:[self port]];
        [session setLogin:[self login]];
        [session setPassword:[self password]];
        [session setAuthType:[self authType]];
        [session setRealm:[self realm]];
        [_sessions addObject:session];
        [session release];
    }
}

- (void) _unsetupSession
{
    [_sessions release];
    _sessions = nil;
}

- (void) _setupRequest:(LEPIMAPRequest *)request
{
    LEPIMAPSession * session;
    unsigned int lowestPending;
    
    if (_sessions == nil) {
		[self _setupSession];
	}
    
    session = nil;
    lowestPending = 0;
    for(LEPIMAPSession * currentSession in _sessions) {
        if (session == nil) {
            session = currentSession;
            lowestPending = [session pendingRequestsCount];
        }
        else if ([currentSession pendingRequestsCount] < lowestPending) {
            session = currentSession;
            lowestPending = [session pendingRequestsCount];
        }
    }
    
    [request setSession:session];
}

- (LEPIMAPFolder *) inboxFolder
{
	return [self folderWithPath:@"INBOX"];
}

- (LEPIMAPFolder *) folderWithPath:(NSString *)path
{
	LEPIMAPFolder * folder;
	
	folder = [[LEPIMAPFolder alloc] init];
	[folder _setPath:path];
	[folder _setAccount:self];
	
	return [folder autorelease];
}

- (void) setupWithFoldersPaths:(NSArray *)paths
{
    NSArray * localizedMailbox;
    //NSMutableSet * folderNameSet;
	NSMutableArray * folderNameArray;
    BOOL isGoogleMail;
	unsigned int bestScore;
	NSDictionary * bestItem;
	unsigned int countGmail;
	unsigned int countGoogleMail;
	
	isGoogleMail = NO;
    LEPLog(@"finished ! %@", paths);
    
    //folderNameSet = [[NSMutableSet alloc] init];
    folderNameArray = [[NSMutableArray alloc] init];
	
	countGmail = 0;
	countGoogleMail = 0;
    for(NSString * path in paths) {
        NSString * str;
        
        str = nil;
        if ([path hasPrefix:@"[Gmail]/"]) {
            str = [path substringFromIndex:8];
			countGmail ++;
        }
        else if ([path hasPrefix:@"[Google Mail]/"]) {
            str = [path substringFromIndex:14];
			countGoogleMail ++;
        }
        if (str != nil) {
            //[folderNameSet addObject:str];
			[folderNameArray addObject:str];
        }
    }
	if (countGoogleMail > countGmail) {
		isGoogleMail = YES;
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
		[self setGmailMailboxNames:gmailMailboxes];
		[gmailMailboxes release];
	}
	
    [localizedMailbox release];
    
    //[folderNameSet release];
	[folderNameArray release];
}

@end
