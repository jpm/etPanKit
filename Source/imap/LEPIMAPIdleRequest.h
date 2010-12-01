//
//  LEPIMAPIdleRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 11/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EtPanKit/LEPIMAPRequest.h>

@interface LEPIMAPIdleRequest : LEPIMAPRequest {
    NSString * _path;
    int64_t _lastUID;
}

@property (nonatomic, copy) NSString * path;
@property (nonatomic, assign) int64_t lastUID;

// call from main thread
- (void) done;

@end
