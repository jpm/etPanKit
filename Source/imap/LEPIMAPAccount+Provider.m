//
//  LEPIMAPAccount+Provider.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPAccount+Provider.h"

#import "LEPIMAPAccount+Gmail.h"
#import "LEPMailProvider.h"
#import "LEPIMAPNamespace.h"
#import "LEPIMAPFolder.h"

#define GMAIL_PROVIDER_IDENTIFIER @"gmail"

@implementation LEPIMAPAccount (Provider)

- (LEPIMAPFolder *) _providerFolderWithPath:(NSString *)path
{
    NSString * fullPath;
    
    if ([self defaultNamespace] == nil) {
        fullPath = path;
    }
    else {
        fullPath = [[[self defaultNamespace] mainPrefix] stringByAppendingString:path];
    }
    return [self folderWithPath:fullPath];
}

- (LEPIMAPFolder *) sentMailFolderForProvider:(LEPMailProvider *)provider
{
    if (_xListMapping != nil) {
        if ([_xListMapping objectForKey:@"sentmail"] != nil) {
            return [self _providerFolderWithPath:[_xListMapping objectForKey:@"sentmail"]];
        }
    }
    
    if ([[provider identifier] isEqualToString:GMAIL_PROVIDER_IDENTIFIER]) {
        return [self sentMailFolder];
    }
    
    if ([provider sentMailFolderPath] == nil)
        return nil;
    
	return [self _providerFolderWithPath:[provider sentMailFolderPath]];
}

- (LEPIMAPFolder *) starredFolderForProvider:(LEPMailProvider *)provider
{
    if (_xListMapping != nil) {
        if ([_xListMapping objectForKey:@"starred"] != nil) {
            return [self _providerFolderWithPath:[_xListMapping objectForKey:@"starred"]];
        }
    }
    
    if ([[provider identifier] isEqualToString:GMAIL_PROVIDER_IDENTIFIER]) {
        return [self starredFolder];
    }
    
    if ([provider starredFolderPath] == nil)
        return nil;
    
	return [self _providerFolderWithPath:[provider starredFolderPath]];
}

- (LEPIMAPFolder *) allMailFolderForProvider:(LEPMailProvider *)provider;
{
    if (_xListMapping != nil) {
        if ([_xListMapping objectForKey:@"allmail"] != nil) {
            return [self _providerFolderWithPath:[_xListMapping objectForKey:@"allmail"]];
        }
    }
    
    if ([[provider identifier] isEqualToString:GMAIL_PROVIDER_IDENTIFIER]) {
        return [self allMailFolder];
    }
    
    if ([provider allMailFolderPath] == nil)
        return nil;
    
	return [self _providerFolderWithPath:[provider allMailFolderPath]];
}

- (LEPIMAPFolder *) trashFolderForProvider:(LEPMailProvider *)provider;
{
    if (_xListMapping != nil) {
        if ([_xListMapping objectForKey:@"trash"] != nil) {
            return [self _providerFolderWithPath:[_xListMapping objectForKey:@"trash"]];
        }
    }
    
    if ([[provider identifier] isEqualToString:GMAIL_PROVIDER_IDENTIFIER]) {
        return [self trashFolder];
    }
    
    if ([provider trashFolderPath] == nil)
        return nil;
    
	return [self _providerFolderWithPath:[provider trashFolderPath]];
}

- (LEPIMAPFolder *) draftsFolderForProvider:(LEPMailProvider *)provider;
{
    if (_xListMapping != nil) {
        if ([_xListMapping objectForKey:@"drafts"] != nil) {
            return [self _providerFolderWithPath:[_xListMapping objectForKey:@"drafts"]];
        }
    }
    
    if ([[provider identifier] isEqualToString:GMAIL_PROVIDER_IDENTIFIER]) {
        return [self draftsFolder];
    }
    
    if ([provider draftsFolderPath] == nil)
        return nil;
    
	return [self _providerFolderWithPath:[provider draftsFolderPath]];
}

- (LEPIMAPFolder *) spamFolderForProvider:(LEPMailProvider *)provider;
{
    if (_xListMapping != nil) {
        if ([_xListMapping objectForKey:@"spam"] != nil) {
            return [self _providerFolderWithPath:[_xListMapping objectForKey:@"spam"]];
        }
    }
    
    if ([[provider identifier] isEqualToString:GMAIL_PROVIDER_IDENTIFIER]) {
        return [self spamFolder];
    }
    
    if ([provider spamFolderPath] == nil)
        return nil;
    
	return [self _providerFolderWithPath:[provider spamFolderPath]];
}

- (LEPIMAPFolder *) importantFolderForProvider:(LEPMailProvider *)provider;
{
    if (_xListMapping != nil) {
        if ([_xListMapping objectForKey:@"important"] != nil) {
            return [self _providerFolderWithPath:[_xListMapping objectForKey:@"important"]];
        }
    }
    
    if ([[provider identifier] isEqualToString:GMAIL_PROVIDER_IDENTIFIER]) {
        return [self importantFolder];
    }
    
    if ([provider importantFolderPath] == nil)
        return nil;
    
	return [self _providerFolderWithPath:[provider importantFolderPath]];
}

- (void) setXListMapping:(NSDictionary *)mapping
{
    [_xListMapping release];
    _xListMapping = [mapping copy];
}

- (NSDictionary *) XListMapping
{
    return _xListMapping;
}

- (void) setupWithFoldersPaths:(NSArray *)paths xListHints:(NSDictionary *)mapping
{
    NSSet * pathsSet;
    unsigned int count;
    
    count = 0;
    pathsSet = [[NSSet alloc] initWithArray:paths];
    for(NSString * value in [mapping allValues]) {
        if ([pathsSet containsObject:value]) {
            count ++;
        }
    }
    [pathsSet release];
    
    if (count > 0) {
		[self setXListMapping:mapping];
    }
    [self setupWithFoldersPaths:paths];
}

+ (NSDictionary *) XListMappingWithFolders:(NSArray * /* LEPIMAPFolder */ )folders
{
    NSMutableDictionary * result;
    
    result = [NSMutableDictionary dictionary];
    for(LEPIMAPFolder * folder in folders) {
        if (([folder flags] & LEPIMAPMailboxFlagInbox) != 0) {
            [result setObject:[folder path] forKey:@"inbox"];
        }
        else if (([folder flags] & LEPIMAPMailboxFlagSentMail) != 0) {
            [result setObject:[folder path] forKey:@"sentmail"];
        }
        else if (([folder flags] & LEPIMAPMailboxFlagStarred) != 0) {
            [result setObject:[folder path] forKey:@"starred"];
        }
        else if (([folder flags] & LEPIMAPMailboxFlagAllMail) != 0) {
            [result setObject:[folder path] forKey:@"allmail"];
        }
        else if (([folder flags] & LEPIMAPMailboxFlagTrash) != 0) {
            [result setObject:[folder path] forKey:@"trash"];
        }
        else if (([folder flags] & LEPIMAPMailboxFlagDrafts) != 0) {
            [result setObject:[folder path] forKey:@"drafts"];
        }
        else if (([folder flags] & LEPIMAPMailboxFlagSpam) != 0) {
            [result setObject:[folder path] forKey:@"spam"];
        }
        else if (([folder flags] & LEPIMAPMailboxFlagImportant) != 0) {
            [result setObject:[folder path] forKey:@"important"];
        }
    }
    
    return result;
}

@end
