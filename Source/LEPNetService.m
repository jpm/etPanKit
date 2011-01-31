//
//  LEPNetService.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LEPNetService.h"

@implementation LEPNetService

@synthesize hostname = _hostname;
@synthesize port = _port;
@synthesize authType = _authType;

- (id) init
{
    self = [super init];
    
    return self;
}

- (void) dealloc
{
    [_hostname release];
    [super dealloc];
}

- (id) initWithInfo:(NSDictionary *)info
{
    BOOL ssl;
    BOOL starttls;
    
    self = [self init];
    
    [self setHostname:[info objectForKey:@"hostname"]];
    [self setPort:[[info objectForKey:@"port"] intValue]];
    ssl = [[info objectForKey:@"ssl"] boolValue];
    starttls = [[info objectForKey:@"starttls"] boolValue];
    if (ssl) {
        _authType = LEPAuthTypeTLS;
    }
    else if (starttls) {
        _authType = LEPAuthTypeStartTLS;
    }
    else {
        _authType = LEPAuthTypeClear;
    }
    
    return self;
}

@end
