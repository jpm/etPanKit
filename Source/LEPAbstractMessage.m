//
//  LEPAbstractMessage.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPAbstractMessage.h"
#import "LEPUtils.h"

@implementation LEPAbstractMessage

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
	[super dealloc];
}

- (NSString *) messageID
{
    LEPCrash();
    return nil;
}

- (NSArray *) references
{
    LEPCrash();
    return nil;
}

- (NSArray *) inReplyTo
{
    LEPCrash();
    return nil;
}

- (LEPAddress *) from
{
    LEPCrash();
    return nil;
}

- (NSArray *) to
{
    LEPCrash();
    return nil;
}

- (NSArray *) cc
{
    LEPCrash();
    return nil;
}

- (NSArray *) bcc
{
    LEPCrash();
    return nil;
}

- (NSArray *) replyTo
{
    LEPCrash();
    return nil;
}

- (NSString *) subject
{
    LEPCrash();
    return nil;
}

- (NSDate *) date
{
    LEPCrash();
    return nil;
}

@end
