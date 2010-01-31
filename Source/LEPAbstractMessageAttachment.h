//
//  LEPAbstractMessageAttachment.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPAbstractAttachment.h"

@class LEPMessageHeader;

@interface LEPAbstractMessageAttachment : LEPAbstractAttachment {
	LEPMessageHeader * _header;
}

@property (nonatomic, retain, readonly) LEPMessageHeader * header;

@end
