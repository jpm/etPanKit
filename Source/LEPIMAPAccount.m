//
//  LEPIMAPAccount.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPAccount.h"

@interface LEPIMAPAccount ()

@property (nonatomic, copy) NSArray * subscribedFolders;
@property (nonatomic, copy) NSArray * allFolders;

@end

@implementation LEPIMAPAccount

@synthesize host = _host;
@synthesize port = _port;
@synthesize login = _login;
@synthesize password = _password;
@synthesize authType = _authType;

@synthesize subscribedFolders = _subscribedFolders;
@synthesize allFolders = _allFolders;

@synthesize idleEnabled = _idleEnabled;

- (LEPIMAPRequest *) fetchSubscribedFoldersRequest
{
#warning should be implemented
    return nil;
}

- (LEPIMAPRequest *) fetchAllFoldersRequest
{
#warning should be implemented
    return nil;
}

- (LEPIMAPRequest *) createFolderRequest:(NSString *)name
{
#warning should be implemented
    return nil;
}

@end
