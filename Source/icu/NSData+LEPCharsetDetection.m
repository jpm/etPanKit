//
//  NSData+LEPCharsetDetection.m
//  MiniMail
//
//  Created by DINH Viêt Hoà on 2/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSData+LEPCharsetDetection.h"

#define LEPICU_DISABLED 1

#if !LEPICU_DISABLED
#include "unicode/ucsdet.h"
#endif

@implementation NSData (LEPCharsetDetection)

- (NSString *) lepCharsetForFilteredHTML:(BOOL)filterHTML
{
#if LEPICU_DISABLED
    return nil;
#else
    UCharsetDetector * detector;
    const UCharsetMatch * match;
    UErrorCode err = U_ZERO_ERROR;
    const char * cName;
    NSString * result;
    
    detector = ucsdet_open(&err);
    ucsdet_setText(detector, [self bytes], [self length], &err);
    ucsdet_enableInputFilter(detector, filterHTML);
    match = ucsdet_detect(detector, &err);
    if (match == NULL) {
        ucsdet_close(detector);
        return NULL;
    }
    
    cName = ucsdet_getName(match, &err);
    
    result = [NSString stringWithUTF8String:cName];
    ucsdet_close(detector);
    
    return result;
#endif
}

@end
