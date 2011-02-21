//
//  LEPIMAPNamespaceRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <EtPanKit/LEPIMAPRequest.h>
#import <EtPanKit/LEPConstants.h>

@class LEPIMAPAccount;

@interface LEPIMAPNamespaceRequest : LEPIMAPRequest {
    NSDictionary * _namespaces;
    LEPIMAPAccount * _account;
}

@property (nonatomic, retain) LEPIMAPAccount * account;

// result
@property (nonatomic, retain, readonly) NSDictionary * namespaces;

@end
