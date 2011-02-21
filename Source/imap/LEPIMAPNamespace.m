//
//  LEPIMAPNamespace.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPNamespace.h"
#import "LEPIMAPNamespacePrivate.h"

#import "LEPIMAPNamespaceItem.h"
#include <libetpan/libetpan.h>

@interface LEPIMAPNamespace ()

- (LEPIMAPNamespaceItem *) _itemForPath:(NSString *)path;
- (LEPIMAPNamespaceItem *) _mainItem;

@end


@implementation LEPIMAPNamespace

- (id) init
{
    self = [super init];
    
    _items = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) dealloc
{
    [_items release];
    [super dealloc];
}

- (NSString *) mainPrefix
{
    if ([_items count] == 0)
        return nil;
    
    return [[self prefixes] objectAtIndex:0];
}

- (char) mainDelimiter
{
    if ([_items count] == 0)
        return 0;
    
    return [[_items objectAtIndex:0] delimiter];
}

- (NSArray *) prefixes
{
    NSMutableArray * result;
    
    result = [NSMutableArray array];
    for(LEPIMAPNamespaceItem * item in _items) {
        [result addObject:[item prefix]];
    }
    
    return result;
}

- (LEPIMAPNamespaceItem *) _mainItem
{
    if ([_items count] == 0)
        return nil;
    
    return [_items objectAtIndex:0];
}

- (LEPIMAPNamespaceItem *) _itemForPath:(NSString *)path
{
    for(LEPIMAPNamespaceItem * item in _items) {
        if ([item containsFolderPath:path])
            return item;
    }
    
    return nil;
}

- (NSString *) pathForComponents:(NSArray *)components
{
    return [[self _mainItem] pathForComponents:components];
}

- (NSString *) pathForComponents:(NSArray *)components forPrefix:(NSString *)prefix
{
    return [[self _itemForPath:prefix] pathForComponents:components];
}

- (NSArray *) componentsFromPath:(NSString *)path
{
    LEPIMAPNamespaceItem * item;
    item = [self _itemForPath:path];
    return [item componentsFromPath:path];
}

- (void) _setFromNamespace:(struct mailimap_namespace_item *)item
{
    clistiter * cur;
    
    for(cur = clist_begin(item->ns_data_list) ; cur != NULL ; cur = clist_next(cur)) {
        LEPIMAPNamespaceItem * item;
        struct mailimap_namespace_info * info;
        
        info = clist_content(cur);
        item = [[LEPIMAPNamespaceItem alloc] init];
        [item setFromNamespaceInfo:info];
        [_items addObject:item];
        [item release];
    }
}

- (BOOL) containsFolderPath:(NSString *)path
{
    return ([self _itemForPath:path] != nil);
}

+ (LEPIMAPNamespace *) _defaultNamespaceWithDelimiter:(char)delimiter
{
    return [self namespaceWithPrefix:@"" delimiter:delimiter];
}

+ (LEPIMAPNamespace *) namespaceWithPrefix:(NSString *)prefix delimiter:(char)delimiter
{
    LEPIMAPNamespace * namespace;
    LEPIMAPNamespaceItem * item;
    
    namespace = [[[LEPIMAPNamespace alloc] init] autorelease];
    item = [[LEPIMAPNamespaceItem alloc] init];
    [item setDelimiter:delimiter];
    [item setPrefix:prefix];
    [namespace->_items addObject:item];
    [item release];
    
    return namespace;
}

@end
