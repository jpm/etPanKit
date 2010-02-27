//
//  LEPIMAPAccount+Gmail.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 27/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEPIMAPAccount.h"

@interface LEPIMAPAccount (Gmail)

- (LEPIMAPFolder *) sentMailFolder;
- (LEPIMAPFolder *) starredFolder;
- (LEPIMAPFolder *) allMailFolder;
- (LEPIMAPFolder *) draftFolder;
- (LEPIMAPFolder *) trashFolder;

@end
