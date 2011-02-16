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
    NSArray * _resultUidSet;
	NSString * _currentMailbox;
	uint32_t _uidValidity;
	uint32_t _uidNext;
    
    int _idleDone[2];
    BOOL _idling;
    
    id _currentProgressDelegate;
  unsigned int _progressItemsCount;
    BOOL _checkCertificate;
    NSString * _lastMailboxPath;
    
    NSString * _welcomeString;
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
@property (nonatomic, readonly, retain) NSArray * resultUidSet;
@property (nonatomic, readonly, assign) uint32_t uidValidity;
@property (nonatomic, readonly, assign) uint32_t uidNext;
@property (nonatomic, readonly, retain) NSString * welcomeString;

- (void) queueOperation:(LEPIMAPRequest *)request;
- (unsigned int) pendingRequestsCount;

- (void) cancel;

@end
