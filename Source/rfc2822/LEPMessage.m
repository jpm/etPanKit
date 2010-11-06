//
//  LEPMessage.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPMessage.h"
#import "NSData+LEPUTF8.h"
#import "LEPAttachment.h"
#import "LEPAttachmentPrivate.h"
#import "LEPMessageAttachment.h"
#import "LEPUtils.h"
#import "LEPMessageHeader.h"
#import "LEPMessageHeaderPrivate.h"
#import "LEPAlternativeAttachment.h"
#import "NSString+LEP.h"
#import <libetpan/libetpan.h>

@interface LEPAbstractAttachment (LEPAttachment)

- (NSData *) data;

@end

struct mailmime * get_text_part(const char * mime_type, const char * charset, const char * content_id,
								const char * text, size_t length)
{
	struct mailmime_fields * mime_fields;
	struct mailmime * mime;
	struct mailmime_content * content;
	struct mailmime_parameter * param;
	int encoding_type;
	struct mailmime_disposition * disposition;
	struct mailmime_mechanism * encoding;
	char * dup_content_id;
    
	encoding_type = MAILMIME_MECHANISM_8BIT;
	encoding = mailmime_mechanism_new(encoding_type, NULL);
	disposition = mailmime_disposition_new_with_data(MAILMIME_DISPOSITION_TYPE_INLINE,
													 NULL, NULL, NULL, NULL, (size_t) -1);
    dup_content_id = NULL;
    if (content_id != NULL)
        dup_content_id = strdup(content_id);
	mime_fields = mailmime_fields_new_with_data(encoding,
                                                dup_content_id, NULL, disposition, NULL);
	
	content = mailmime_content_new_with_str(mime_type);
	if (charset == NULL) {
		param = mailmime_param_new_with_data("charset", "utf-8");
	}
	else {
		param = mailmime_param_new_with_data("charset", (char *) charset);
	}
	clist_append(content->ct_parameters, param);
	mime = mailmime_new_empty(content, mime_fields);
	mailmime_set_body_text(mime, (char *) text, length);
	
	return mime;
}

static struct mailmime * get_file_part(const char * filename, const char * mime_type, int is_inline,
                                       const char * content_id,
                                       const char * text, size_t length)
{
	char * disposition_name;
	int encoding_type;
	struct mailmime_disposition * disposition;
	struct mailmime_mechanism * encoding;
	struct mailmime_content * content;
	struct mailmime * mime;
	struct mailmime_fields * mime_fields;
	char * dup_content_id;
	
	disposition_name = NULL;
	if (filename != NULL) {
		disposition_name = strdup(filename);
	}
	if (is_inline) {
		disposition = mailmime_disposition_new_with_data(MAILMIME_DISPOSITION_TYPE_INLINE,
														 disposition_name, NULL, NULL, NULL, (size_t) -1);
	}
	else {
		disposition = mailmime_disposition_new_with_data(MAILMIME_DISPOSITION_TYPE_ATTACHMENT,
														 disposition_name, NULL, NULL, NULL, (size_t) -1);
	}
	content = mailmime_content_new_with_str(mime_type);
	
	encoding_type = MAILMIME_MECHANISM_BASE64;
	encoding = mailmime_mechanism_new(encoding_type, NULL);
    dup_content_id = NULL;
    if (content_id != NULL)
        dup_content_id = strdup(content_id);
	mime_fields = mailmime_fields_new_with_data(encoding,
												dup_content_id, NULL, disposition, NULL);
	mime = mailmime_new_empty(content, mime_fields);
	mailmime_set_body_text(mime, (char *) text, length);
	
	return mime;
}

static struct mailmime * get_multipart_alternative(void)
{
	struct mailmime * mime;
	
	mime = mailmime_multiple_new("multipart/alternative");
	
	return mime;
}

static int add_attachment(struct mailmime * mime,
                          struct mailmime * mime_sub)
{
    struct mailmime * saved_sub;
    struct mailmime * mp;
    int res;
    int r;
    
    switch (mime->mm_type) {
        case MAILMIME_SINGLE:
            res = MAILIMF_ERROR_INVAL;
            goto err;
            
        case MAILMIME_MULTIPLE:
            r = mailmime_add_part(mime, mime_sub);
            if (r != MAILIMF_NO_ERROR) {
                res = MAILIMF_ERROR_MEMORY;
                goto err;
            }
            
            return MAILIMF_NO_ERROR;
    }
    
    /* MAILMIME_MESSAGE */
    
    if (mime->mm_data.mm_message.mm_msg_mime == NULL) {
        /* there is no subpart, we can simply attach it */
        
        r = mailmime_add_part(mime, mime_sub);
        if (r != MAILIMF_NO_ERROR) {
            res = MAILIMF_ERROR_MEMORY;
            goto err;
        }
        
        return MAILIMF_NO_ERROR;
    }
    
