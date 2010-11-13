//
//  LEPAbstractAlternativeAttachment.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EtPanKit/LEPAbstractAttachment.h>

@interface LEPAbstractAlternativeAttachment : LEPAbstractAttachment <NSCoding, NSCopying> {
	NSArray * _attachments;
}

// array of array of attachments
@property (nonatomic, retain) NSArray * attachments;

@end
