//
//  LEPAbstractMessageAttachment.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EtPanKit/LEPAbstractAttachment.h>

@class LEPMessageHeader;

@interface LEPAbstractMessageAttachment : LEPAbstractAttachment <NSCoding, NSCopying> {
	LEPMessageHeader * _header;
	NSArray * /* LEPAttachment */ _attachments;
}

@property (nonatomic, retain, readonly) LEPMessageHeader * header;
@property (nonatomic, retain) NSArray * /* LEPAbstractAttachment */ attachments;

@end
