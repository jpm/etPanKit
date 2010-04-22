//
//  LEPIMAPLogoutRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 22/04/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPLogoutRequest.h"

#import "LEPIMAPSession.h"
#import "LEPIMAPSessionPrivate.h"

@implementation LEPIMAPLogoutRequest

- (void) mainRequest
{
	[_session _logout];
}

- (void) mainFinished
{
    [_session _logoutDone];
}

@end
