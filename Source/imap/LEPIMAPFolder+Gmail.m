//
//  LEPIMAPFolder+Gmail.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 11/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPFolder+Gmail.h"

#import "LEPIMAPAccountPrivate.h"

@implementation LEPIMAPFolder (Gmail)

- (BOOL) isGmailFolder
{
    return [_account _isGmailFolder:self];
}

@end
