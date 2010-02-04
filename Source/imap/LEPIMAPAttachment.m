//
//  LEPIMAPAttachment.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPAttachment.h"

#import "LEPIMAPAlternativeAttachment.h"
#import "LEPIMAPMessageAttachment.h"
#import "NSString+LEP.h"
#import "LEPMessageHeader.h"
#import "LEPMessageHeaderPrivate.h"
#import <libetpan/libetpan.h>

@interface LEPIMAPAttachment ()

+ (NSArray *) _attachmentWithIMAPBody1Part:(struct mailimap_body_type_1part *)body_1part;
+ (NSArray *) _attachmentWithIMAPBody1PartMessage:(struct mailimap_body_type_msg *)message
										extension:(struct mailimap_body_ext_1part *)extension;
+ (LEPAbstractAttachment *) _attachmentWithIMAPBody1PartText:(struct mailimap_body_type_text *)text
												   extension:(struct mailimap_body_ext_1part *)extension;
+ (LEPAbstractAttachment *) _attachmentWithIMAPBody1PartBasic:(struct mailimap_body_type_basic *)basic
													extension:(struct mailimap_body_ext_1part *)extension;
+ (NSArray *) _attachmentWithIMAPBodyMultipart:(struct mailimap_body_type_mpart *)body_mpart;

- (void) _setFieldsFromFields:(struct mailimap_body_fields *)fields
					extension:(struct mailimap_body_ext_1part *)extension;

@end

@implementation LEPIMAPAttachment

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
	[super dealloc];
}

- (LEPIMAPFetchAttachmentRequest *) fetchRequest
{
#warning should be implemented
    return nil;
}

+ (NSArray *) attachmentsWithIMAPBody:(struct mailimap_body *)body
{
	switch (body->bd_type) {
		case MAILIMAP_BODY_1PART:
			return [self _attachmentWithIMAPBody1Part:body->bd_data.bd_body_1part];
		case MAILIMAP_BODY_MPART:
			return [self _attachmentWithIMAPBodyMultipart:body->bd_data.bd_body_mpart];
	}
	
    return nil;
}

+ (NSArray *) _attachmentWithIMAPBody1Part:(struct mailimap_body_type_1part *)body_1part
{
	switch (body_1part->bd_type) {
		case MAILIMAP_BODY_TYPE_1PART_BASIC:
		{
			LEPAbstractAttachment * attachment;
			
			attachment = [self _attachmentWithIMAPBody1PartBasic:body_1part->bd_data.bd_type_basic
													   extension:body_1part->bd_ext_1part];
			return [NSArray arrayWithObject:attachment];
		}
		case MAILIMAP_BODY_TYPE_1PART_MSG:
		{
			return [self _attachmentWithIMAPBody1PartMessage:body_1part->bd_data.bd_type_msg
												   extension:body_1part->bd_ext_1part];
		}
		case MAILIMAP_BODY_TYPE_1PART_TEXT:
		{
			LEPAbstractAttachment * attachment;
			
			attachment = [self _attachmentWithIMAPBody1PartText:body_1part->bd_data.bd_type_text
													  extension:body_1part->bd_ext_1part];
			return [NSArray arrayWithObject:attachment];
		}
	}
	
	return nil;
}

+ (NSArray *) _attachmentWithIMAPBody1PartMessage:(struct mailimap_body_type_msg *)message
										extension:(struct mailimap_body_ext_1part *)extension
{
	LEPIMAPMessageAttachment * attachment;
	NSArray * result;
	NSArray * subAttachments;
	
	attachment = [[LEPIMAPMessageAttachment alloc] init];
	[[attachment header] setFromIMAPEnvelope:message->bd_envelope];
	
	subAttachments = [self attachmentsWithIMAPBody:message->bd_body];
	[attachment setAttachments:subAttachments];
	
    result = [NSArray arrayWithObject:attachment];
	[attachment release];
	
	return result;
}

- (void) _setFieldsFromFields:(struct mailimap_body_fields *)fields
					extension:(struct mailimap_body_ext_1part *)extension
{
	if (fields->bd_parameter != NULL) {
		clistiter * cur;
		
		for(cur = clist_begin(fields->bd_parameter->pa_list) ; cur != NULL ;
			cur = clist_next(cur)) {
			struct mailimap_single_body_fld_param * imap_param;
			
			imap_param = clist_content(cur);
			
			if (strcasecmp(imap_param->pa_name, "name") != 0) {
				[self setFilename:[NSString lepStringByDecodingMIMEHeaderValue:imap_param->pa_value]];
			}
			else if (strcasecmp(imap_param->pa_name, "charset") != 0) {
				[self setFilename:[NSString lepStringByDecodingMIMEHeaderValue:imap_param->pa_value]];
			}
		}
	}
	
