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
}

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * path;
@property (nonatomic) LEPIMAPMessageFlag flags;

@end
