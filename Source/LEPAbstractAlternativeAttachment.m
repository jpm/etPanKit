//
//  LEPAbstractAlternativeAttachment.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPAbstractAlternativeAttachment.h"

@implementation LEPAbstractAlternativeAttachment

@synthesize attachments = _attachments;

- (id) init
{
	self = [super init];
	
	return self;
}

- (void) dealloc
{
	[_attachments release];
	[super dealloc];
}

- (void) setMessage:(LEPAbstractMessage *)message
{
	_message = message;
	for(NSArray * oneAlternative in _attachments) {
		for(LEPAbstractAttachment * attachment in oneAlternative) {
			[attachment setMessage:message];
		}
	}
}

- (NSString *) description
{
	NSMutableString * result;

	result = [NSMutableString string];
	[result appendFormat:@"{%@: 0x%p %@\n", [self class], self, [self mimeType]];
	for(NSArray * oneAlternative in _attachments) {
		[result appendFormat:@"  {"];
		for(unsigned int i = 0 ; i < [oneAlternative count] ; i ++) {
			LEPAbstractAttachment * attachment;
			
			attachment = [oneAlternative objectAtIndex:i];
			if (i == [oneAlternative count] - 1) {
				[result appendFormat:@"%@", attachment];
			}
			else {
				[result appendFormat:@"%@, ", attachment];
			}
		}
		[result appendFormat:@"}\n"];
	}
	[result appendFormat:@"}"];
	
	return result;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	
	_attachments = [[decoder decodeObjectForKey:@"attachments"] retain];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_attachments forKey:@"attachments"];
}

- (id) copyWithZone:(NSZone *)zone
{
    LEPAbstractAlternativeAttachment * attachment;
    
    attachment = [super copyWithZone:zone];
    
    NSMutableArray * alternatives;
    
    alternatives = [[NSMutableArray alloc] init];
    for(NSArray * oneAlternative in [self attachments]) {
        NSMutableArray * attachments;
        
        attachments = [[NSMutableArray alloc] init];
        for(LEPAbstractAttachment * attachment in oneAlternative) {
            [attachments addObject:[[attachment copy] autorelease]];
        }
        [alternatives addObject:attachments];
        [attachments release];
    }
    
	[attachment setAttachments:alternatives];
	
    [alternatives release];
    
    return attachment;
}

@end
