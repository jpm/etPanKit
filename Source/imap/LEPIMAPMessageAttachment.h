//
//  LEPIMAPMessageAttachment.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPAbstractMessageAttachment.h"

@interface LEPIMAPMessageAttachment : LEPAbstractMessageAttachment {
	NSArray * _attachments;
}

@property (nonatomic, retain) NSArray * /* LEPAttachment */ attachments;

@end
