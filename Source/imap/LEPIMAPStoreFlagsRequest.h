//
//  LEPIMAPStoreFlagsRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 20/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPIMAPRequest.h"
#import "LEPConstants.h"

@class LEPIMAPFolder;

@interface LEPIMAPStoreFlagsRequest : LEPIMAPRequest {
	NSString * _path;
	NSArray * _uids;
	LEPIMAPStoreFlagsRequestKind _kind;
	LEPIMAPMessageFlag _flags;
}

@property (nonatomic, copy) NSString * path;
@property (nonatomic, retain) NSArray * uids;
@property (nonatomic, assign) LEPIMAPStoreFlagsRequestKind kind;
@property (nonatomic, assign) LEPIMAPMessageFlag flags;

@end
