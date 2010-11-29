//
//  LEPSMTPAccount.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 04/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EtPanKit/LEPConstants.h>

@class LEPSMTPRequest;
@class LEPMessage;
@class LEPSMTPSession;

@interface LEPSMTPAccount : NSObject {
    NSString * _host;
    uint16_t _port;
    NSString * _login;
    NSString * _password;
    LEPAuthType _authType;
	NSString * _realm;
	LEPSMTPSession * _session;
    BOOL _checkCertificate;
}

@property (nonatomic, copy) NSString * host;
@property (nonatomic) uint16_t port;
@property (nonatomic, copy) NSString * login;
@property (nonatomic, copy) NSString * password;
@property (nonatomic) LEPAuthType authType;
@property (nonatomic, copy) NSString * realm; // for NTLM
@property (nonatomic, assign) BOOL checkCertificate;

- (LEPSMTPRequest *) sendRequest:(LEPMessage *)message;
- (LEPSMTPRequest *) checkConnectionRequest;

@end
