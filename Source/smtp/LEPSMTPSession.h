//
//  LEPSMTPSession.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 06/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LEPSMTPRequest;

@interface LEPSMTPSession : NSObject {
	NSOperationQueue * _queue;
	NSError * _error;
}

- (void) queueOperation:(LEPSMTPRequest *)request;

@end
