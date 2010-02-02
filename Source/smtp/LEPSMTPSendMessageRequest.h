//
//  LEPSMTPSendMessageRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 02/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPSMTPRequest.h"

@class LEPAddress;

@interface LEPSMTPSendMessageRequest : LEPSMTPRequest {
	NSData * _messageData;
	LEPAddress * _from;
	NSArray * _recipient;
}

@property (nonatomic, retain) NSData * messageData;
@property (nonatomic, retain) LEPAddress * from;
@property (nonatomic, retain) NSArray * recipient;

@end
