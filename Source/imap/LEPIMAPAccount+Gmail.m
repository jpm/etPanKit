//
//  LEPIMAPAccount+Gmail.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 27/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPAccount+Gmail.h"

#import "LEPIMAPFolder.h"
#import "LEPIMAPFolderPrivate.h"
#import "LEPUtils.h"

@implementation LEPIMAPAccount (Gmail)

- (LEPIMAPFolder *) sentMailFolder
{
	LEPIMAPFolder * folder;
	
    LEPAssert(_gmailMailboxNames != nil);
    
	folder = [[LEPIMAPFolder alloc] init];
	[folder _setPath:[_gmailMailboxNames objectForKey:@"sentmail"]];
	[folder _setAccount:self];
	
	return [folder autorelease];
}

- (LEPIMAPFolder *) allMailFolder
{
	LEPIMAPFolder * folder;
	
	folder = [[LEPIMAPFolder alloc] init];
	[folder _setPath:[_gmailMailboxNames objectForKey:@"allmail"]];
	[folder _setAccount:self];
	
	return [folder autorelease];
}

- (LEPIMAPFolder *) starredFolder
{
	LEPIMAPFolder * folder;
	
    LEPAssert(_gmailMailboxNames != nil);
    
	folder = [[LEPIMAPFolder alloc] init];
	[folder _setPath:[_gmailMailboxNames objectForKey:@"starred"]];
	[folder _setAccount:self];
	
	return [folder autorelease];
}

- (LEPIMAPFolder *) trashFolder
{
	LEPIMAPFolder * folder;
	
    LEPAssert(_gmailMailboxNames != nil);
    
	folder = [[LEPIMAPFolder alloc] init];
	[folder _setPath:[_gmailMailboxNames objectForKey:@"trash"]];
	[folder _setAccount:self];
	
	return [folder autorelease];
}

- (LEPIMAPFolder *) draftsFolder
{
	LEPIMAPFolder * folder;
	
    LEPAssert(_gmailMailboxNames != nil);
    
	folder = [[LEPIMAPFolder alloc] init];
	[folder _setPath:[_gmailMailboxNames objectForKey:@"drafts"]];
	[folder _setAccount:self];
	
	return [folder autorelease];
}

- (LEPIMAPFolder *) spamFolder
{
	LEPIMAPFolder * folder;
	
    LEPAssert(_gmailMailboxNames != nil);
    
	folder = [[LEPIMAPFolder alloc] init];
	[folder _setPath:[_gmailMailboxNames objectForKey:@"spam"]];
	[folder _setAccount:self];
	
	return [folder autorelease];
}

- (void) setGmailMailboxNames:(NSDictionary *)gmailMailboxNames
{
    [_gmailMailboxNames release];
    _gmailMailboxNames = [gmailMailboxNames retain];
}

- (NSDictionary *) gmailMailboxNames
{
    return _gmailMailboxNames;
}

@end
