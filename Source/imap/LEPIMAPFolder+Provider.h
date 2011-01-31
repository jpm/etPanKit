//
//  LEPIMAPFolder+Provider.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <EtPanKit/LEPIMAPFolder.h>

@class LEPMailProvider;

@interface LEPIMAPFolder (Provider)

- (BOOL) isMainFolderForProvider:(LEPMailProvider *)provider;

@end
