//
//  LEPIMAPNamespaceItem.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPNamespaceItem.h"
#include <libetpan/libetpan.h>
#import "NSString+LEP.h"

@implementation LEPIMAPNamespaceItem

@synthesize prefix = _prefix;
@synthesize delimiter = _delimiter;

- (id) init
{
    self = [super init];
    
    return self;
}

- (void) dealloc
{
    [_prefix release];
    [super dealloc];
}

- (NSString *) prefixWithDelimiter:(BOOL)withDelimiter
{
    if (withDelimiter) {
        return _prefix;
    }
    else {
        if ([_prefix hasSuffix:[NSString stringWithFormat:@"%c", _delimiter]]) {
            return [_prefix substringToIndex:[_prefix length] - 1];
        }
        else {
            return _prefix;
        }
    }
}

- (char) delimiter
{
    return _delimiter;
}

- (void) setFromNamespaceInfo:(struct mailimap_namespace_info *)info
{
    [self setPrefix:[NSString stringWithUTF8String:info->ns_prefix]];
    [self setDelimiter:info->ns_delimiter];
}

- (NSArray *) _encodedComponents:(NSArray *)components
{
    NSMutableArray * result;
    
    result = [NSMutableArray array];
    for(NSString * value in components) {
        [result addObject:[value lepEncodeToModifiedUTF7]];
    }
    
    return result;
}

- (NSArray *) _decodedComponents:(NSArray *)components
{
    NSMutableArray * result;
    
    result = [NSMutableArray array];
    for(NSString * value in components) {
        [result addObject:[value lepDecodeFromModifiedUTF7]];
    }
    
    return result;
}

- (NSString *) pathForComponents:(NSArray *)components
{
    NSString * path;
    NSString * prefix;
    
    components = [self _encodedComponents:components];
    path = [components componentsJoinedByString:[NSString stringWithFormat:@"%c", _delimiter]];
    
    prefix = _prefix;
    if ([prefix length] > 0) {
        if (![prefix hasSuffix:[NSString stringWithFormat:@"%c", _delimiter]]) {
            prefix = [prefix stringByAppendingFormat:@"%c", _delimiter];
        }
    }
    return [prefix stringByAppendingString:path];
}

- (BOOL) containsFolderPath:(NSString *)path
{
    if ([_prefix length] == 0)
        return YES;
    return [path hasPrefix:_prefix];
}

- (NSArray *) componentsFromPath:(NSString *)path
{
    NSArray * components;
    NSMutableArray * result;
    
    if ([path hasPrefix:_prefix]) {
        path = [path substringFromIndex:[_prefix length]];
    }
    components = [path componentsSeparatedByString:[NSString stringWithFormat:@"%c", _delimiter]];
    components = [self _decodedComponents:components];
    result = [components mutableCopy];
    if ([result count] > 0) {
        if ([[result objectAtIndex:0] length] == 0) {
            [result removeObjectAtIndex:0];
        }
    }
    
    return [result autorelease];
}

@end
