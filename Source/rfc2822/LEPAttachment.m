//
//  LEPAttachment.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPAttachment.h"

#import "LEPMessageAttachment.h"
#import "LEPUtils.h"
#import "LEPMessageHeader.h"
#import "LEPMessageHeaderPrivate.h"
#import "LEPAlternativeAttachment.h"
#import "NSString+LEP.h"
#import <libetpan/libetpan.h>

#pragma mark Content-Type

static char * get_discrete_type(struct mailmime_discrete_type * discrete_type)
{
	switch (discrete_type->dt_type) {
		case MAILMIME_DISCRETE_TYPE_TEXT:
			return "text";
			
		case MAILMIME_DISCRETE_TYPE_IMAGE:
			return "image";
			
		case MAILMIME_DISCRETE_TYPE_AUDIO:
			return "audio";
			
		case MAILMIME_DISCRETE_TYPE_VIDEO:
			return "video";
			
		case MAILMIME_DISCRETE_TYPE_APPLICATION:
			return "application";
			
		case MAILMIME_DISCRETE_TYPE_EXTENSION:
			return discrete_type->dt_extension;
	}
	
	return NULL;
}

static char *
get_composite_type(struct mailmime_composite_type * composite_type)
{
	switch (composite_type->ct_type) {
		case MAILMIME_COMPOSITE_TYPE_MESSAGE:
			return "message";
			
		case MAILMIME_COMPOSITE_TYPE_MULTIPART:
			return "multipart";
			
		case MAILMIME_COMPOSITE_TYPE_EXTENSION:
			return composite_type->ct_token;
	}
	
	return NULL;
}

static char * get_content_type_str(struct mailmime_content * content)
{
	char * str;
	char * result;
	
	str = "unknown";
	
	switch (content->ct_type->tp_type) {
		case MAILMIME_TYPE_DISCRETE_TYPE:
			str = get_discrete_type(content->ct_type->tp_data.tp_discrete_type);
			break;
			
		case MAILMIME_TYPE_COMPOSITE_TYPE:
			str = get_composite_type(content->ct_type->tp_data.tp_composite_type);
			break;
	}
	
	if (str == NULL)
		str = "unknown";
	
	result = malloc(strlen(str) + strlen(content->ct_subtype) + 2);
	strcpy(result, str);
	strcat(result, "/");
	strcat(result, content->ct_subtype);
	
	return result;
}

@interface LEPAttachment ()

+ (LEPAttachment *) _attachmentWithSingleMIME:(struct mailmime *)mime;
+ (LEPMessageAttachment *) _attachmentWithMessageMIME:(struct mailmime *)mime;

@end

@implementation LEPAttachment

@synthesize data = _data;

- (id) init
{
	self = [super init];
	
	[self setMimeType:@"application/octet-stream"];
	
	return self;
} 

- (void) dealloc
{
    [_data release];
	[super dealloc];
}

+ (NSArray *) attachmentsWithMIME:(struct mailmime *)mime
{
	switch (mime->mm_type) {
		case MAILMIME_SINGLE:
		{
			LEPAttachment * attachment;
			
			attachment = [self _attachmentWithSingleMIME:mime];
			return [NSArray arrayWithObject:attachment];
		}
		case MAILMIME_MULTIPLE:
		{
			if (strcasecmp(mime->mm_content_type->ct_subtype, "alternative") == 0) {
				NSMutableArray * subAttachments;
				clistiter * cur;
				LEPAlternativeAttachment * attachment;
				
				subAttachments = [NSMutableArray array];
				for(cur = clist_begin(mime->mm_data.mm_multipart.mm_mp_list) ; cur != NULL ; cur = clist_next(cur)) {
					struct mailmime * submime;
					NSArray * subResult;
					
					submime = clist_content(cur);
					subResult = [self attachmentsWithMIME:submime];
					[subAttachments addObject:subResult];
				}
				
				attachment = [[[LEPAlternativeAttachment alloc] init] autorelease];
				[attachment setAttachments:subAttachments];
				return [NSArray arrayWithObject:attachment];
			}
			else {
				NSMutableArray * result;
				clistiter * cur;
				
				result = [NSMutableArray array];
				for(cur = clist_begin(mime->mm_data.mm_multipart.mm_mp_list) ; cur != NULL ; cur = clist_next(cur)) {
					struct mailmime * submime;
					NSArray * subResult;
					
					submime = clist_content(cur);
					subResult = [self attachmentsWithMIME:submime];
					[result addObjectsFromArray:subResult];
				}
				
				return result;
			}
		}
		case MAILMIME_MESSAGE:
		{
			return [self attachmentsWithMIME:mime->mm_data.mm_message.mm_msg_mime];
		}
	}
	
	return nil;
}

