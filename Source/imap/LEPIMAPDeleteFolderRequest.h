//
//  LEPIMAPDeleteFolderRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 20/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPIMAPRequest.h"

@interface LEPIMAPDeleteFolderRequest : LEPIMAPRequest {
	NSString * _path;
}

@property (nonatomic, copy) NSString * path;

@end
