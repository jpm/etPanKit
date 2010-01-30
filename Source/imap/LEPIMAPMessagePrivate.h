/*
 *  LEPIMAPMessagePrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 27/01/2010.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "LEPIMAPMessage.h"

@interface LEPIMAPMessage (LEPIMAPMessagePrivate)

- (void) _setUid:(uint32_t)uid;
- (void) _setFlags:(LEPIMAPMessageFlag)flags;
- (void) _setFolder:(LEPIMAPFolder *)folder;

- (void) _setDate:(NSDate *)date;
- (void) _setMessageID:(NSString *)messageID;
- (void) _setReferences:(NSArray * /* NSString */)references;
- (void) _setInReplyTo:(NSArray * /* NSString */)inReplyTo;
- (void) _setFrom:(LEPAddress *)from;
- (void) _setTo:(NSArray * /* LEPAddress */)to;
- (void) _setCc:(NSArray * /* LEPAddress */)cc;
- (void) _setBcc:(NSArray * /* LEPAddress */)bcc;
- (void) _setReplyTo:(NSArray * /* LEPAddress */)replyTo;
- (void) _setSubject:(NSString *)subject;

@end
