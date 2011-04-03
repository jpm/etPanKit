//
//  NSData+MMCharsetDetection.h
//  MiniMail
//
//  Created by DINH Viêt Hoà on 2/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSData (LEPCharsetDetection)

- (NSString *) lepCharsetForFilteredHTML:(BOOL)filterHTML;

@end
