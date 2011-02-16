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

- (id) copyWithZone:(NSZone *)zone
{
    return [[LEPNetService netServiceWithInfo:[self info]] retain];
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

- (NSDictionary *) info
{
    NSMutableDictionary * result;
    
    result = [NSMutableDictionary dictionary];
    if ([self hostname] != nil) {
        [result setObject:[self hostname] forKey:@"hostname"];
    }
    if ([self port] != 0) {
        [result setObject:[NSNumber numberWithInt:[self port]] forKey:@"port"];
    }
    switch (_authType & LEPAuthTypeConnectionMask) {
        case LEPAuthTypeTLS:
            [result setObject:[NSNumber numberWithBool:YES] forKey:@"ssl"];
            break;
        case LEPAuthTypeStartTLS:
            [result setObject:[NSNumber numberWithBool:YES] forKey:@"starttls"];
            break;
    }
    
    return result;
}

+ (LEPNetService *) netServiceWithInfo:(NSDictionary *)info
{
    return [[[LEPNetService alloc] initWithInfo:info] autorelease];
}

@end
