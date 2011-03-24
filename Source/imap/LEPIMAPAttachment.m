//
//  LEPIMAPAttachment.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPAttachment.h"
#import "LEPIMAPAttachmentPrivate.h"

#import "LEPIMAPAlternativeAttachment.h"
#import "LEPIMAPMessageAttachment.h"
#import "NSString+LEP.h"
#import "LEPMessageHeader.h"
#import "LEPMessageHeaderPrivate.h"
#import "LEPIMAPFetchAttachmentRequest.h"
#import "LEPIMAPFetchMessageRequest.h"
#import "LEPIMAPMessage.h"
#import "LEPIMAPMessagePrivate.h"
#import "LEPIMAPFolder.h"
#import "LEPIMAPFolderPrivate.h"
#import "LEPIMAPAccount.h"
#import "LEPIMAPAccountPrivate.h"
#import "LEPConstants.h"
#import "LEPError.h"
#import "LEPUtils.h"
#import <libetpan/libetpan.h>

@interface LEPIMAPAttachment ()

+ (NSArray *) _attachmentsWithIMAPBody:(struct mailimap_body *)body withPartID:(NSString *)partID;
+ (NSArray *) _attachmentWithIMAPBody1Part:(struct mailimap_body_type_1part *)body_1part
								withPartID:(NSString *)partID;
+ (NSArray *) _attachmentWithIMAPBody1PartMessage:(struct mailimap_body_type_msg *)message
										extension:(struct mailimap_body_ext_1part *)extension
									   withPartID:(NSString *)partID;
+ (LEPIMAPAttachment *) _attachmentWithIMAPBody1PartText:(struct mailimap_body_type_text *)text
											   extension:(struct mailimap_body_ext_1part *)extension;
+ (LEPIMAPAttachment *) _attachmentWithIMAPBody1PartBasic:(struct mailimap_body_type_basic *)basic
												extension:(struct mailimap_body_ext_1part *)extension;
+ (NSArray *) _attachmentWithIMAPBodyMultipart:(struct mailimap_body_type_mpart *)body_mpart
									withPartID:(NSString *)partID;
- (void) _setFieldsFromFields:(struct mailimap_body_fields *)fields
					extension:(struct mailimap_body_ext_1part *)extension;

@end

@implementation LEPIMAPAttachment

@synthesize partID = _partID;
@synthesize size = _size;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
	[_partID release];
	[super dealloc];
}

- (void) _setupRequest:(LEPIMAPRequest *)request
{
	[(LEPIMAPMessage *) [self message] _setupRequest: request];
}

- (LEPIMAPFetchAttachmentRequest *) fetchRequest
{
	LEPIMAPFetchAttachmentRequest * request;
	
	request = [[LEPIMAPFetchAttachmentRequest alloc] init];
	[request setEncoding:_encoding];
	[request setPath:[[(LEPIMAPMessage *) [self message] folder] path]];
	[request setUid:[(LEPIMAPMessage *) [self message] uid]];
	[request setPartID:_partID];
    [request setSize:_size];
	
    [self _setupRequest:request];
    
    return [request autorelease];
}

+ (NSArray *) attachmentsWithIMAPBody:(struct mailimap_body *)body
{
	return [self _attachmentsWithIMAPBody:body withPartID:nil];
}

+ (NSArray *) _attachmentsWithIMAPBody:(struct mailimap_body *)body withPartID:(NSString *)partID
{
	switch (body->bd_type) {
		case MAILIMAP_BODY_1PART:
			return [self _attachmentWithIMAPBody1Part:body->bd_data.bd_body_1part withPartID:partID];
		case MAILIMAP_BODY_MPART:
			return [self _attachmentWithIMAPBodyMultipart:body->bd_data.bd_body_mpart withPartID:partID];
	}
	
    return nil;
}

+ (NSArray *) _attachmentWithIMAPBody1Part:(struct mailimap_body_type_1part *)body_1part withPartID:(NSString *)partID
{
	switch (body_1part->bd_type) {
		case MAILIMAP_BODY_TYPE_1PART_BASIC:
		{
			LEPIMAPAttachment * attachment;
			
			attachment = [self _attachmentWithIMAPBody1PartBasic:body_1part->bd_data.bd_type_basic
													   extension:body_1part->bd_ext_1part];
			LEPLog(@"attachment %@", partID);
			if (partID == nil) {
				partID = @"1";
			}
			[attachment _setPartID:partID];
			return [NSArray arrayWithObject:attachment];
		}
		case MAILIMAP_BODY_TYPE_1PART_MSG:
		{
			return [self _attachmentWithIMAPBody1PartMessage:body_1part->bd_data.bd_type_msg
												   extension:body_1part->bd_ext_1part
												  withPartID:partID];
		}
		case MAILIMAP_BODY_TYPE_1PART_TEXT:
		{
			LEPIMAPAttachment * attachment;
			
			attachment = [self _attachmentWithIMAPBody1PartText:body_1part->bd_data.bd_type_text
													  extension:body_1part->bd_ext_1part];
			if (partID == nil) {
				partID = @"1";
			}
			[attachment _setPartID:partID];
			LEPLog(@"attachment %@", partID);
			return [NSArray arrayWithObject:attachment];
		}
	}
	
	return nil;
}

