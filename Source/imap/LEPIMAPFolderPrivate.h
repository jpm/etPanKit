/*
 *  LEPIMAPFolderPrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 18/01/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

@interface LEPIMAPFolder (LEPIMAPFolderPrivate)

- (void) _setDelimiter:(char)delimiter;
- (void) _setPath:(NSString *)path;
- (void) _setFlags:(int)flags;
- (void) _setAccount:(LEPIMAPAccount *)account;

- (void) _setUidValidity:(uint32_t)uidValidity;
- (void) _setUidNext:(uint32_t)uidNext;

@end
