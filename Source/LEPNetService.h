//
//  LEPNetService.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <EtPanKit/LEPConstants.h>

@interface LEPNetService : NSObject {
    NSString * _hostname;
    int _port;
    LEPAuthType _authType;
}

@property (nonatomic, copy) NSString * hostname;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) LEPAuthType authType;

- (id) initWithInfo:(NSDictionary *)info;

@end
