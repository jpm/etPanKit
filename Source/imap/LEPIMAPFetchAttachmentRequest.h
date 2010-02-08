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
	NSString * _path;
	NSString * _partID;
	uint32_t _uid;
	int _encoding;
}

@property (nonatomic, copy) NSString * path;
@property (nonatomic, copy) NSString * partID;
@property (nonatomic, assign) uint32_t uid;
@property (nonatomic, assign) int encoding;

// result
@property (nonatomic, readonly, retain) NSData * data;

@end
