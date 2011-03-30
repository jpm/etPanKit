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

@protocol LEPIMAPSessionProgressDelegate;

@interface LEPIMAPSession (LEPIMAPSessionPrivate)

- (void) _selectIfNeeded:(NSString *)mailbox;

- (NSArray *) _fetchSubscribedFoldersWithAccount:(LEPIMAPAccount *)account;
- (NSArray *) _fetchAllFoldersWithAccount:(LEPIMAPAccount *)account usingXList:(BOOL)useXList;

- (void) _renameFolder:(NSString *)path withNewPath:(NSString *)newPath;
- (void) _deleteFolder:(NSString *)path;
- (void) _createFolder:(NSString *)path;

- (void) _subscribeFolder:(NSString *)path;
- (void) _unsubscribeFolder:(NSString *)path;

- (void) _appendMessageData:(NSData *)messageData flags:(LEPIMAPMessageFlag)flags toPath:(NSString *)path
           progressDelegate:(id <LEPIMAPSessionProgressDelegate>)progressDelegate;

- (void) _copyMessages:(NSArray * /* NSNumber */)uidSet fromPath:(NSString *)fromPath toPath:(NSString *)toPath;

- (void) _expunge:(NSString *)path;

- (NSDictionary *) _fetchFolderMessagesMessageNumberUIDMappingForPath:(NSString *)path fromUID:(uint32_t)fromUID toUID:(uint32_t)toUID;

- (NSArray *) _fetchFolderMessages:(NSString *)path fromUID:(uint32_t)fromUID toUID:(uint32_t)toUID kind:(LEPIMAPMessagesRequestKind)kind folder:(LEPIMAPFolder *)folder
                           mapping:(NSDictionary *)mapping
                  progressDelegate:(id <LEPIMAPSessionProgressDelegate>)progressDelegate;

- (NSArray *) _fetchFolderMessages:(NSString *)path fromUID:(uint32_t)fromUID toUID:(uint32_t)toUID kind:(LEPIMAPMessagesRequestKind)kind folder:(LEPIMAPFolder *)folder
                  progressDelegate:(id <LEPIMAPSessionProgressDelegate>)progressDelegate;

- (NSData *) _fetchMessageWithUID:(uint32_t)uid path:(NSString *)path
                 progressDelegate:(id <LEPIMAPSessionProgressDelegate>)progressDelegate;

- (NSArray *) _fetchMessageStructureWithUID:(uint32_t)uid path:(NSString *)path message:(LEPIMAPMessage *)message;

- (NSData *) _fetchAttachmentWithPartID:(NSString *)partID UID:(uint32_t)uid path:(NSString *)path encoding:(int)encoding
                           expectedSize:(size_t)expectedSize
                       progressDelegate:(id <LEPIMAPSessionProgressDelegate>)progressDelegate;

- (NSString *) _fetchContentTypeWithPartID:(NSString *)partID UID:(uint32_t)uid path:(NSString *)path;

- (void) _select:(NSString *)mailbox;

- (void) _storeFlags:(LEPIMAPMessageFlag)flags kind:(LEPIMAPStoreFlagsRequestKind)kind messagesUids:(NSArray *)uids path:(NSString *)path;

- (BOOL) _idlePrepare;
- (void) _idleUnprepare;
- (void) _idlePath:(NSString *)path lastUID:(int64_t)lastUID;
- (void) _idleDone;

- (NSIndexSet *) _capabilitiesForSelection:(BOOL)selectFirst;
- (NSDictionary *) _namespace;

- (BOOL) _matchLastMailbox:(NSString *)mailbox;
- (void) _setLastMailbox:(NSString *)mailbox;

- (LEPAuthType) _checkConnection;

- (void) _setError:(NSError *)error;

@end

@protocol LEPIMAPSessionProgressDelegate

- (void) LEPIMAPSession:(LEPIMAPSession *)session bodyProgressWithCurrent:(size_t)current maximum:(size_t)maximum;
- (void) LEPIMAPSession:(LEPIMAPSession *)session itemsProgressWithCurrent:(size_t)current maximum:(size_t)maximum;

@end
