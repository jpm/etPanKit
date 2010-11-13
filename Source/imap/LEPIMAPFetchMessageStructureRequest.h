//
//  LEPIMAPFetchMessageStructureRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EtPanKit/LEPIMAPRequest.h>

@class LEPIMAPMessage;

@interface LEPIMAPFetchMessageStructureRequest : LEPIMAPRequest {
	NSString * _path;
	uint32_t _uid;
	NSArray * _attachments;
	LEPIMAPMessage * _message;
}

@property (nonatomic, copy) NSString * path;
@property (nonatomic, assign) uint32_t uid;
@property (nonatomic, retain) LEPIMAPMessage * message;

// result
@property (nonatomic, readonly, retain) NSArray * attachments;

@end
