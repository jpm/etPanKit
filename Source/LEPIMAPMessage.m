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

- (LEPIMAPFetchMessageRequest *) fetchRequest
{
    return nil;
}

- (LEPIMAPFetchMessageBodyRequest *) fetchMessageBodyRequest
{
    return nil;
}

@end
