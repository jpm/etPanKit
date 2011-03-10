//
//  LEPIMAPCheckRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <EtPanKit/LEPIMAPRequest.h>
#import <EtPanKit/LEPConstants.h>

@interface LEPIMAPCheckRequest : LEPIMAPRequest {
    LEPAuthType _authType;
}

@property (nonatomic, assign, readonly) LEPAuthType authType;

@end
