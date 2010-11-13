//
//  LEPIMAPFetchFoldersRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 07/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EtPanKit/LEPIMAPRequest.h>

@class LEPIMAPAccount;

@interface LEPIMAPFetchFoldersRequest : LEPIMAPRequest {
	NSArray * _folders;
	LEPIMAPAccount * _account;
}

@property (nonatomic, retain) LEPIMAPAccount * account;

// result
@property (nonatomic, retain, readonly) NSArray * /* LEPIMAPFolder */ folders;

@end
