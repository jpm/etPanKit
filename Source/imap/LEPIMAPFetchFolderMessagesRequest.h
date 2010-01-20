//
//  LEPIMAPFetchFolderMessagesRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 20/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPIMAPRequest.h"

@interface LEPIMAPFetchFolderMessagesRequest : LEPIMAPRequest {
	NSArray * _messages;
}

@property (nonatomic, readonly) NSArray * /* LEPIMAPMessage */ messages;

@end
