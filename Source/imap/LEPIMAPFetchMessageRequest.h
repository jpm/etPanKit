//
//  LEPIMAPFetchMessageRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EtPanKit/LEPIMAPRequest.h>

@interface LEPIMAPFetchMessageRequest : LEPIMAPRequest {
	NSString * _path;
	uint32_t _uid;
	NSData * _messageData;
    size_t _currentProgress;
    size_t _maximumProgress;
}

@property (nonatomic, copy) NSString * path;
@property (nonatomic) uint32_t uid;

// result
@property (nonatomic, readonly, retain) NSData * messageData;

// progress
@property (nonatomic, assign, readonly) size_t currentProgress;
@property (nonatomic, assign, readonly) size_t maximumProgress;

@end
