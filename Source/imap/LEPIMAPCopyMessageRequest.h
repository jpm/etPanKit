//
//  LEPIMAPCopyMessageRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 22/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPIMAPRequest.h"

@interface LEPIMAPCopyMessageRequest : LEPIMAPRequest {
	NSArray * _uidSet;
    NSString * _fromPath;
    NSString * _toPath;
}

@property (nonatomic, retain) NSArray * uidSet;
@property (nonatomic, copy) NSString * fromPath;
@property (nonatomic, copy) NSString * toPath;

@end
