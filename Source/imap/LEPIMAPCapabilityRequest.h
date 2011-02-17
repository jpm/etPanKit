//
//  LEPIMAPCapabilityRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <EtPanKit/LEPIMAPRequest.h>
#import <EtPanKit/LEPConstants.h>

@interface LEPIMAPCapabilityRequest : LEPIMAPRequest {
    NSIndexSet * _capabilities;
    BOOL _selectionEnabled;
}

@property (nonatomic, assign) BOOL selectionEnabled;

// result
@property (nonatomic, retain, readonly) NSIndexSet * capabilities;

@end
