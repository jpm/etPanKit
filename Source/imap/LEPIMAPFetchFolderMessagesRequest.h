//
//  LEPIMAPFetchFolderMessagesRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 20/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPIMAPRequest.h"
#import "LEPConstants.h"

@interface LEPIMAPFetchFolderMessagesRequest : LEPIMAPRequest {
	NSArray * _messages;
    uint32_t _fromUID;
    uint32_t _toUID;
    NSString * _path;
    LEPIMAPMessagesRequestKind _fetchKind;
}

@property (nonatomic, copy) NSString * path;
@property (nonatomic) uint32_t fromUID;
@property (nonatomic) uint32_t toUID;
@property (nonatomic) LEPIMAPMessagesRequestKind fetchKind;

@property (nonatomic, readonly) NSArray * /* LEPIMAPMessage */ messages;

@end
