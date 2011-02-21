//
//  LEPIMAPNamespace.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LEPIMAPNamespace : NSObject {
    NSMutableArray * /* LEPIMAPNamespaceItem */ _items;
}

- (NSString *) mainPrefix;
- (char) mainDelimiter;

- (NSArray *) prefixes;

- (NSString *) pathForComponents:(NSArray *)components;
- (NSString *) pathForComponents:(NSArray *)components forPrefix:(NSString *)prefix;

- (NSArray *) componentsFromPath:(NSString *)path;

- (BOOL) containsFolderPath:(NSString *)path;

+ (LEPIMAPNamespace *) namespaceWithPrefix:(NSString *)prefix delimiter:(char)delimiter;

@end