    if (mime->mm_data.mm_message.mm_msg_mime->mm_type == MAILMIME_MULTIPLE &&
        strcasecmp(mime->mm_data.mm_message.mm_msg_mime->mm_content_type->ct_subtype, "alternative") != 0) {
        /* in case the subpart is multipart, simply attach it to the subpart */
        
        return mailmime_add_part(mime->mm_data.mm_message.mm_msg_mime, mime_sub);
    }
    
    /* we save the current subpart, ... */
    
    saved_sub = mime->mm_data.mm_message.mm_msg_mime;
    
    /* create a multipart */
    
    mp = mailmime_multiple_new("multipart/mixed");
    if (mp == NULL) {
        res = MAILIMF_ERROR_MEMORY;
        goto err;
    }
    
    /* detach the saved subpart from the parent */
    
    mailmime_remove_part(saved_sub);
    
    /* the created multipart is the new child of the parent */
    
    r = mailmime_add_part(mime, mp);
    if (r != MAILIMF_NO_ERROR) {
        res = MAILIMF_ERROR_MEMORY;
        goto free_mp;
    }
    
    /* then, attach the saved subpart and ... */
    
    r = mailmime_add_part(mp, saved_sub);
    if (r != MAILIMF_NO_ERROR) {
        res = MAILIMF_ERROR_MEMORY;
        goto free_saved_sub;
    }
    
    /* the given part to the parent */
    
    r = mailmime_add_part(mp, mime_sub);
    if (r != MAILIMF_NO_ERROR) {
        res = MAILIMF_ERROR_MEMORY;
        goto free_saved_sub;
    }
    
    return MAILIMF_NO_ERROR;
    
free_mp:
    mailmime_free(mp);
free_saved_sub:
    mailmime_free(saved_sub);
err:
    return res;
}

static struct mailmime * mime_from_attachments(LEPMessageHeader * header, NSArray * attachments);

static struct mailmime * mime_from_attachment(LEPAbstractAttachment * attachment)
{
	if (([attachment respondsToSelector:@selector(data)]) || ([attachment isKindOfClass:[LEPAttachment class]])) {
		struct mailmime * mime;
		LEPAttachment * att;
		NSData * data;
		
		att = (LEPAttachment *) attachment;
		data = [att data];
		if ([att isInlineAttachment] && [[[att mimeType] lowercaseString] hasPrefix:@"text/"]) {
			mime = get_text_part([[att mimeType] UTF8String], [[att charset] UTF8String],
                                 [[attachment contentID] UTF8String],
                                 [data bytes], [data length]);
		}
		else {
			mime = get_file_part([[[att filename] lepEncodedMIMEHeaderValue] bytes], [[att mimeType] UTF8String], [att isInlineAttachment],
                                 [[attachment contentID] UTF8String],
                                 [data bytes], [data length]);
		}
		return mime;
	}
	else if ([attachment isKindOfClass:[LEPAlternativeAttachment class]]) {
		struct mailmime * mime;
		LEPAlternativeAttachment * altAttachment;
		unsigned int i;
		
		altAttachment = (LEPAlternativeAttachment *) attachment;
		
		mime = get_multipart_alternative();
		for(i = 0 ; i < [[altAttachment attachments] count] ; i ++) {
			LEPAbstractAttachment * subAtt;
			struct mailmime * submime;
			
			subAtt = [[altAttachment attachments] objectAtIndex:i];
			submime = mime_from_attachment(subAtt);
			mailmime_smart_add_part(mime, submime);
		}
		return mime;
	}
	else if ([attachment isKindOfClass:[LEPMessageAttachment class]]) {
		LEPMessageAttachment * msgAttachment;
		struct mailmime * mime;
		
		msgAttachment = (LEPMessageAttachment *) attachment;
		
		mime = mime_from_attachments([msgAttachment header], [msgAttachment attachments]);
		return mime;
	}
	
	return NULL;
}

static struct mailmime * mime_from_attachments(LEPMessageHeader * header, NSArray * attachments)
{
	struct mailimf_fields * fields;
	unsigned int i;
	struct mailmime * mime;
	
	fields = [header createIMFFields];
	
	mime = mailmime_new_message_data(NULL);
	mailmime_set_imf_fields(mime, fields);
	
	for(i = 0 ; i < [attachments count] ; i ++) {
		LEPAbstractAttachment * attachment;
		struct mailmime * submime;
		
		attachment = [attachments objectAtIndex:i];
		submime = mime_from_attachment(attachment);
		add_attachment(mime, submime);
	}
	
	return mime;
}

@implementation LEPMessage

