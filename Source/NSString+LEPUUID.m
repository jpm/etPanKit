//
//  NSString+LEPUUID.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+LEPUUID.h"


@implementation NSString (LEPUUID)

+ (NSString *) lepUUIDString
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString * newUUID = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [newUUID autorelease];
}

@end