+ (LEPAttachment *) _attachmentWithSingleMIME:(struct mailmime *)mime
{
	struct mailmime_data * data;
	const char * bytes;
	size_t length;
	LEPAttachment * result;
	struct mailmime_single_fields single_fields;
	char * str;
	char * name;
	char * filename;
    char * content_id;
	
	LEPAssert(mime->mm_type == MAILMIME_SINGLE);
	
	result = [[LEPAttachment alloc] init];
	data = mime->mm_data.mm_single;
	bytes = data->dt_data.dt_text.dt_data;
	length = data->dt_data.dt_text.dt_length;
	switch (data->dt_encoding) {
		case MAILMIME_MECHANISM_7BIT:
		case MAILMIME_MECHANISM_8BIT:
		case MAILMIME_MECHANISM_BINARY:
		case MAILMIME_MECHANISM_TOKEN:
		{
			[result setData:[NSData dataWithBytes:bytes length:length]];
			break;
		}
			
		case MAILMIME_MECHANISM_QUOTED_PRINTABLE:
		case MAILMIME_MECHANISM_BASE64:
		{
			char * decoded;
			size_t decoded_length;
			size_t cur_token;
			
			cur_token = 0;
			mailmime_part_parse(bytes, length, &cur_token,
								data->dt_encoding, &decoded, &decoded_length);
			[result setData:[NSData dataWithBytes:decoded length:decoded_length]];
			mailmime_decoded_part_free(decoded);
			break;
		}
	}
	
	str = get_content_type_str(mime->mm_content_type);
	[result setMimeType:[NSString stringWithUTF8String:str]];
	free(str);
	
	mailmime_single_fields_init(&single_fields, mime->mm_mime_fields, mime->mm_content_type);
	
	name = single_fields.fld_content_name;
	filename = single_fields.fld_disposition_filename;
    content_id = single_fields.fld_id;
	fprintf(stderr, "%s\n%s\n\n", name, filename);
	
	if (filename != NULL) {
		[result setFilename:[NSString stringWithUTF8String:filename]];
	}
	else if (name != NULL) {
		[result setFilename:[NSString stringWithUTF8String:name]];
	}
	if (content_id != NULL) {
        [result setContentID:[NSString stringWithUTF8String:content_id]];
    }
	if (single_fields.fld_content_charset != NULL) {
		[result setCharset:[NSString stringWithUTF8String:single_fields.fld_content_charset]];
	}
    
	if (single_fields.fld_disposition != NULL) {
		if (single_fields.fld_disposition->dsp_type != NULL) {
			if (single_fields.fld_disposition->dsp_type->dsp_type == MAILMIME_DISPOSITION_TYPE_INLINE) {
				[result setInlineAttachment:YES];
			}
		}
	}
	
	return [result autorelease];
}

