//
//  LEPIMAPAttachment.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPAttachment.h"

@implementation LEPIMAPAttachment

@synthesize filename = _filename;
@synthesize mimeType = _mimeType;

- (LEPIMAPFetchAttachmentRequest *) fetchRequest
{
#warning should be implemented
    return nil;
}

@end

@implementation LEPIMAPFetchAttachmentRequest

@end