@synthesize body = _body;
@synthesize HTMLBody = _HTMLBody;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
	[_HTMLBody release];
	[_body release];
	[_attachments release];
    
	[super dealloc];
}

- (id) initWithData:(NSData *)data
{
	self = [super init];
	[self parseData:data];
	
	return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	[self setBody:[coder decodeObjectForKey:@"body"]];
	[self setHTMLBody:[coder decodeObjectForKey:@"HTMLBody"]];
	[self setAttachments:[coder decodeObjectForKey:@"attachments"]];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_body forKey:@"body"];
	[encoder encodeObject:_HTMLBody forKey:@"HTMLBody"];
	[encoder encodeObject:_attachments forKey:@"attachments"];
}

- (id) copyWithZone:(NSZone *)zone
{
    LEPMessage * message;
    
    message = [super copyWithZone:zone];
    
    [message setBody:[self body]];
    [message setHTMLBody:[self HTMLBody]];
	NSMutableArray * attachments;
	attachments = [[NSMutableArray alloc] init];
	for(LEPAbstractAttachment * attachment in [self attachments]) {
		[attachments addObject:[[attachment copy] autorelease]];
	}
    [message setAttachments:attachments];
	[attachments release];
    
    return message;
}

- (void) parseData:(NSData *)data
{
	mailmessage * msg;
	struct mailmime * mime;
	
	msg = data_message_init((char *) [data bytes], [data length]);
	
	mailmessage_get_bodystructure(msg, &mime);
	
	[_attachments release];
	_attachments = [LEPAttachment attachmentsWithMIME:msg->msg_mime];
	[[self header] setFromIMFFields:msg->msg_fields];
	[_attachments retain];
	for(LEPAbstractAttachment * attachment in _attachments) {
		[attachment setMessage:self];
	}
	
	mailmessage_free(msg);
}

- (NSData *) data
{
	NSArray * attachments;
	struct mailmime * mime;
	NSData * data;
	MMAPString * str;
	int col;
#warning should generate undisclosed recipient when recipient except Bcc is empty
	
	attachments = [self attachments];
	
	if (([self HTMLBody] != nil) && ([self body] == nil)) {
		NSMutableArray * newArray;
		LEPAttachment * attachment;
		
		attachment = [LEPAttachment attachmentWithHTMLString:[self HTMLBody]];
		
		newArray = [NSMutableArray array];
		[newArray addObject:attachment];
		[newArray addObjectsFromArray:attachments];
		
		attachments = newArray;
	}
	else if (([self HTMLBody] != nil) && ([self body] != nil)) {
		NSMutableArray * newArray;
		LEPAlternativeAttachment * alternative;
		NSMutableArray * altAttachments;
		LEPAttachment * altAttachment;
		
		alternative = [[LEPAlternativeAttachment alloc] init];
		altAttachments = [[NSMutableArray alloc] init];
		altAttachment = [LEPAttachment attachmentWithString:[self body]];
		[altAttachments addObject:altAttachment];
		altAttachment = [LEPAttachment attachmentWithHTMLString:[self HTMLBody] withTextAlternative:NO];
		[altAttachments addObject:altAttachment];
		[alternative setAttachments:altAttachments];
		[altAttachments release];
		
		newArray = [NSMutableArray array];
		[newArray addObject:alternative];
		[newArray addObjectsFromArray:attachments];
		
		attachments = newArray;
	}
	else if ([self body] != nil) {
		NSMutableArray * newArray;
		LEPAttachment * attachment;
		
		attachment = [LEPAttachment attachmentWithString:[self body]];
		
		newArray = [NSMutableArray array];
		[newArray addObject:attachment];
		[newArray addObjectsFromArray:attachments];
		
		attachments = newArray;
	}
	
	mime = mime_from_attachments([self header], attachments);
	str = mmap_string_new("");
	col = 0;
	mailmime_write_mem(str, &col, mime);
	data = [NSData dataWithBytes:str->str length:str->len];
	mmap_string_free(str);
	mailmime_free(mime);
	
	return data;
}

- (void) addAttachment:(LEPAbstractAttachment *)attachment
{
	NSMutableArray * array;
	
    LEPAssert([attachment respondsToSelector:@selector(data)]);
    
	array = [[self attachments] mutableCopy];
	if (array == nil) {
		array = [[NSMutableArray alloc] init];
	}
	[array addObject:attachment];
	[self setAttachments:array];
	[array release];
}

- (NSArray *) attachments
{
	return _attachments;
}

- (void) setAttachments:(NSArray *)attachments
{
	[_attachments release];
	for(LEPAbstractAttachment * attachment in attachments) {
		[attachment setMessage:self];
	}
	_attachments = [attachments retain];
}

@end