+ (LEPMessageAttachment *) _attachmentWithMessageMIME:(struct mailmime *)mime
{
	LEPMessageAttachment * attachment;
	NSArray * attachments;
	
	attachment = [[LEPMessageAttachment alloc] init];
	
	[[attachment header] setFromIMFFields:mime->mm_data.mm_message.mm_fields];
	
	attachments = [LEPAttachment attachmentsWithMIME:mime->mm_data.mm_message.mm_msg_mime];
	[attachment setAttachments:attachments];
	
	return [attachment autorelease];
}

+ (LEPAbstractAttachment *) attachmentWithMIME:(struct mailmime *)mime
{
	LEPAssert(mime->mm_type != MAILMIME_MULTIPLE);
	
	switch (mime->mm_type) {
		case MAILMIME_SINGLE:
			return [self _attachmentWithSingleMIME:mime];
		case MAILMIME_MESSAGE:
			return [self _attachmentWithMessageMIME:mime];
	}
	
	return nil;
}

+ (NSString *) _mimeTypeFromFilename:(NSString *)filename
{
	if ([[[filename pathExtension] lowercaseString] isEqualToString:@"jpg"]) {
		return @"image/jpeg";
	}
	else if ([[[filename pathExtension] lowercaseString] isEqualToString:@"jpeg"]) {
		return @"image/jpeg";
	}
	else if ([[[filename pathExtension] lowercaseString] isEqualToString:@"png"]) {
		return @"image/png";
	}
	else if ([[[filename pathExtension] lowercaseString] isEqualToString:@"gif"]) {
		return @"image/gif";
	}
	else if ([[[filename pathExtension] lowercaseString] isEqualToString:@"html"]) {
		return @"text/html";
	}
	return nil;
}

+ (LEPAttachment *) attachmentWithContentsOfFile:(NSString *)filename
{
	NSString * mimeType;
	NSData * data;
	LEPAttachment * attachment;
	
	attachment = [[LEPAttachment alloc] init];
	data = [[NSData alloc] initWithContentsOfFile:filename];
	mimeType = [self _mimeTypeFromFilename:filename];
	if (mimeType != nil) {
		[attachment setMimeType:mimeType];
	}
	[attachment setFilename:[filename lastPathComponent]];
	[attachment setData:data];
	[data release];
	
	return [attachment autorelease];
}

+ (LEPAttachment *) attachmentWithHTMLString:(NSString *)html
{
	return [self attachmentWithHTMLString:html withTextAlternative:YES];
}

+ (LEPAttachment *) attachmentWithHTMLString:(NSString *)html withTextAlternative:(BOOL)hasAlternative;
{
	if (!hasAlternative) {
		NSData * data;
		LEPAttachment * attachment;
		
		attachment = [[LEPAttachment alloc] init];
		[attachment setInlineAttachment:YES];
		[attachment setMimeType:@"text/html"];
		data = [html dataUsingEncoding:NSUTF8StringEncoding];
		[attachment setData:data];
		
		return [attachment autorelease];
	}
	else {
		LEPAlternativeAttachment * alternativeAttachment;
		NSMutableArray * attachments;
		LEPAttachment * attachment;
		
		alternativeAttachment = [[LEPAlternativeAttachment alloc] init];
		attachments = [[NSMutableArray alloc] init];
		attachment = [LEPAttachment attachmentWithString:[html lepFlattenHTML]];
		[attachments addObject:attachment];
		attachment = [LEPAttachment attachmentWithHTMLString:html withTextAlternative:NO];
		[attachments addObject:attachment];
		[alternativeAttachment setAttachments:attachments];
		[attachments release];
		
		return [alternativeAttachment autorelease];
	}
}

+ (LEPAttachment *) attachmentWithString:(NSString *)stringValue
{
	NSData * data;
	LEPAttachment * attachment;
	
	attachment = [[LEPAttachment alloc] init];
	[attachment setInlineAttachment:YES];
	[attachment setMimeType:@"text/plain"];
	data = [stringValue dataUsingEncoding:NSUTF8StringEncoding];
	[attachment setData:data];
	
	return [attachment autorelease];
}

@end
