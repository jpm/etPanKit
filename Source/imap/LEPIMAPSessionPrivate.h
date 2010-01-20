/*
 *  LEPIMAPSessionPrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 07/01/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

@interface LEPIMAPSession (LEPIMAPSessionPrivate)

- (NSArray *) _fetchSubscribedFolders;
- (NSArray *) _fetchAllFolders;

- (void) _renameFolder:(NSString *)path withNewPath:(NSString *)newPath;
- (void) _deleteFolder:(NSString *)path;
- (void) _createFolder:(NSString *)path;

- (void) _subscribeFolder:(NSString *)path;
- (void) _unsubscribeFolder:(NSString *)path;

@end
