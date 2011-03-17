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

+ (LEPAddress *) addressWithRFC822String:(NSString *)string
{
    const char * utf8String;
    size_t currentIndex;
    struct mailimf_mailbox * mb;
    int r;
    LEPAddress * result;
    
    utf8String = [string UTF8String];
    currentIndex = 0;
    r = mailimf_mailbox_parse(utf8String, strlen(utf8String), &currentIndex, &mb);
    if (r != MAILIMF_NO_ERROR)
        return nil;
    
    result = [LEPAddress addressWithIMFMailbox:mb];
    mailimf_mailbox_free(mb);
    
    return result;
}

+ (LEPAddress *) addressWithNonEncodedRFC822String:(NSString *)string
{
    const char * utf8String;
    size_t currentIndex;
    struct mailimf_mailbox * mb;
    int r;
    LEPAddress * result;
    
    utf8String = [string UTF8String];
    currentIndex = 0;
    r = mailimf_mailbox_parse(utf8String, strlen(utf8String), &currentIndex, &mb);
    if (r != MAILIMF_NO_ERROR)
        return nil;
    
    result = [LEPAddress addressWithNonEncodedIMFMailbox:mb];
    mailimf_mailbox_free(mb);
    
    return result;
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
#if 0
	if (mailbox != NULL) {
		[address setMailbox:[NSString lepStringByDecodingMIMEHeaderValue:[mailbox UTF8String]]];
	}
#endif
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
    if ([address mailbox] == nil) {
        [address setMailbox:@""];
    }
	
    return [address autorelease];
}

+ (LEPAddress *) addressWithNonEncodedIMFMailbox:(struct mailimf_mailbox *)mailbox
{
    LEPAddress * address;
	
    address = [[LEPAddress alloc] init];
	if (mailbox->mb_display_name != NULL) {
		[address setDisplayName:[NSString stringWithUTF8String:mailbox->mb_display_name]];
	}
	if (mailbox->mb_addr_spec != NULL) {
		[address setMailbox:[NSString stringWithUTF8String:mailbox->mb_addr_spec]];
	}
    if ([address mailbox] == nil) {
        [address setMailbox:@""];
    }
	
    return [address autorelease];
}

- (struct mailimf_mailbox *) createIMFMailbox
{
	struct mailimf_mailbox * result;
	char * display_name;
	char * addr_spec;
	
	display_name = NULL;
	if ([[self displayName] length] > 0) {
        NSData * data;
        
        data = [[self displayName] lepEncodedAddressDisplayNameValue];
        if ([data bytes] != NULL) {
            display_name = strdup([data bytes]);
        }
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

- (NSString *) description
{
	return [NSString stringWithFormat:@"[%@: 0x%p %@ <%@>]", [self class], self, [self displayName], [self mailbox]];
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super init];
	
	_displayName = [[coder decodeObjectForKey:@"displayName"] retain];
	_mailbox = [[coder decodeObjectForKey:@"mailbox"] retain];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_displayName forKey:@"displayName"];
	[encoder encodeObject:_mailbox forKey:@"mailbox"];
}

- (NSString *) nonEncodedRFC822String
{
    struct mailimf_mailbox * mb;
    MMAPString * str;
    int col;
    struct mailimf_mailbox_list * mb_list;
    clist * list;
    NSString * result;
	char * display_name;
	char * addr_spec;
	
	display_name = NULL;
	if ([[self displayName] length] > 0) {
		display_name = strdup([[self displayName] UTF8String]);
	}
	addr_spec = strdup([[self mailbox] UTF8String]);
	mb = mailimf_mailbox_new(display_name, addr_spec);
    
    list = clist_new();
    clist_append(list, mb);
    mb_list = mailimf_mailbox_list_new(list);
    
    str = mmap_string_new("");
    col = 0;
    mailimf_mailbox_list_write_mem(str, &col, mb_list);
    
    result = [NSString stringWithUTF8String:str->str];
    
    mailimf_mailbox_list_free(mb_list);
    mmap_string_free(str);
    
    return result;
}

- (NSString *) RFC822String
{
    struct mailimf_mailbox * mb;
    MMAPString * str;
    int col;
    struct mailimf_mailbox_list * mb_list;
    clist * list;
    NSString * result;
    
    mb = [self createIMFMailbox];

    list = clist_new();
    clist_append(list, mb);
    mb_list = mailimf_mailbox_list_new(list);
    
    str = mmap_string_new("");
    col = 0;
    mailimf_mailbox_list_write_mem(str, &col, mb_list);
    
    result = [NSString stringWithUTF8String:str->str];
    
    mailimf_mailbox_list_free(mb_list);
    mmap_string_free(str);
    
    return result;
}

