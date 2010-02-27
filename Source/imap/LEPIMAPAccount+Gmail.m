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

@implementation LEPIMAPAccount (Gmail)

- (LEPIMAPFolder *) sentMailFolder
{
	LEPIMAPFolder * folder;
	
	folder = [[LEPIMAPFolder alloc] init];
	[folder _setPath:@"[Gmail]/Sent Mail"];
	[folder _setAccount:self];
	
	return [folder autorelease];
}

- (LEPIMAPFolder *) allMailFolder
{
	LEPIMAPFolder * folder;
	
	folder = [[LEPIMAPFolder alloc] init];
	[folder _setPath:@"[Gmail]/All Mail"];
	[folder _setAccount:self];
	
	return [folder autorelease];
}

- (LEPIMAPFolder *) draftFolder
{
	LEPIMAPFolder * folder;
	
	folder = [[LEPIMAPFolder alloc] init];
	[folder _setPath:@"[Gmail]/Drafts"];
	[folder _setAccount:self];
	
	return [folder autorelease];
}

- (LEPIMAPFolder *) starredFolder
{
	LEPIMAPFolder * folder;
	
	folder = [[LEPIMAPFolder alloc] init];
	[folder _setPath:@"[Gmail]/Starred"];
	[folder _setAccount:self];
	
	return [folder autorelease];
}

- (LEPIMAPFolder *) trashFolder
{
	LEPIMAPFolder * folder;
	
	folder = [[LEPIMAPFolder alloc] init];
	[folder _setPath:@"[Gmail]/Trash"];
	[folder _setAccount:self];
	
	return [folder autorelease];
}

@end
