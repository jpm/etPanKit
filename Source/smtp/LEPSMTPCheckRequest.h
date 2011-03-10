//
//  LEPSMTPCheckRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 11/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EtPanKit/LEPSMTPRequest.h>
#import <EtPanKit/LEPConstants.h>

@interface LEPSMTPCheckRequest : LEPSMTPRequest {
    LEPAuthType _authType;
}

@property (nonatomic, assign, readonly) LEPAuthType authType;

@end
