//
//  LEPIMAPFetchFolderMessagesUIDRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 25/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPIMAPRequest.h"

@interface LEPIMAPFetchFolderMessagesUIDRequest : LEPIMAPRequest {
	NSArray * _messagesUIDs;
    uint32_t _fromUID;
    uint32_t _toUID;
}

@property (nonatomic) uint32_t fromUID;
@property (nonatomic) uint32_t toUID;

@property (nonatomic, readonly) NSArray * /* NSNumber */ messagesUIDs;

@end
