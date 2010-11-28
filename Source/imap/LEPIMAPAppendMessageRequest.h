//
//  LEPIMAPAppendMessageRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 22/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPIMAPRequest.h"
#import "LEPConstants.h"

@interface LEPIMAPAppendMessageRequest : LEPIMAPRequest {
    NSData * _data;
    NSString * _path;
    LEPIMAPMessageFlag _flags;
    size_t _currentProgress;
    size_t _maximumProgress;
}

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * path;
@property (nonatomic) LEPIMAPMessageFlag flags;

// progress
@property (nonatomic, assign, readonly) size_t currentProgress;
@property (nonatomic, assign, readonly) size_t maximumProgress;

@end
