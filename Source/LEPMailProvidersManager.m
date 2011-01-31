//
//  LEPMailProviders.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LEPMailProvidersManager.h"
#import "LEPSingleton.h"
#import "LEPMailProvider.h"

@implementation LEPMailProvidersManager

+ (LEPMailProvidersManager *) sharedManager
{
    LEPSINGLETON(LEPMailProvidersManager)
}

- (id) init
{
    NSString * filename;
    NSDictionary * providersInfos;
    
    self = [super init];
    
    _providers = [[NSMutableDictionary alloc] init];
    
    filename =  [[NSBundle bundleForClass:[self class]] pathForResource:@"provider-info" ofType:@"plist"];
    providersInfos = [[NSDictionary alloc] initWithContentsOfFile:filename];
    for(NSString * identifier in providersInfos) {
        LEPMailProvider * provider;
        
        provider = [[LEPMailProvider alloc] initWithInfo:[providersInfos objectForKey:identifier]];
        [provider setIdentifier:identifier];
        [_providers setObject:provider forKey:identifier];
        [provider release];
    }
    [providersInfos release];
    
    return self;
}

- (void) dealloc
{
    [_providers release];
    [super dealloc];
}

- (LEPMailProvider *) providerForEmail:(NSString *)email
{
    for(NSString * identifier in _providers) {
        LEPMailProvider * provider;
        
        provider = [_providers objectForKey:identifier];
        if ([provider matchEmail:email])
            return provider;
    }
    
    return nil;
}

- (LEPMailProvider *) providerForIdentifier:(NSString *)identifier
{
    return [_providers objectForKey:identifier];
}

@end
