/*
 *  LEPIMAPSessionPrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 07/01/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "LEPIMAPSession.h"
#import "LEPIMAPMessage.h"

@class LEPIMAPFolder;
@class LEPIMAPAccount;

@interface LEPIMAPSession (LEPIMAPSessionPrivate)

- (void) _selectIfNeeded:(NSString *)mailbox;

- (NSArray *) _fetchSubscribedFoldersWithAccount:(LEPIMAPAccount *)account;
- (NSArray *) _fetchAllFoldersWithAccount:(LEPIMAPAccount *)account;

- (void) _renameFolder:(NSString *)path withNewPath:(NSString *)newPath;
- (void) _deleteFolder:(NSString *)path;
- (void) _createFolder:(NSString *)path;

- (void) _subscribeFolder:(NSString *)path;
- (void) _unsubscribeFolder:(NSString *)path;

- (void) _appendMessageData:(NSData *)messageData flags:(LEPIMAPMessageFlag)flags toPath:(NSString *)path;
- (void) _copyMessages:(NSArray * /* NSNumber */)uidSet fromPath:(NSString *)fromPath toPath:(NSString *)toPath;

- (void) _expunge:(NSString *)path;

- (NSArray *) _fetchFolderMessages:(NSString *)path fromUID:(uint32_t)fromUID toUID:(uint32_t)toUID kind:(LEPIMAPMessagesRequestKind)kind folder:(LEPIMAPFolder *)folder;

- (NSData *) _fetchMessageWithUID:(uint32_t)uid path:(NSString *)path;
- (NSArray *) _fetchMessageStructureWithUID:(uint32_t)uid path:(NSString *)path message:(LEPIMAPMessage *)message;

- (NSData *) _fetchAttachmentWithPartID:(NSString *)partID UID:(uint32_t)uid path:(NSString *)path encoding:(int)encoding;

- (void) _select:(NSString *)mailbox;

- (void) _storeFlags:(LEPIMAPMessageFlag)flags kind:(LEPIMAPStoreFlagsRequestKind)kind messagesUids:(NSArray *)uids path:(NSString *)path;

- (void) _idlePrepare;
- (void) _idleUnprepare;
- (void) _idlePath:(NSString *)path;
- (void) _idleDone;

@end
