//
//  LEPIMAPFetchAttachmentRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EtPanKit/LEPIMAPRequest.h>
#import <EtPanKit/LEPConstants.h>

@interface LEPIMAPFetchAttachmentRequest : LEPIMAPRequest {
	NSData * _data;
	NSString * _path;
	NSString * _partID;
	uint32_t _uid;
	int _encoding;
    size_t _size;
    size_t _currentProgress;
    size_t _maximumProgress;
    LEPIMAPWorkaround _workaround;
}

@property (nonatomic, copy) NSString * path;
@property (nonatomic, copy) NSString * partID;
@property (nonatomic, assign) uint32_t uid;
@property (nonatomic, assign) int encoding;
@property (nonatomic, assign) size_t size;
@property (nonatomic, assign) LEPIMAPWorkaround workaround;

// result
@property (nonatomic, readonly, retain) NSData * data;

// progress
@property (nonatomic, assign, readonly) size_t currentProgress;
@property (nonatomic, assign, readonly) size_t maximumProgress;

@end
