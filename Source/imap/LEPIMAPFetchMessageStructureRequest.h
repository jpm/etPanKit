//
//  LEPIMAPFetchMessageStructureRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPIMAPRequest.h"

@interface LEPIMAPFetchMessageStructureRequest : LEPIMAPRequest {
	NSString * _path;
	uint32_t _uid;
	NSArray * _attachments;
}

@property (nonatomic, copy) NSString * path;
@property (nonatomic) uint32_t uid;

// result
@property (nonatomic, readonly, retain) NSArray * attachments;

@end
