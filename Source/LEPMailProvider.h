//
//  LEPMailProvider.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LEPNetService;

@interface LEPMailProvider : NSObject {
    NSString * _identifier;
    NSArray * _domainMatch;
    NSMutableArray * _imapServices;
    NSMutableArray * _smtpServices;
    NSMutableArray * _popServices;
    NSDictionary * _mailboxPaths;
    NSMutableSet * _mxSet;
}

@property (nonatomic, copy) NSString * identifier;

- (id) initWithInfo:(NSDictionary *)info;

- (NSArray * /* LEPNetService */) imapServices;
- (NSArray * /* LEPNetService */) smtpServices;
- (NSArray * /* LEPNetService */) popServices;

- (BOOL) matchEmail:(NSString *)email;
- (BOOL) matchMX:(NSString *)hostname;

- (NSString *) sentMailFolderPath;
- (NSString *) starredFolderPath;
- (NSString *) allMailFolderPath;
- (NSString *) trashFolderPath;
- (NSString *) draftsFolderPath;
- (NSString *) spamFolderPath;
- (NSString *) importantFolderPath;

- (BOOL) isMainFolder:(NSString *)folderPath prefix:(NSString *)prefix;

@end
