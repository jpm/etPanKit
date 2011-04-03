//
//  NSData+LEPUTF8.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 05/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSData+LEPUTF8.h"
#import <libetpan/libetpan.h>
#import "NSData+LEPCharsetDetection.h"

@implementation NSData (LEPUTF8)

- (NSString *) lepUTF8String
{
	return [[[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding] autorelease];
}

- (NSString *) lepStringWithCharset:(NSString *)charset
{
	char * utf8str;
	NSString * result;
	
#if 0
    utf8str = NULL;
	charconv("utf-8", (char *) [charset UTF8String], (char *) [self bytes], [self length], &utf8str);
    if (utf8str == NULL) {
        result = nil;
    }
    else {
        result = [NSString stringWithUTF8String:utf8str];
    }
	free(utf8str);
#else
    size_t utf8len;
    utf8len = 0;
    utf8str = NULL;
    charconv_buffer("utf-8", (char *) [charset UTF8String],
                        (char *) [self bytes], [self length],
                    &utf8str, &utf8len);
    for(size_t i = 0 ; i < utf8len ; i ++) {
        if (utf8str[i] == 0) {
            utf8str[i] = ' ';
        }
    }
    //fprintf(stderr, "%u %u\n", strlen(utf8str), utf8len);
    if (utf8str == NULL) {
        result = nil;
    }
    else {
        result = [NSString stringWithUTF8String:utf8str];
    }
    charconv_buffer_free(utf8str);
#endif
	
	return result;
}

- (NSString *) lepStringWithDetectedCharset
{
    NSString * charset;
    
    charset = [self lepCharsetForFilteredHTML:NO];
    if (charset == nil) {
        charset = @"iso-8859-1";
    }
    
    return [self lepStringWithCharset:charset];
}

- (NSString *) lepHTMLStringWithDetectedCharset
{
    NSString * charset;
    
    charset = [self lepCharsetForFilteredHTML:YES];
    if (charset == nil) {
        charset = @"iso-8859-1";
    }
    
    return [self lepStringWithCharset:charset];
}

@end
