/*
 *  LEPIMAPAccountPrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 18/01/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "LEPIMAPAccount.h"

@interface LEPIMAPAccount (LEPIMAPAccountPrivate)

- (void) _setSubscribedFolders:(NSArray * )folders;
- (void) _setAllFolders:(NSArray * )folders;

- (void) _setupSession;
- (void) _unsetupSession;

- (void) _setupRequest:(LEPIMAPRequest *)request;
- (void) _setupRequest:(LEPIMAPRequest *)request forMailbox:(NSString *)mailbox;

- (BOOL) _isGmailFolder:(LEPIMAPFolder *)folder;
- (BOOL) _isYahooFolder:(LEPIMAPFolder *)folder;
- (BOOL) _isMobileMeFolder:(LEPIMAPFolder *)folder;
- (BOOL) _isAOLFolder:(LEPIMAPFolder *)folder;

- (void) _setDefaultDelimiter:(char)delimiter;
- (void) _setDefaultNamespace:(LEPIMAPNamespace *)ns;

@end
