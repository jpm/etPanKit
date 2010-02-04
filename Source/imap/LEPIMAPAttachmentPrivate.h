/*
 *  LEPIMAPAttachmentPrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 03/02/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

@interface LEPIMAPAttachment (LEPAttachmentPrivate)

+ (NSArray *) attachmentsWithIMAPBody:(struct mailimap_body *)body;

@end
