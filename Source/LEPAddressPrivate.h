/*
 *  LEPAddressPrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 31/01/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

@interface LEPAddress (LEPAddressPrivate)

+ (LEPAddress *) addressWithIMAPAddress:(struct mailimap_address *)imap_addr;
+ (LEPAddress *) addressWithIMFMailbox:(struct mailimf_mailbox *)mailbox;
+ (LEPAddress *) addressWithNonEncodedIMFMailbox:(struct mailimf_mailbox *)mailbox;
- (struct mailimf_mailbox *) createIMFMailbox;
- (struct mailimf_address *) createIMFAddress;

@end
