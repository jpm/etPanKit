//
//  NSString+LEP.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (LEP)

+ (NSString *) lepStringByDecodingMIMEHeaderValue:(const char *)phrase;
- (NSData *) lepEncodedMIMEHeaderValue;

- (NSString*) lepFlattenHTML;

@end