+ (NSArray *) _attachmentWithIMAPBody1PartMessage:(struct mailimap_body_type_msg *)message
										extension:(struct mailimap_body_ext_1part *)extension
									   withPartID:(NSString *)partID
{
	LEPIMAPMessageAttachment * attachment;
	NSArray * result;
	NSArray * subAttachments;
	NSString * nextPartID;
	
	attachment = [[LEPIMAPMessageAttachment alloc] init];
	[[attachment header] setFromIMAPEnvelope:message->bd_envelope];
	
	if (message->bd_body->bd_type == MAILIMAP_BODY_1PART) {
		if (partID == nil) {
			nextPartID = [@"1" retain];
		}
		else {
			nextPartID = [[NSString alloc] initWithFormat:@"%@.1", partID];
		}
	}
	else {
		nextPartID = [partID retain];
	}
	subAttachments = [self _attachmentsWithIMAPBody:message->bd_body withPartID:nextPartID];
	[attachment setAttachments:subAttachments];
	[nextPartID release];
	
    result = [NSArray arrayWithObject:attachment];
	[attachment release];
	
	return result;
}

- (void) _setFieldsFromFields:(struct mailimap_body_fields *)fields
					extension:(struct mailimap_body_ext_1part *)extension
{
	[self _setSize:fields->bd_size];
    if (fields->bd_encoding != NULL) {
        [self _setEncoding:fields->bd_encoding->enc_type];
    }
	
	if (fields->bd_parameter != NULL) {
		clistiter * cur;
		
		for(cur = clist_begin(fields->bd_parameter->pa_list) ; cur != NULL ;
			cur = clist_next(cur)) {
			struct mailimap_single_body_fld_param * imap_param;
			
			imap_param = clist_content(cur);
			
			if (strcasecmp(imap_param->pa_name, "name") == 0) {
				[self setFilename:[NSString lepStringByDecodingMIMEHeaderValue:imap_param->pa_value]];
			}
			else if (strcasecmp(imap_param->pa_name, "charset") == 0) {
				[self setCharset:[NSString lepStringByDecodingMIMEHeaderValue:imap_param->pa_value]];
			}
		}
	}
    if (fields->bd_id != NULL) {
		char * contentid;
		size_t cur_token;
		int r;
		
		cur_token = 0;
		r = mailimf_msg_id_parse(fields->bd_id, strlen(fields->bd_id),
								 &cur_token, &contentid);
		if (r == MAILIMF_NO_ERROR) {
			// msg id
            [self setContentID:[NSString stringWithUTF8String:contentid]];
            free(contentid);
		}
    }
	
    if (extension != NULL) {
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
                    
                    if (strcasecmp(imap_param->pa_name, "filename") == 0) {
                        [self setFilename:[NSString lepStringByDecodingMIMEHeaderValue:imap_param->pa_value]];
                    }
                }
            }
        }
        
        if (extension->bd_loc != NULL) {
            [self setContentLocation:[NSString stringWithUTF8String:extension->bd_loc]];
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
									withPartID:(NSString *)partID
{
	NSMutableArray * result;
	
	result = [NSMutableArray array];
	
	if (strcasecmp(body_mpart->bd_media_subtype, "alternative") == 0) {
		// multipart/alternative
		clistiter * cur;
		LEPIMAPAlternativeAttachment * attachment;
		NSMutableArray * attachments;
		unsigned int count;
		
		attachments = [[NSMutableArray alloc] init];
		
		count = 1;
		for(cur = clist_begin(body_mpart->bd_list) ; cur != NULL ; cur = clist_next(cur)) {
			struct mailimap_body * body;
			NSArray * subResult;
			NSString * nextPartID;
			
			if (partID == nil) {
				nextPartID = [[NSString alloc] initWithFormat:@"%u", count];
			}
			else {
				nextPartID = [[NSString alloc] initWithFormat:@"%@.%u", partID, count];
			}
			body = clist_content(cur);
			subResult = [self _attachmentsWithIMAPBody:body withPartID:nextPartID];
			[nextPartID release];
			[attachments addObject:subResult];
			
			count ++;
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
		unsigned int count;
		
		count = 1;
		for(cur = clist_begin(body_mpart->bd_list) ; cur != NULL ; cur = clist_next(cur)) {
			struct mailimap_body * body;
			NSArray * subResult;
			NSString * nextPartID;
			
			if (partID == nil) {
				nextPartID = [[NSString alloc] initWithFormat:@"%u", count];
			}
			else {
				nextPartID = [[NSString alloc] initWithFormat:@"%@.%u", partID, count];
			}
			body = clist_content(cur);
			subResult = [self _attachmentsWithIMAPBody:body withPartID:nextPartID];
			[result addObjectsFromArray:subResult];
			[nextPartID release];
			
			count ++;
		}
	}
	return result;
}

- (void) _setPartID:(NSString *)partID
{
	[_partID release];
	_partID = [partID copy];
}

- (void) _setSize:(size_t)size
{
	_size = size;
}

- (void) _setEncoding:(int)encoding
{
	_encoding = encoding;
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"<%@: 0x%p %@ %@ %@>", [self class], self, _partID, [self mimeType], [self filename]];
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	
	_partID = [[coder decodeObjectForKey:@"partID"] retain];
	_encoding = [coder decodeInt32ForKey:@"encoding"];
	_size = [coder decodeInt32ForKey:@"size"];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_partID forKey:@"partID"];
	[encoder encodeInt32:(int32_t)_encoding forKey:@"encoding"];
	[encoder encodeInt32:(int32_t)_size forKey:@"size"];
}

- (id) copyWithZone:(NSZone *)zone
{
    LEPIMAPAttachment * attachment;
    
    attachment = [super copyWithZone:zone];
    
    attachment->_encoding = self->_encoding;
    [attachment->_partID release];
    attachment->_partID = [self->_partID copy];
    attachment->_size = self->_size;
    
    return attachment;
}

- (size_t) decodedSize
{
	switch (_encoding) {
		case MAILIMAP_BODY_FLD_ENC_BASE64:
            return _size * 3 / 4;
            
        default:
            return _size;
	}
}

@end
