//
//  LEPIMAPMessage.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPMessage.h"

@interface LEPIMAPMessage ()

@property (nonatomic) LEPIMAPMessageFlag flags;

@end

@implementation LEPIMAPMessage

@synthesize flags = _flags;
@synthesize uid = _uid;
@synthesize folder = _folder;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
    [_uid release];
    [_folder release];
	[super dealloc];
}

- (LEPIMAPFetchMessageRequest *) fetchRequest
{
#warning should be implemented
    return nil;
}

- (LEPIMAPFetchMessageBodyRequest *) fetchMessageBodyRequest
{
#warning should be implemented
    return nil;
}

@end
