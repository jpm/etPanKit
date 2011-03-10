/*
 *  LEPSMTPSessionPrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 02/02/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "LEPSMTPSession.h"

@class LEPAddress;
@protocol LEPSMTPSessionProgressDelegate;

@interface LEPSMTPSession (LEPSMTPSessionPrivate)

- (void) _sendMessage:(NSData *)messageData from:(LEPAddress *)from recipient:(NSArray *)recipient
     progressDelegate:(id <LEPSMTPSessionProgressDelegate>)progressDelegate;
- (LEPAuthType) _checkConnection;

@end

@protocol LEPSMTPSessionProgressDelegate

- (void) LEPSMTPSession:(LEPSMTPSession *)session progressWithCurrent:(size_t)current maximum:(size_t)maximum;

@end

