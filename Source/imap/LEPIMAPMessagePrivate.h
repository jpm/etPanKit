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

- (void) _setupRequest:(LEPIMAPRequest *)request;
- (void) _setUid:(uint32_t)uid;
- (void) _setAttachments:(NSArray *)attachments;

@end
