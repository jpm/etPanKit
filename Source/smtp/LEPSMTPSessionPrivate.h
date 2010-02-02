/*
 *  LEPSMTPSessionPrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 02/02/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

@interface LEPSMTPSession (LEPSMTPSessionPrivate)

- (void) _sendMessage:(NSData *)messageData from:(LEPAddress *)from recipient:(NSArray *)recipient;

@end

