//
//  LEPIMAPNamespaceItem.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LEPIMAPNamespaceItem : NSObject {
    char _delimiter;
    NSString * _prefix;
}

@property (nonatomic, copy) NSString * prefix;
@property (nonatomic, assign) char delimiter;

- (NSString *) pathForComponents:(NSArray *)components;
- (NSArray *) componentsFromPath:(NSString *)path;

- (BOOL) containsFolderPath:(NSString *)path;

- (void) setFromNamespaceInfo:(struct mailimap_namespace_info *)info;

@end
