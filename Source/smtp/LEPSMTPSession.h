//
//  LEPSMTPSession.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 06/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPConstants.h"

@class LEPSMTPRequest;

@interface LEPSMTPSession : NSObject {
	NSOperationQueue * _queue;
	NSError * _error;
	void * _lepData;
    NSString * _host;
    uint16_t _port;
    NSString * _login;
    NSString * _password;
    LEPAuthType _authType;
	NSString * _realm;
    id _currentProgressDelegate;
    BOOL _checkCertificate;
}

@property (nonatomic, copy) NSString * host;
@property (nonatomic) uint16_t port;
@property (nonatomic, copy) NSString * login;
@property (nonatomic, copy) NSString * password;
@property (nonatomic) LEPAuthType authType;
@property (nonatomic, copy) NSString * realm; // for NTLM
@property (nonatomic, assign) BOOL checkCertificate;

// result
@property (nonatomic, readonly, copy) NSError * error;

- (void) queueOperation:(LEPSMTPRequest *)request;

@end
