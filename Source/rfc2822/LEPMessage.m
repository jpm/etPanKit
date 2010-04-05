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

struct mailmime * get_text_part(const char * mime_type, const char * charset,
								const char * text, size_t length)
{
	struct mailmime_fields * mime_fields;
	struct mailmime * mime;
	struct mailmime_content * content;
	struct mailmime_parameter * param;
	int encoding_type;
	struct mailmime_disposition * disposition;
	struct mailmime_mechanism * encoding;
	
	encoding_type = MAILMIME_MECHANISM_8BIT;
	encoding = mailmime_mechanism_new(encoding_type, NULL);
	disposition = mailmime_disposition_new_with_data(MAILMIME_DISPOSITION_TYPE_INLINE,
													 NULL, NULL, NULL, NULL, (size_t) -1);
	mime_fields = mailmime_fields_new_with_data(encoding,
												NULL, NULL, disposition, NULL);
	
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

static struct mailmime * get_file_part(const char * filename, const char * mime_type, int is_inline, const char * text, size_t length)
{
	char * disposition_name;
	int encoding_type;
	struct mailmime_disposition * disposition;
	struct mailmime_mechanism * encoding;
	struct mailmime_content * content;
	struct mailmime * mime;
	struct mailmime_fields * mime_fields;
	
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
	mime_fields = mailmime_fields_new_with_data(encoding,
												NULL, NULL, disposition, NULL);
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

static struct mailmime * mime_from_attachments(LEPMessageHeader * header, NSArray * attachments);

static struct mailmime * mime_from_attachment(LEPAbstractAttachment * attachment)
{
	if ([attachment isKindOfClass:[LEPAttachment class]]) {
		struct mailmime * mime;
		LEPAttachment * att;
		NSData * data;
		
		att = (LEPAttachment *) attachment;
		data = [att data];
		if ([att isInlineAttachment] && [[[att mimeType] lowercaseString] hasPrefix:@"text/"]) {
			mime = get_text_part([[att mimeType] UTF8String], [[att charset] UTF8String], [data bytes], [data length]);
		}
		else {
			mime = get_file_part([[[att filename] lepEncodedMIMEHeaderValue] bytes], [[att mimeType] UTF8String], [att isInlineAttachment], [data bytes], [data length]);
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
		mailmime_smart_add_part(mime, submime);
	}
	
	return mime;
}

@implementation LEPMessage

@synthesize attachments = _attachments;
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
		altAttachment = [LEPAttachment attachmentWithHTMLString:[self HTMLBody] withTextAlternative:NO];
		[altAttachments addObject:altAttachment];
		altAttachment = [LEPAttachment attachmentWithString:[self body]];
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

- (void) addAttachment:(LEPAttachment *)attachment
{
	NSMutableArray * array;
	
	array = [[self attachments] mutableCopy];
	if (array == nil) {
		array = [[NSMutableArray alloc] init];
	}
	[array addObject:attachment];
	[self setAttachments:array];
	[array release];
}

@end
