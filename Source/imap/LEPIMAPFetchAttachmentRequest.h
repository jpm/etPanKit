//
//  LEPIMAPFetchAttachmentRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LEPIMAPRequest.h"

@interface LEPIMAPFetchAttachmentRequest : LEPIMAPRequest {
	NSData * _data;
}

@property (nonatomic, readonly) NSData * data;

@end
