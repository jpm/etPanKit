//
//  NSData+LEPUTF8.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 05/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSData+LEPUTF8.h"

@implementation NSData (LEPUTF8)

- (NSString *) LEPUTF8String
{
	return [[[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding] autorelease];
}

@end
