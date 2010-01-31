//
//  LEPIMAPFetchAllFoldersRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 18/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPIMAPRequest.h"

@class LEPIMAPAccount;

@interface LEPIMAPFetchAllFoldersRequest : LEPIMAPRequest {
	LEPIMAPAccount * _account;
	NSArray * _folders;
}

@property (nonatomic, retain) LEPIMAPAccount * account;

// result
@property (nonatomic, retain, readonly) NSArray * folders;

@end
