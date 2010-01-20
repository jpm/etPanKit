//
//  LEPIMAPRenameFolderRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 20/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPIMAPRequest.h"

@interface LEPIMAPRenameFolderRequest : LEPIMAPRequest {
	NSString * _oldPath;
	NSString * _newPath;
}

@property (nonatomic, copy) NSString * oldPath;
@property (nonatomic, copy) NSString * newPath;

@end
