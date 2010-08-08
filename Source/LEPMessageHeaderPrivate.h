/*
 *  LEPMessageHeaderPrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 31/01/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "LEPMessageHeader.h"

@interface LEPMessageHeader (LEPMessageHeaderPrivate)

//- (id) _initForCopy;

- (void) setFromIMFFields:(struct mailimf_fields *)fields;
- (struct mailimf_fields *) createIMFFields;

- (void) setFromIMAPReferences:(NSData *)data;
- (void) setFromIMAPEnvelope:(struct mailimap_envelope *)env;

@end
