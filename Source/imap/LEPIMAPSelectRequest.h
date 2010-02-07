//
//  LEPIMAPSelectRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 07/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPIMAPRequest.h"

@class LEPIMAPFolder;

@interface LEPIMAPSelectRequest : LEPIMAPRequest {
	NSString * _path;
	LEPIMAPFolder * _folder;
}

@property (nonatomic, copy) NSString * path;
@property (nonatomic, retain) LEPIMAPFolder * folder;

@end
