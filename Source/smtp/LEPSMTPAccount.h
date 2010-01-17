//
//  LEPSMTPAccount.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 04/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPConstants.h"

@class LEPSMTPRequest;
@class LEPMessage;

@interface LEPSMTPAccount : NSObject {
    NSString * _host;
    uint16_t _port;
    NSString * _login;
    NSString * _password;
    LEPAuthType _authType;
}

@property (nonatomic, copy) NSString * host;
@property (nonatomic) uint16_t port;
@property (nonatomic, copy) NSString * login;
@property (nonatomic, copy) NSString * password;
@property (nonatomic) LEPAuthType authType;

- (LEPSMTPRequest *) sendRequest:(LEPMessage *)message;

@end
