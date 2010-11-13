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
	return [self folderWithPath:[_gmailMailboxNames objectForKey:@"sentmail"]];
}

- (LEPIMAPFolder *) allMailFolder
{
	return [self folderWithPath:[_gmailMailboxNames objectForKey:@"allmail"]];
}

- (LEPIMAPFolder *) starredFolder
{
	return [self folderWithPath:[_gmailMailboxNames objectForKey:@"starred"]];
}

- (LEPIMAPFolder *) trashFolder
{
	return [self folderWithPath:[_gmailMailboxNames objectForKey:@"trash"]];
}

- (LEPIMAPFolder *) draftsFolder
{
	return [self folderWithPath:[_gmailMailboxNames objectForKey:@"drafts"]];
}

- (LEPIMAPFolder *) spamFolder
{
	return [self folderWithPath:[_gmailMailboxNames objectForKey:@"spam"]];
}

- (LEPIMAPFolder *) importantFolder
{
	return [self folderWithPath:[_gmailMailboxNames objectForKey:@"important"]];
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
