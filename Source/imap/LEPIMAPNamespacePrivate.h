/*
 *  LEPIMAPNamespacePrivate.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 2/19/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "LEPIMAPNamespace.h"

@interface LEPIMAPNamespace (Private)

- (void) _setFromNamespace:(struct mailimap_namespace_item *)item;

+ (LEPIMAPNamespace *) _defaultNamespaceWithDelimiter:(char)delimiter;

@end
