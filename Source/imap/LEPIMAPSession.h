//
//  LEPIMAPSession.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 06/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPConstants.h"

@class LEPIMAPRequest;

@interface LEPIMAPSession : NSObject {
    NSString * _host;
    uint16_t _port;
    NSString * _login;
    NSString * _password;
    LEPAuthType _authType;
	NSString * _realm;
    BOOL _idleEnabled;
	
	void * _lepData;
	NSOperationQueue * _queue;
	
	int _state;
	NSError * _error;
	NSString * _currentMailbox;
}

@property (nonatomic, copy) NSString * host;
@property (nonatomic) uint16_t port;
@property (nonatomic, copy) NSString * login;
@property (nonatomic, copy) NSString * password;
@property (nonatomic) LEPAuthType authType;
@property (nonatomic, copy) NSString * realm; // for NTLM

// result
@property (nonatomic, readonly, copy) NSError * error;

- (void) queueOperation:(LEPIMAPRequest *)request;

@end
