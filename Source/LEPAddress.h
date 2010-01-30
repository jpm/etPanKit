//
//  LEPAddress.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 30/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LEPAddress : NSObject <NSCopying> {
	NSString * _displayName;
    NSString * _mailbox;
}

@property (nonatomic, copy) NSString * displayName;
@property (nonatomic, copy) NSString * mailbox;

@end
