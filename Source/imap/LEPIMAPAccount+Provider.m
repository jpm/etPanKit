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
    if ([[provider identifier] isEqualToString:GMAIL_PROVIDER_IDENTIFIER]) {
        return [self sentMailFolder];
    }
    
    if ([provider sentMailFolderPath] == nil)
        return nil;
    
	return [self _providerFolderWithPath:[provider sentMailFolderPath]];
}

- (LEPIMAPFolder *) starredFolderForProvider:(LEPMailProvider *)provider
{
    if ([[provider identifier] isEqualToString:GMAIL_PROVIDER_IDENTIFIER]) {
        return [self starredFolder];
    }
    
    if ([provider starredFolderPath] == nil)
        return nil;
    
	return [self _providerFolderWithPath:[provider starredFolderPath]];
}

- (LEPIMAPFolder *) allMailFolderForProvider:(LEPMailProvider *)provider;
{
    if ([[provider identifier] isEqualToString:GMAIL_PROVIDER_IDENTIFIER]) {
        return [self allMailFolder];
    }
    
    if ([provider allMailFolderPath] == nil)
        return nil;
    
	return [self _providerFolderWithPath:[provider allMailFolderPath]];
}

- (LEPIMAPFolder *) trashFolderForProvider:(LEPMailProvider *)provider;
{
    if ([[provider identifier] isEqualToString:GMAIL_PROVIDER_IDENTIFIER]) {
        return [self trashFolder];
    }
    
    if ([provider trashFolderPath] == nil)
        return nil;
    
	return [self _providerFolderWithPath:[provider trashFolderPath]];
}

- (LEPIMAPFolder *) draftsFolderForProvider:(LEPMailProvider *)provider;
{
    if ([[provider identifier] isEqualToString:GMAIL_PROVIDER_IDENTIFIER]) {
        return [self draftsFolder];
    }
    
    if ([provider draftsFolderPath] == nil)
        return nil;
    
	return [self _providerFolderWithPath:[provider draftsFolderPath]];
}

- (LEPIMAPFolder *) spamFolderForProvider:(LEPMailProvider *)provider;
{
    if ([[provider identifier] isEqualToString:GMAIL_PROVIDER_IDENTIFIER]) {
        return [self spamFolder];
    }
    
    if ([provider spamFolderPath] == nil)
        return nil;
    
	return [self _providerFolderWithPath:[provider spamFolderPath]];
}

- (LEPIMAPFolder *) importantFolderForProvider:(LEPMailProvider *)provider;
{
    if ([[provider identifier] isEqualToString:GMAIL_PROVIDER_IDENTIFIER]) {
        return [self importantFolder];
    }
    
    if ([provider importantFolderPath] == nil)
        return nil;
    
	return [self _providerFolderWithPath:[provider importantFolderPath]];
}

@end
