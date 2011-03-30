//
//  LEPIMAPAccount.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPAccount.h"
#import "LEPIMAPAccount+Gmail.h"
#import "LEPIMAPAccount+Provider.h"
#import "LEPIMAPAccountPrivate.h"

#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"
#import "LEPUtils.h"
#import "LEPIMAPFetchSubscribedFoldersRequest.h"
#import "LEPIMAPFetchAllFoldersRequest.h"
#import "LEPIMAPCreateFolderRequest.h"
#import "LEPError.h"
#import "LEPIMAPFolder.h"
#import "LEPIMAPFolderPrivate.h"
#import "LEPIMAPCapabilityRequest.h"
#import "LEPIMAPNamespaceRequest.h"
#import "LEPIMAPNamespacePrivate.h"
#import "LEPIMAPRenameFolderRequest.h"
#import "LEPIMAPDeleteFolderRequest.h"
#import "LEPIMAPCheckRequest.h"
#import <libetpan/libetpan.h>

@interface LEPIMAPAccount ()

//- (void) _setupRequest:(LEPIMAPRequest *)request;
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
@synthesize checkCertificate = _checkCertificate;

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
    _checkCertificate = YES;
    
	return self;
} 

- (void) dealloc
{
    [self _unsetupSession];
    [_xListMapping release];
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

- (LEPIMAPFetchFoldersRequest *) fetchAllFoldersUsingXListRequest
{
	LEPIMAPFetchAllFoldersRequest * request;
	
	request = [[LEPIMAPFetchAllFoldersRequest alloc] init];
    [request setUseXList:YES];
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

- (LEPIMAPCapabilityRequest *) capabilityRequest
{
	LEPIMAPCapabilityRequest * request;
	
	request = [[LEPIMAPCapabilityRequest alloc] init];
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPNamespaceRequest *) namespaceRequest
{
	LEPIMAPNamespaceRequest * request;
	
	request = [[LEPIMAPNamespaceRequest alloc] init];
    [request setAccount:self];
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPCheckRequest *) checkRequest
{
	LEPIMAPCheckRequest * request;
	
	request = [[LEPIMAPCheckRequest alloc] init];
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
        [session setCheckCertificate:[self checkCertificate]];
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
	NSMutableSet * detectableMailbox;
    
	isGoogleMail = NO;
    LEPLog(@"finished ! %@", paths);
    
    detectableMailbox = [[NSMutableSet alloc] init];
    localizedMailbox = [[NSArray alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"localized-mailbox" ofType:@"plist"]];
    for(NSDictionary * item in localizedMailbox) {
        NSArray * mailboxNames;
        BOOL match;
		NSMutableSet * currentSet;
		
        mailboxNames = [item allValues];
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
                [detectableMailbox addObject:str];
			}
        }
    }
    
    //folderNameSet = [[NSMutableSet alloc] init];
    folderNameArray = [[NSMutableArray alloc] init];
	
	countGmail = 0;
	countGoogleMail = 0;
    for(NSString * path in paths) {
        NSString * str;
        
        str = nil;
        if ([path hasPrefix:@"[Gmail]/"]) {
            str = [path substringFromIndex:8];
            if ([detectableMailbox containsObject:str]) {
                countGmail ++;
            }
        }
        else if ([path hasPrefix:@"[Google Mail]/"]) {
            str = [path substringFromIndex:14];
            if ([detectableMailbox containsObject:str]) {
                countGoogleMail ++;
            }
        }
    }
    //NSLog(@"gmail: %u, google mail: %u", countGmail, countGoogleMail);
	if (countGoogleMail > countGmail) {
		isGoogleMail = YES;
	}
    
    for(NSString * path in paths) {
        NSString * str;
        
        str = nil;
        if ([path hasPrefix:@"[Gmail]/"]) {
            if (!isGoogleMail) {
                str = [path substringFromIndex:8];
            }
        }
        else if ([path hasPrefix:@"[Google Mail]/"]) {
            if (isGoogleMail) {
                str = [path substringFromIndex:14];
            }
        }
        
        if (str != nil) {
			[folderNameArray addObject:str];
        }
    }
    
	bestItem = nil;
	bestScore = 0;
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
	
    //[folderNameSet release];
	[folderNameArray release];
    [detectableMailbox release];
    [localizedMailbox release];
}

- (void) cancel
{
    for(LEPIMAPSession * session in _sessions) {
        [session cancel];
    }
}

- (BOOL) _isGmailFolder:(LEPIMAPFolder *)folder
{
    NSMutableSet * pathSet;
    BOOL result;    
    
    pathSet = [[NSMutableSet alloc] init];
    [pathSet addObject:[[self sentMailFolder] path]];
    [pathSet addObject:[[self starredFolder] path]];
    [pathSet addObject:[[self allMailFolder] path]];
    [pathSet addObject:[[self trashFolder] path]];
    [pathSet addObject:[[self draftsFolder] path]];
    [pathSet addObject:[[self spamFolder] path]];
    [pathSet addObject:[[self importantFolder] path]];
    
    result = [pathSet containsObject:[folder path]];
    
    [pathSet release];
    
    return result;
}

- (void) _setupRequest:(LEPIMAPRequest *)request forMailbox:(NSString *)mailbox
{
    [request setMailboxSelectionPath:mailbox];
    for(LEPIMAPSession * currentSession in _sessions) {
        if ([currentSession _matchLastMailbox:mailbox]) {
            [request setSession:currentSession];
            return;
        }
    }
    
    [self _setupRequest:request];
}

- (void) _setDefaultDelimiter:(char)delimiter
{
    _defaultDelimiter = delimiter;
}

- (LEPIMAPNamespace *) defaultNamespace
{
    if (_defaultNamespace != nil)
        return _defaultNamespace;
    
    if (_defaultDelimiter == 0)
        return nil;
    
    return [LEPIMAPNamespace _defaultNamespaceWithDelimiter:_defaultDelimiter];
}

- (void) _setDefaultNamespace:(LEPIMAPNamespace *)ns
{
    [_defaultNamespace release];
    _defaultNamespace = [ns retain];
}

- (void) setupNamespaceWithPrefix:(NSString *)prefix delimiter:(char)delimiter;
{
    if (prefix == nil) {
        [self _setDefaultDelimiter:delimiter];
        return;
    }
    
    [self _setDefaultNamespace:[LEPIMAPNamespace namespaceWithPrefix:prefix delimiter:delimiter]];
}

- (LEPIMAPRequest *) renameRequestPath:(NSString *)path toNewPath:(NSString *)newPath
{
	LEPIMAPRenameFolderRequest * request;
	
	request = [[LEPIMAPRenameFolderRequest alloc] init];
    [request setOldPath:path];
    [request setNewPath:newPath];
    
    [self _setupRequest:request];
    
    return [request autorelease];
}

- (LEPIMAPRequest *) deleteRequestPath:(NSString *)path
{
	LEPIMAPDeleteFolderRequest * request;
	
	request = [[LEPIMAPDeleteFolderRequest alloc] init];
    [request setPath:path];
    
    [self _setupRequest:request];
    
    return [request autorelease];
}

@end
