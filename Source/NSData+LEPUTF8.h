//
//  NSData+LEPUTF8.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 05/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (LEPUTF8)

- (NSString *) lepUTF8String;
- (NSString *) lepStringWithCharset:(NSString *)charset;
- (NSString *) lepStringWithDetectedCharset;
- (NSString *) lepHTMLStringWithDetectedCharset;

@end
