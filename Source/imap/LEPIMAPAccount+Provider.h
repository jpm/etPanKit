//
//  LEPIMAPAccount+Provider.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EtPanKit/LEPIMAPAccount.h>

@class LEPMailProvider;

@interface LEPIMAPAccount (Provider)

- (LEPIMAPFolder *) sentMailFolderForProvider:(LEPMailProvider *)provider;
- (LEPIMAPFolder *) starredFolderForProvider:(LEPMailProvider *)provider;
- (LEPIMAPFolder *) allMailFolderForProvider:(LEPMailProvider *)provider;
- (LEPIMAPFolder *) trashFolderForProvider:(LEPMailProvider *)provider;
- (LEPIMAPFolder *) draftsFolderForProvider:(LEPMailProvider *)provider;
- (LEPIMAPFolder *) spamFolderForProvider:(LEPMailProvider *)provider;
- (LEPIMAPFolder *) importantFolderForProvider:(LEPMailProvider *)provider;

- (void) setXListMapping:(NSDictionary *)mapping;
- (NSDictionary *) XListMapping;

- (void) setupWithFoldersPaths:(NSArray *)paths xListHints:(NSDictionary *)mapping;
+ (NSDictionary *) XListMappingWithFolders:(NSArray * /* LEPIMAPFolder */ )folders;

@end
