//
//  LEPIMAPFolder+Provider.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPFolder+Provider.h"
#import "LEPIMAPFolder+Gmail.h"

#import "LEPIMAPAccount.h"
#import "LEPIMAPNamespace.h"
#import "LEPMailProvider.h"

@implementation LEPIMAPFolder (Provider)

- (BOOL) isMainFolderForProvider:(LEPMailProvider *)provider
{
    if ([[provider identifier] isEqualToString:@"gmail"]) {
        return [self isGmailFolder];
    }
    else {
        return [provider isMainFolder:[self path] prefix:[[_account defaultNamespace] mainPrefix]];
    }
}

@end
