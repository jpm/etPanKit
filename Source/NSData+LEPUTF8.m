//
//  NSData+LEPUTF8.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 05/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSData+LEPUTF8.h"
#import <libetpan/libetpan.h>

@implementation NSData (LEPUTF8)

- (NSString *) lepUTF8String
{
	return [[[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding] autorelease];
}

- (NSString *) lepStringWithCharset:(NSString *)charset
{
	char * utf8str;
	NSString * result;
	
	charconv("utf-8", (char *) [charset UTF8String], (char *) [self bytes], [self length], &utf8str);
	result = [NSString stringWithUTF8String:utf8str];
	free(utf8str);
	
	return result;
}

@end
