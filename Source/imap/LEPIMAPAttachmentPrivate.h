/*
 *  LEPIMAPAttachmentPrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 03/02/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "LEPIMAPAttachment.h"

@interface LEPIMAPAttachment (LEPAttachmentPrivate)

+ (NSArray *) attachmentsWithIMAPBody:(struct mailimap_body *)body;

- (void) _setPartID:(NSString *)partID;
- (void) _setSize:(size_t)size;
- (void) _setEncoding:(int)encoding;

@end
