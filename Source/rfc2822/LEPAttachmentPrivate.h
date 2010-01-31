/*
 *  LEPAttachmentPrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 31/01/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

@interface LEPAttachment (LEPAttachmentPrivate)

+ (NSArray *) attachmentsWithMIME:(struct mailmime *)mime;
+ (LEPAbstractAttachment *) attachmentWithMIME:(struct mailmime *)mime;

@end
