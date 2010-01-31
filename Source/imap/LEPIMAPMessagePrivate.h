/*
 *  LEPIMAPMessagePrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 27/01/2010.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "LEPIMAPMessage.h"

@interface LEPIMAPMessage (LEPIMAPMessagePrivate)

- (void) _setUid:(uint32_t)uid;
- (void) _setFlags:(LEPIMAPMessageFlag)flags;
- (void) _setFolder:(LEPIMAPFolder *)folder;

@end
