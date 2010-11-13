//
//  LEPIMAPAccount+Gmail.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 27/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EtPanKit/LEPIMAPAccount.h>

@interface LEPIMAPAccount (Gmail)

- (void) setGmailMailboxNames:(NSDictionary *)gmailMailboxNames;
- (NSDictionary *) gmailMailboxNames;

- (LEPIMAPFolder *) sentMailFolder;
- (LEPIMAPFolder *) starredFolder;
- (LEPIMAPFolder *) allMailFolder;
- (LEPIMAPFolder *) trashFolder;
- (LEPIMAPFolder *) draftsFolder;
- (LEPIMAPFolder *) spamFolder;
- (LEPIMAPFolder *) importantFolder;

@end