	if (extension->bd_disposition != NULL) {
		if (strcasecmp(extension->bd_disposition->dsp_type, "inline") == 0) {
			[self setInlineAttachment:YES];
		}
		
		if (extension->bd_disposition->dsp_attributes != NULL) {
			clistiter * cur;
			
			for(cur = clist_begin(extension->bd_disposition->dsp_attributes->pa_list) ; cur != NULL ;
				cur = clist_next(cur)) {
				struct mailimap_single_body_fld_param * imap_param;
				
				imap_param = clist_content(cur);
				
				if (strcasecmp(imap_param->pa_name, "filename") != 0) {
					[self setFilename:[NSString lepStringByDecodingMIMEHeaderValue:imap_param->pa_value]];
				}
			}
		}
	}
}

+ (LEPAbstractAttachment *) _attachmentWithIMAPBody1PartBasic:(struct mailimap_body_type_basic *)basic
													extension:(struct mailimap_body_ext_1part *)extension
{
	LEPIMAPAttachment * attachment;
	NSString * mimeType;
	
	attachment = [[LEPIMAPAttachment alloc] init];
	[attachment _setFieldsFromFields:basic->bd_fields extension:extension];
	
	switch (basic->bd_media_basic->med_type) {
		case MAILIMAP_MEDIA_BASIC_APPLICATION:
			mimeType = [[NSString alloc] initWithFormat:@"application/%@", [NSString stringWithUTF8String:basic->bd_media_basic->med_subtype]];
			break;
		case MAILIMAP_MEDIA_BASIC_AUDIO:
			mimeType = [[NSString alloc] initWithFormat:@"audio/%@", [NSString stringWithUTF8String:basic->bd_media_basic->med_subtype]];
			break;
		case MAILIMAP_MEDIA_BASIC_IMAGE:
			mimeType = [[NSString alloc] initWithFormat:@"image/%@", [NSString stringWithUTF8String:basic->bd_media_basic->med_subtype]];
			break;
		case MAILIMAP_MEDIA_BASIC_MESSAGE:
			mimeType = [[NSString alloc] initWithFormat:@"message/%@", [NSString stringWithUTF8String:basic->bd_media_basic->med_subtype]];
			break;
		case MAILIMAP_MEDIA_BASIC_VIDEO:
			mimeType = [[NSString alloc] initWithFormat:@"video/%@", [NSString stringWithUTF8String:basic->bd_media_basic->med_subtype]];
			break;
		case MAILIMAP_MEDIA_BASIC_OTHER:
			mimeType = [[NSString alloc] initWithFormat:@"other/%@", [NSString stringWithUTF8String:basic->bd_media_basic->med_subtype]];
			break;
	}
	[attachment setMimeType:mimeType];
	[mimeType release];
	
	return [attachment autorelease];
}

+ (LEPAbstractAttachment *) _attachmentWithIMAPBody1PartText:(struct mailimap_body_type_text *)text
												   extension:(struct mailimap_body_ext_1part *)extension
{
	LEPIMAPAttachment * attachment;
	
	attachment = [[LEPIMAPAttachment alloc] init];
	[attachment _setFieldsFromFields:text->bd_fields extension:extension];
	[attachment setMimeType:[NSString stringWithFormat:@"text/%@", [NSString stringWithUTF8String:text->bd_media_text]]];
	
	return [attachment autorelease];
}

+ (NSArray *) _attachmentWithIMAPBodyMultipart:(struct mailimap_body_type_mpart *)body_mpart
{
	NSMutableArray * result;
	
	result = [NSMutableArray array];
	
	if (strcasecmp(body_mpart->bd_media_subtype, "alternative") == 0) {
		// multipart/alternative
		clistiter * cur;
		LEPIMAPAlternativeAttachment * attachment;
		NSMutableArray * attachments;
		
		attachments = [[NSMutableArray alloc] init];
		
		for(cur = clist_begin(body_mpart->bd_list) ; cur != NULL ; cur = clist_next(cur)) {
			struct mailimap_body * body;
			NSArray * subResult;
			
			body = clist_content(cur);
			subResult = [self attachmentsWithIMAPBody:body];
			[attachments addObject:subResult];
		}
		
		attachment = [[LEPIMAPAlternativeAttachment alloc] init];
		[attachment setAttachments:attachments];
		[result addObject:attachment];
		[attachment release];
		
		[attachments release];
	}
	else {
		// multipart/*
		clistiter * cur;
		
		for(cur = clist_begin(body_mpart->bd_list) ; cur != NULL ; cur = clist_next(cur)) {
			struct mailimap_body * body;
			NSArray * subResult;
			
			body = clist_content(cur);
			subResult = [self attachmentsWithIMAPBody:body];
			[result addObjectsFromArray:subResult];
		}
	}
	return result;
}

@end
