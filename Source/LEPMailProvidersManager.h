//
//  LEPMailProviders.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LEPMailProvider;

@interface LEPMailProvidersManager : NSObject {
    NSMutableDictionary * _providers;
}

+ (LEPMailProvidersManager *) sharedManager;

- (LEPMailProvider *) providerForEmail:(NSString *)email;
- (LEPMailProvider *) providerForMX:(NSString *)hostname;
- (LEPMailProvider *) providerForIdentifier:(NSString *)identifier;
- (void) registerProviders:(NSDictionary *)providers;
- (void) registerProvidersFilename:(NSString *)filename;

@end
