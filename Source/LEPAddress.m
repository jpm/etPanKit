//
//  LEPAddress.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 30/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPAddress.h"


@implementation LEPAddress

@synthesize displayName = _displayName;
@synthesize mailbox = _mailbox;

- (id) init
{
    self = [super init];
    
    return self;
}

- (void) dealloc
{
    [_displayName release];
    [_mailbox release];
    [super dealloc];
}

- (id) copyWithZone:(NSZone *)zone
{
    LEPAddress * aCopy;
    
    aCopy = [[LEPAddress alloc] init];
    [aCopy setDisplayName:[self displayName]];
    [aCopy setMailbox:[self mailbox]];
    
    return aCopy;
}

@end
