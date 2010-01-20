/*
 *  LEPIMAPAccountPrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 18/01/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

@interface LEPIMAPAccount (LEPIMAPAccountPrivate)

- (void) _setSubscribedFolders:(NSArray * )folders;
- (void) _setAllFolders:(NSArray * )folders;
- (LEPIMAPSession *) _session;

- (void) _setupSession;
- (void) _unsetupSession;

@end
