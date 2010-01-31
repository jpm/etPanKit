//
//  LEPAddress.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 30/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPAddress.h"
#import <libetpan/libetpan.h>
#import "LEPAddressPrivate.h"
#import "NSString+LEP.h"

@implementation LEPAddress

@synthesize displayName = _displayName;
@synthesize mailbox = _mailbox;

- (id) init
{
    self = [super init];
    
    return self;
}

- (void) dealloc
{
    [_displayName release];
    [_mailbox release];
    [super dealloc];
}

- (id) copyWithZone:(NSZone *)zone
{
    LEPAddress * aCopy;
    
    aCopy = [[LEPAddress alloc] init];
    [aCopy setDisplayName:[self displayName]];
    [aCopy setMailbox:[self mailbox]];
    
    return aCopy;
}

+ (LEPAddress *) addressWithDisplayName:(NSString *)displayName mailbox:(NSString *)mailbox
{
	LEPAddress * address;
	
	address = [[LEPAddress alloc] init];
	[address setDisplayName:displayName];
	[address setMailbox:mailbox];
	
	return [address autorelease];
}

+ (LEPAddress *) addressWithMailbox:(NSString *)mailbox
{
	return [self addressWithDisplayName:nil mailbox:mailbox];
}

+ (LEPAddress *) addressWithIMAPAddress:(struct mailimap_address *)imap_addr
{
    char * dsp_name;
    LEPAddress * address;
    NSString * mailbox;
    
    if (imap_addr->ad_personal_name == NULL)
        dsp_name = NULL;
    else {
        dsp_name = imap_addr->ad_personal_name;
    }
    
    if (imap_addr->ad_host_name == NULL) {
        char * addr;
        
        if (imap_addr->ad_mailbox_name == NULL) {
            addr = "";
        }
        else {
            addr = imap_addr->ad_mailbox_name;
        }
        mailbox = [NSString stringWithUTF8String:addr];
    }
    else if (imap_addr->ad_mailbox_name == NULL) {
        // fix by Gabor Cselle, (http://gaborcselle.com/), reported 8/16/2009
        mailbox = [NSString stringWithFormat:@"@%@", [NSString stringWithUTF8String:imap_addr->ad_host_name]];
    }
    else {
        mailbox = [NSString stringWithFormat:@"%@@%@", [NSString stringWithUTF8String:imap_addr->ad_mailbox_name], [NSString stringWithUTF8String:imap_addr->ad_host_name]];
    }
    
    address = [[LEPAddress alloc] init];
    if (dsp_name != NULL) {
        [address setDisplayName:[NSString lepStringByDecodingMIMEHeaderValue:dsp_name]];
    }
    [address setMailbox:mailbox];
    
    return [address autorelease];
}

+ (LEPAddress *) addressWithIMFMailbox:(struct mailimf_mailbox *)mailbox
{
    LEPAddress * address;
	
    address = [[LEPAddress alloc] init];
	if (mailbox->mb_display_name != NULL) {
		[address setDisplayName:[NSString lepStringByDecodingMIMEHeaderValue:mailbox->mb_display_name]];
	}
	if (mailbox->mb_addr_spec != NULL) {
		[address setMailbox:[NSString stringWithUTF8String:mailbox->mb_addr_spec]];
	}
	
    return [address autorelease];
}

- (struct mailimf_mailbox *) createIMFMailbox
{
	struct mailimf_mailbox * result;
	char * display_name;
	char * addr_spec;
	
	display_name = NULL;
	if ([self displayName] != nil) {
		display_name = strdup([[[self displayName] lepEncodedMIMEHeaderValue] bytes]);
	}
	addr_spec = strdup([[self mailbox] UTF8String]);
	result = mailimf_mailbox_new(display_name, addr_spec);
	
	return result;
}

- (struct mailimf_address *) createIMFAddress
{
	struct mailimf_mailbox * mailbox;
	struct mailimf_address * result;
	
	mailbox = [self createIMFMailbox];
	result = mailimf_address_new(MAILIMF_ADDRESS_MAILBOX, mailbox, NULL);
	
	return result;
}

@end