- (NSUInteger)hash
{
	return [[self displayName] hash] + [[self mailbox] hash];
}

- (BOOL)isEqual:(id)anObject
{
	if (([self displayName] == NULL) && ([anObject displayName] == NULL)) {
		return [[self mailbox] isEqual:[anObject mailbox]];
	}
	
	return ([[self displayName] isEqual:[anObject displayName]] && [[self mailbox] isEqual:[anObject mailbox]]);
}

@end

@implementation LEPAddress (LEPNSArray)

static NSArray * lep_address_list_from_lep_mailbox(struct mailimf_mailbox_list * mb_list, int encoded)
{
	NSMutableArray * result;
	clistiter * cur;
	
	result = [NSMutableArray array];
	for(cur = clist_begin(mb_list->mb_list) ; cur != NULL ; cur = clist_next(cur)) {
		struct mailimf_mailbox * mb;
		LEPAddress * address;
		
		mb = clist_content(cur);
		if (encoded) {
			address = [LEPAddress addressWithIMFMailbox:mb];
		}
		else {
			address = [LEPAddress addressWithNonEncodedIMFMailbox:mb];
		}
		[result addObject:address];
	}
	
	return result;
}

static NSArray * lep_address_list_from_lep_addr(struct mailimf_address_list * addr_list, int encoded)
{
	NSMutableArray * result;
	clistiter * cur;
	
	result = [NSMutableArray array];
	
	for(cur = clist_begin(addr_list->ad_list) ; cur != NULL ;
		cur = clist_next(cur)) {
		struct mailimf_address * addr;
		
		addr = clist_content(cur);
		switch (addr->ad_type) {
			case MAILIMF_ADDRESS_MAILBOX:
			{
				LEPAddress * address;
				
				if (encoded) {
					address = [LEPAddress addressWithIMFMailbox:addr->ad_data.ad_mailbox];
				}
				else {
					address = [LEPAddress addressWithNonEncodedIMFMailbox:addr->ad_data.ad_mailbox];
				}
				[result addObject:address];
				break;
			}
				
			case MAILIMF_ADDRESS_GROUP:
			{
				if (addr->ad_data.ad_group->grp_mb_list != NULL) {
					NSArray * subArray;
					
					subArray = lep_address_list_from_lep_mailbox(addr->ad_data.ad_group->grp_mb_list, encoded);
					[result addObjectsFromArray:subArray];
				}
				break;
			}
		}
	}
	
	return result;
}

+ (NSArray *) addressesWithRFC822String:(NSString *)string
{
	const char * utf8String;
	size_t currentIndex;
	struct mailimf_address_list * addr_list;
	NSArray * result;
	int r;
	
    utf8String = [string UTF8String];
    currentIndex = 0;
	
	r = mailimf_address_list_parse(utf8String, strlen(utf8String), &currentIndex, &addr_list);
    if (r != MAILIMF_NO_ERROR)
        return nil;
	
	result = lep_address_list_from_lep_addr(addr_list, 1);
	mailimf_address_list_free(addr_list);
	
	return result;
}

+ (NSArray *) addressesWithNonEncodedRFC822String:(NSString *)string
{
	const char * utf8String;
	size_t currentIndex;
	struct mailimf_address_list * addr_list;
	NSArray * result;
	int r;
	
    utf8String = [string UTF8String];
    currentIndex = 0;
	
	r = mailimf_address_list_parse(utf8String, strlen(utf8String), &currentIndex, &addr_list);
    if (r != MAILIMF_NO_ERROR)
        return nil;
	
	result = lep_address_list_from_lep_addr(addr_list, 0);
	mailimf_address_list_free(addr_list);
	
	return result;
}

@end

@implementation NSArray (LEPNSArray)

- (NSString *) lepRFC822String
{
    NSMutableString * result;
    BOOL first;
    
    result = [NSMutableString string];
    first = YES;
    for(LEPAddress * address in self) {
        if (first) {
            first = NO;
        }
        else {
            [result appendString:@", "];
        }
        [result appendString:[address RFC822String]];
    }
    
    return result;
}

- (NSString *) lepNonEncodedRFC822String
{
    NSMutableString * result;
    BOOL first;
    
    result = [NSMutableString string];
    first = YES;
    for(LEPAddress * address in self) {
        if (first) {
            first = NO;
        }
        else {
            [result appendString:@", "];
        }
        [result appendString:[address nonEncodedRFC822String]];
    }
    
    return result;
}

@end
