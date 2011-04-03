//
//  LEPMessageHeader.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPMessageHeader.h"
#import "LEPMessageHeaderPrivate.h"

#import "LEPAddress.h"
#import "LEPAddressPrivate.h"
#import "NSString+LEP.h"
#import "NSString+LEPUUID.h"
#import "NSData+LEPUTF8.h"
#import "LEPUtils.h"
#include <libetpan/libetpan.h>
#include <pthread.h>
#include <unistd.h>
#import "NSData+LEPCharsetDetection.h"

#pragma mark IMAP mailbox conversion

static NSArray * imap_mailbox_list_to_address_array(clist * imap_mailbox_list)
{
    clistiter * cur;
    NSMutableArray * result;
    
    result = [NSMutableArray array];
    
    for(cur = clist_begin(imap_mailbox_list) ; cur != NULL ;
        cur = clist_next(cur)) {
        struct mailimap_address * imap_addr;
        LEPAddress * address;
        
        imap_addr = clist_content(cur);
        address = [LEPAddress addressWithIMAPAddress:imap_addr];
        [result addObject:address];
    }
    
    return result;
}

#pragma mark Message-ID conversion

static NSArray * msg_id_to_string_array(clist * msgids)
{
	clistiter * cur;
	NSMutableArray * result;
	
	result = [NSMutableArray array];
	
	for(cur = clist_begin(msgids) ; cur != NULL ; cur = clist_next(cur)) {
		char * msgid;
		NSString * str;
		
		msgid = clist_content(cur);
		str = [NSString stringWithUTF8String:msgid];
        if (str == nil) {
            NSData * data;
            
            data = [[NSData alloc] initWithBytes:msgid length:strlen(msgid)];
            str = [data lepStringWithCharset:@"utf-8"];
            [data release];
        }
		[result addObject:str];
	}
	
	return result;
}

static clist * msg_id_from_string_array(NSArray * msgids)
{
	clist * result;
	
	result = clist_new();
	for(NSString * msgid in msgids) {
		clist_append(result, strdup([msgid UTF8String]));
	}
	
	return result;
}

#pragma mark date conversion

#ifndef WRONG
#define WRONG	(-1)
#endif /* !defined WRONG */

static int tmcomp(struct tm * atmp, struct tm * btmp)
{
	register int	result;
	
	if ((result = (atmp->tm_year - btmp->tm_year)) == 0 &&
		(result = (atmp->tm_mon - btmp->tm_mon)) == 0 &&
		(result = (atmp->tm_mday - btmp->tm_mday)) == 0 &&
		(result = (atmp->tm_hour - btmp->tm_hour)) == 0 &&
		(result = (atmp->tm_min - btmp->tm_min)) == 0)
		result = atmp->tm_sec - btmp->tm_sec;
	return result;
}

static time_t mkgmtime(struct tm * tmp)
{
	register int			dir;
	register int			bits;
	register int			saved_seconds;
	time_t				t;
	struct tm			yourtm, mytm;
	
	yourtm = *tmp;
	saved_seconds = yourtm.tm_sec;
	yourtm.tm_sec = 0;
	/*
	 ** Calculate the number of magnitude bits in a time_t
	 ** (this works regardless of whether time_t is
	 ** signed or unsigned, though lint complains if unsigned).
	 */
	for (bits = 0, t = 1; t > 0; ++bits, t <<= 1)
		;
	/*
	 ** If time_t is signed, then 0 is the median value,
	 ** if time_t is unsigned, then 1 << bits is median.
	 */
	if(bits > 40) bits = 40;
	t = (t < 0) ? 0 : ((time_t) 1 << bits);
	for ( ; ; ) {
		gmtime_r(&t, &mytm);
		dir = tmcomp(&mytm, &yourtm);
		if (dir != 0) {
			if (bits-- < 0) {
				return WRONG;
			}
			if (bits < 0)
				--t;
			else if (dir > 0)
				t -= (time_t) 1 << bits;
			else	t += (time_t) 1 << bits;
			continue;
		}
		break;
	}
	t += saved_seconds;
	return t;
}

static time_t timestamp_from_date(struct mailimf_date_time * date_time)
{
	struct tm tmval;
	time_t timeval;
	int zone_min;
	int zone_hour;
	
	tmval.tm_sec  = date_time->dt_sec;
	tmval.tm_min  = date_time->dt_min;
	tmval.tm_hour = date_time->dt_hour;
	tmval.tm_mday = date_time->dt_day;
	tmval.tm_mon  = date_time->dt_month - 1;
	if (date_time->dt_year < 1000) {
		// workaround when century is not given in year
		tmval.tm_year = date_time->dt_year + 2000 - 1900;
	}
	else {
		tmval.tm_year = date_time->dt_year - 1900;
	}
	
	timeval = mkgmtime(&tmval);
	
	if (date_time->dt_zone >= 0) {
		zone_hour = date_time->dt_zone / 100;
		zone_min = date_time->dt_zone % 100;
	}
	else {
		zone_hour = -((- date_time->dt_zone) / 100);
		zone_min = -((- date_time->dt_zone) % 100);
	}
	timeval -= zone_hour * 3600 + zone_min * 60;
	
	return timeval;
}

static struct mailimf_date_time * get_date_from_timestamp(time_t timeval)
{
	struct tm gmt;
	struct tm lt;
	int off;
	struct mailimf_date_time * date_time;
	
	gmtime_r(&timeval, &gmt);
	localtime_r(&timeval, &lt);
	
	off = (mkgmtime(&lt) - mkgmtime(&gmt)) * 100 / (60 * 60);
	
	date_time = mailimf_date_time_new(lt.tm_mday, lt.tm_mon + 1,
									  lt.tm_year + 1900,
									  lt.tm_hour, lt.tm_min, lt.tm_sec,
									  off);
	
	return date_time;
}

static time_t timestamp_from_imap_date(struct mailimap_date_time * date_time)
{
	struct tm tmval;
	time_t timeval;
	int zone_min;
	int zone_hour;
	
	tmval.tm_sec  = date_time->dt_sec;
	tmval.tm_min  = date_time->dt_min;
	tmval.tm_hour = date_time->dt_hour;
	tmval.tm_mday = date_time->dt_day;
	tmval.tm_mon  = date_time->dt_month - 1;
	if (date_time->dt_year < 1000) {
		// workaround when century is not given in year
		tmval.tm_year = date_time->dt_year + 2000 - 1900;
	}
	else {
		tmval.tm_year = date_time->dt_year - 1900;
	}
	
	timeval = mkgmtime(&tmval);
	
	if (date_time->dt_zone >= 0) {
		zone_hour = date_time->dt_zone / 100;
		zone_min = date_time->dt_zone % 100;
	}
	else {
		zone_hour = -((- date_time->dt_zone) / 100);
		zone_min = -((- date_time->dt_zone) % 100);
	}
	timeval -= zone_hour * 3600 + zone_min * 60;
	
	return timeval;
}

#pragma mark RFC 2822 mailbox conversion

static NSArray * lep_address_list_from_lep_mailbox(struct mailimf_mailbox_list * mb_list)
{
	NSMutableArray * result;
	clistiter * cur;
	
	result = [NSMutableArray array];
	for(cur = clist_begin(mb_list->mb_list) ; cur != NULL ; cur = clist_next(cur)) {
		struct mailimf_mailbox * mb;
		LEPAddress * address;
		
		mb = clist_content(cur);
		address = [LEPAddress addressWithIMFMailbox:mb];
		[result addObject:address];
	}
	
	return result;
}

static NSArray * lep_address_list_from_lep_addr(struct mailimf_address_list * addr_list)
{
	NSMutableArray * result;
	clistiter * cur;
	
	result = [NSMutableArray array];
	
    if (addr_list == NULL) {
        return result;
    }
    
    if (addr_list->ad_list == nil) {
        return result;
    }
    
	for(cur = clist_begin(addr_list->ad_list) ; cur != NULL ;
		cur = clist_next(cur)) {
		struct mailimf_address * addr;
		
		addr = clist_content(cur);
		switch (addr->ad_type) {
			case MAILIMF_ADDRESS_MAILBOX:
			{
				LEPAddress * address;
				
				address = [LEPAddress addressWithIMFMailbox:addr->ad_data.ad_mailbox];
				[result addObject:address];
				break;
			}
			
			case MAILIMF_ADDRESS_GROUP:
			{
				if (addr->ad_data.ad_group->grp_mb_list != NULL) {
					NSArray * subArray;
					
					subArray = lep_address_list_from_lep_mailbox(addr->ad_data.ad_group->grp_mb_list);
					[result addObjectsFromArray:subArray];
				}
				break;
			}
		}
	}
	
	return result;
}

static struct mailimf_mailbox_list * lep_mailbox_list_from_array(NSArray * addresses)
{
	struct mailimf_mailbox_list * mb_list;
	
	mb_list = mailimf_mailbox_list_new_empty();
	
	for(LEPAddress * address in addresses) {
		struct mailimf_mailbox * mailbox;
		
		mailbox = [address createIMFMailbox];
		mailimf_mailbox_list_add(mb_list, mailbox);
	}
	
	return mb_list;
}

static struct mailimf_address_list * lep_address_list_from_array(NSArray * addresses)
{
	struct mailimf_address_list * addr_list;
	
	addr_list = mailimf_address_list_new_empty();

	for(LEPAddress * address in addresses) {
		struct mailimf_address * addr;
		
		addr = [address createIMFAddress];
		mailimf_address_list_add(addr_list, addr);
	}
	
	return addr_list;
}

@implementation LEPMessageHeader

@synthesize date = _date;
@synthesize internalDate = _internalDate;
@synthesize messageID = _messageID;
@synthesize references = _references;
@synthesize inReplyTo = _inReplyTo;
@synthesize from = _from;
@synthesize sender = _sender;
@synthesize to = _to;
@synthesize cc = _cc;
@synthesize bcc = _bcc;
@synthesize replyTo = _replyTo;
@synthesize subject = _subject;
@synthesize userAgent = _userAgent;

- (id) init
{
	return [self _initWithDate:YES messageID:YES];
}

#define MAX_HOSTNAME 512

- (id) _initWithDate:(BOOL)generateDate messageID:(BOOL)generateMessageID
{
	static NSString * hostname = nil;
	static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
	NSString * messageID;
	
	self = [super init];
	
	if (generateDate) {
        NSDate * date;
        date = [NSDate date];
        [self setInternalDate:date];
		[self setDate:date];
	}
	if (generateMessageID) {
		pthread_mutex_lock(&lock);
		if (hostname == nil) {
            char name[MAX_HOSTNAME];
            int r;
            
            r = gethostname(name, MAX_HOSTNAME);
            if (r < 0) {
                hostname = nil;
            }
            else {
                hostname = [[NSString alloc] initWithUTF8String:name];
            }
            
            if (hostname == nil) {
                hostname = [@"localhost" retain];
            }
		}
		pthread_mutex_unlock(&lock);
		messageID = [[NSString alloc] initWithFormat:@"%@@%@", [NSString lepUUIDString], hostname];
		[self setMessageID:messageID];
		[messageID release];
	}
	
	return self;
}

- (void) dealloc
{
	[_userAgent release];
    [_sender release];
	[_messageID release];
	[_references release];
	[_inReplyTo release];
	[_from release];
	[_to release];
	[_cc release];
	[_bcc release];
    [_replyTo release];
	[_subject release];
	[_internalDate release];
    [_date release];
    
	[super dealloc];
}

- (void) setFromIMFFields:(struct mailimf_fields *)fields
{
	struct mailimf_single_fields single_fields;
	
	mailimf_single_fields_init(&single_fields, fields);
	
	/* date */
	
	if (single_fields.fld_orig_date != NULL) {
		time_t timestamp;
		NSDate * date;
        
		timestamp = timestamp_from_date(single_fields.fld_orig_date->dt_date_time);
        date = [NSDate dateWithTimeIntervalSince1970:timestamp];
		[self setDate:date];
        [self setInternalDate:date];
		LEPLog(@"%lu %@", (unsigned long) timestamp, [self date]);
	}
	
	/* subject */
	if (single_fields.fld_subject != NULL) {
		char * subject;
		
		subject = single_fields.fld_subject->sbj_value;
		[self setSubject:[NSString lepStringByDecodingMIMEHeaderValue:subject]];
	}
	
	/* sender */
	if (single_fields.fld_sender != NULL) {
		struct mailimf_mailbox * mb;
		LEPAddress * address;
        
		mb = single_fields.fld_sender->snd_mb;
       if (mb != NULL) {
           address = [LEPAddress addressWithIMFMailbox:mb];
           [self setSender:address];
       }
	}
    
	/* from */
	if (single_fields.fld_from != NULL) {
		struct mailimf_mailbox_list * mb_list;
		NSArray * addresses;
		
		mb_list = single_fields.fld_from->frm_mb_list;
		addresses = lep_address_list_from_lep_mailbox(mb_list);
		if ([addresses count] > 0) {
			[self setFrom:[addresses objectAtIndex:0]];
		}
	}
	
	/* replyto */
	if (single_fields.fld_reply_to != NULL) {
		struct mailimf_address_list * addr_list;
		NSArray * addresses;
		
		addr_list = single_fields.fld_reply_to->rt_addr_list;
		addresses = lep_address_list_from_lep_addr(addr_list);
		[self setReplyTo:addresses];
	}
	
	/* to */
	if (single_fields.fld_to != NULL) {
		struct mailimf_address_list * addr_list;
		NSArray * addresses;
		
		addr_list = single_fields.fld_to->to_addr_list;
		addresses = lep_address_list_from_lep_addr(addr_list);
		[self setTo:addresses];
	}
	
	/* cc */
	if (single_fields.fld_cc != NULL) {
		struct mailimf_address_list * addr_list;
		NSArray * addresses;
		
		addr_list = single_fields.fld_cc->cc_addr_list;
		addresses = lep_address_list_from_lep_addr(addr_list);
		[self setCc:addresses];
	}
	
	/* bcc */
	if (single_fields.fld_bcc != NULL) {
		struct mailimf_address_list * addr_list;
		NSArray * addresses;
		
		addr_list = single_fields.fld_bcc->bcc_addr_list;
		addresses = lep_address_list_from_lep_addr(addr_list);
		[self setBcc:addresses];
	}
	
	/* msgid */
	if (single_fields.fld_message_id != NULL) {
		char * msgid;
		NSString * str;
        
		msgid = single_fields.fld_message_id->mid_value;
        str = [NSString stringWithUTF8String:msgid];
        if (str == nil) {
            NSData * data;
            
            data = [[NSData alloc] initWithBytes:msgid length:strlen(msgid)];
            str = [data lepStringWithCharset:@"utf-8"];
            [data release];
        }
		[self setMessageID:str];
	}
	
	/* references */
	if (single_fields.fld_references != NULL) {
		clist * msg_id_list;
		NSArray * msgids;
		
		msg_id_list = single_fields.fld_references->mid_list;
		msgids = msg_id_to_string_array(msg_id_list);
		[self setReferences:msgids];
	}
	
	/* inreplyto */
	if (single_fields.fld_in_reply_to != NULL) {
		clist * msg_id_list;
		NSArray * msgids;
		
		msg_id_list = single_fields.fld_in_reply_to->mid_list;
		msgids = msg_id_to_string_array(msg_id_list);
		[self setInReplyTo:msgids];
	}
}

- (void) setFromIMAPEnvelope:(struct mailimap_envelope *)env
{
	if (env->env_date != NULL) {
		size_t cur_token;
		struct mailimf_date_time * date_time;
		int r;
		
		cur_token = 0;
		r = mailimf_date_time_parse(env->env_date, strlen(env->env_date),
									&cur_token, &date_time);
		if (r == MAILIMF_NO_ERROR) {
			time_t timestamp;
			NSDate * date;
            
			// date
			timestamp = timestamp_from_date(date_time);
            date = [NSDate dateWithTimeIntervalSince1970:timestamp];
			[self setDate:date];
            [self setInternalDate:date];
			mailimf_date_time_free(date_time);
		}
#if 0 // it crashes
		else {
			static NSMutableArray * formatters = nil;
			static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
			
			pthread_mutex_lock(&lock);
			if (formatters == nil) {
				NSDateFormatter * formatter;
				
				formatters = [[NSMutableArray alloc] init];
				
				// parse DATE: 14/11/07 14:36:17 -> jj/mm/aa hh:mm:ss
				formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"d/M/yy H:m:s"];
				[formatters addObject:formatter];
				[formatter release];

				// parse DATE: 14/11/2007 14:36:17 -> jj/mm/aaaa hh:mm:ss
				formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"d/M/yyyy H:m:s"];
				[formatters addObject:formatter];
				[formatter release];
				
				// parse DATE: 11/14/07 14:36:17 -> mm/jj/aaaa hh:mm:ss
				formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"M/d/yy H:m:s"];
				[formatters addObject:formatter];
				[formatter release];
				
				// parse DATE: 11/14/2007 14:36:17 -> mm/jj/aaaa hh:mm:ss
				formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"M/d/yyyy H:m:s"];
				[formatters addObject:formatter];
				[formatter release];
				
				// parse DATE: 14/11/07 14:36 -> jj/mm/aa hh:mm
				formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"d/M/yy H:m"];
				[formatters addObject:formatter];
				[formatter release];
				
				// parse DATE: 14/11/2007 14:36 -> jj/mm/aaaa hh:mm
				formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"d/M/yyyy H:m"];
				[formatters addObject:formatter];
				[formatter release];
				
				// parse DATE: 11/14/07 14:36 -> mm/jj/aaaa hh:mm
				formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"M/d/yy H:m"];
				[formatters addObject:formatter];
				[formatter release];
				
				// parse DATE: 11/14/2007 14:36 -> mm/jj/aaaa hh:mm
				formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"M/d/yyyy H:m"];
				[formatters addObject:formatter];
				[formatter release];
			}
			pthread_mutex_unlock(&lock);
			
			for(NSDateFormatter * formatter in formatters) {
				NSDate * date;
				
				date = [formatter dateFromString:[NSString stringWithUTF8String:env->env_date]];
				if (date != nil) {
					[self setDate:date];
                    [self setInternalDate:date];
					break;
				}
			}
		}
#endif
	}

	if (env->env_subject != NULL) {
		char * subject;
		
		// subject
		subject = env->env_subject;
		[self setSubject:[NSString lepStringByDecodingMIMEHeaderValue:subject]];
	}
	
	if (env->env_sender != NULL) {
		if (env->env_sender->snd_list != NULL) {
			NSArray * addresses;
			
			addresses = imap_mailbox_list_to_address_array(env->env_sender->snd_list);
			if ([addresses count] > 0) {
				[self setSender:[addresses objectAtIndex:0]];
			}
		}
    }
    
	if (env->env_from != NULL) {
		if (env->env_from->frm_list != NULL) {
			NSArray * addresses;
			
			addresses = imap_mailbox_list_to_address_array(env->env_from->frm_list);
			if ([addresses count] > 0) {
				[self setFrom:[addresses objectAtIndex:0]];
			}
		}
	}
	
	// skip Sender header
	
	if (env->env_reply_to != NULL) {
		if (env->env_reply_to->rt_list != NULL) {
			NSArray * addresses;
			
			addresses = imap_mailbox_list_to_address_array(env->env_reply_to->rt_list);
			[self setReplyTo:addresses];
		}
	}
	
	if (env->env_to != NULL) {
		if (env->env_to->to_list != NULL) {
			NSArray * addresses;
			
			addresses = imap_mailbox_list_to_address_array(env->env_to->to_list);
			[self setTo:addresses];
		}
	}
	
	if (env->env_cc != NULL) {
		if (env->env_cc->cc_list != NULL) {
			NSArray * addresses;
			
			addresses = imap_mailbox_list_to_address_array(env->env_cc->cc_list);
			[self setCc:addresses];
		}
	}
	
	if (env->env_bcc != NULL) {
		if (env->env_bcc->bcc_list != NULL) {
			NSArray * addresses;
			
			addresses = imap_mailbox_list_to_address_array(env->env_bcc->bcc_list);
			[self setBcc:addresses];
		}
	}
	
	if (env->env_in_reply_to != NULL) {
		size_t cur_token;
		clist * msg_id_list;
		int r;
		
		cur_token = 0;
		r = mailimf_msg_id_list_parse(env->env_in_reply_to,
									  strlen(env->env_in_reply_to), &cur_token, &msg_id_list);
		if (r == MAILIMF_NO_ERROR) {
			NSArray * msgids;
			
			msgids = msg_id_to_string_array(msg_id_list);
			[self setInReplyTo:msgids];
			// in-reply-to
			clist_foreach(msg_id_list, (clist_func) mailimf_msg_id_free, NULL);
			clist_free(msg_id_list);
		}
	}
	
	if (env->env_message_id != NULL) {
		char * msgid;
		size_t cur_token;
		int r;
		
		cur_token = 0;
		r = mailimf_msg_id_parse(env->env_message_id, strlen(env->env_message_id),
								 &cur_token, &msgid);
		if (r == MAILIMF_NO_ERROR) {
			// msg id
            NSString * str;
            
            str = [NSString stringWithUTF8String:msgid];
            if (str == nil) {
                NSData * data;
                
                data = [[NSData alloc] initWithBytes:msgid length:strlen(msgid)];
                str = [data lepStringWithCharset:@"utf-8"];
                [data release];
            }
			[self setMessageID:str];
            mailimf_msg_id_free(msgid);
		}
	}
}

- (void) setFromIMAPReferences:(NSData *)data
{
	size_t cur_token;
	struct mailimf_fields * fields;
	int r;
	struct mailimf_single_fields single_fields;
	
	cur_token = 0;
	r = mailimf_fields_parse([data bytes], [data length], &cur_token, &fields);
	if (r != MAILIMF_NO_ERROR) {
		return;
	}
	
	mailimf_single_fields_init(&single_fields, fields);
	if (single_fields.fld_references != NULL) {
		NSArray * msgids;
		
		msgids = msg_id_to_string_array(single_fields.fld_references->mid_list);
		[self setReferences:msgids];
	}
	if (single_fields.fld_subject != NULL) {
		if (single_fields.fld_subject->sbj_value != NULL) {
            BOOL broken;
            char * value;
            BOOL isASCII;
            
            broken = NO;
            value = single_fields.fld_subject->sbj_value;
            
            isASCII = YES;
            for(char * p = value ; * p != 0 ; p ++) {
                if ((unsigned char) * p >= 128) {
                    isASCII = NO;
                }
            }
            if (isASCII) {
                broken = YES;
            }
            
            //NSLog(@"charset: %s %@", value, charset);
            
            if (!broken) {
                [self setSubject:[NSString lepStringByDecodingMIMEHeaderValue:single_fields.fld_subject->sbj_value]];
            }
		}
	}
	
	mailimf_fields_free(fields);
}

- (void) setFromHeadersData:(NSData *)data
{
	size_t cur_token;
	struct mailimf_fields * fields;
	int r;
	
	cur_token = 0;
	r = mailimf_fields_parse([data bytes], [data length], &cur_token, &fields);
	if (r != MAILIMF_NO_ERROR) {
		return;
	}
    
    [self setFromIMFFields:fields];
    
    mailimf_fields_free(fields);
}

- (void) _setFromInternalDate:(struct mailimap_date_time *)date
{
	[self setInternalDate:[NSDate dateWithTimeIntervalSince1970:timestamp_from_imap_date(date)]];
}

- (struct mailimf_fields *) createIMFFieldsForSending:(BOOL)filter
{
	struct mailimf_date_time * date;
	char * msgid;
	char * subject;
	struct mailimf_mailbox_list * from;
	struct mailimf_address_list * reply_to;
	struct mailimf_address_list * to;
	struct mailimf_address_list * cc;
	struct mailimf_address_list * bcc;
	clist * in_reply_to;
	clist * references;
	struct mailimf_fields * fields;
	
	date = NULL;
	if ([self date] != nil) {
		LEPLog(@"%@", [self date]);
		date = get_date_from_timestamp((time_t) [[self date] timeIntervalSince1970]);
	}
	from = NULL;
	if ([self from] != nil) {
		from = lep_mailbox_list_from_array([NSArray arrayWithObject:[self from]]);
	}
	reply_to = NULL;
	if ([[self replyTo] count] > 0) {
		reply_to = lep_address_list_from_array([self replyTo]);
	}
	to = NULL;
	if ([[self to] count] > 0) {
		to = lep_address_list_from_array([self to]);
	}
	cc = NULL;
	if ([[self cc] count] > 0) {
		cc = lep_address_list_from_array([self cc]);
	}
	bcc = NULL;
    if (!filter) {
        if ([[self bcc] count] > 0) {
            bcc = lep_address_list_from_array([self bcc]);
        }
    }
	msgid = NULL;
	if ([self messageID] != nil) {
		msgid = strdup([[self messageID] UTF8String]);
	}
	in_reply_to = NULL;
	if ([[self inReplyTo] count] > 0) {
		in_reply_to = msg_id_from_string_array([self inReplyTo]);
	}
	references = NULL;
	if ([[self references] count] > 0) {
		references = msg_id_from_string_array([self references]);
	}
	subject = NULL;
	if ([[self subject] length] > 0) {
        NSData * data;
        
        data = [[self subject] lepEncodedMIMEHeaderValueForSubject];
        if ([data bytes] != nil) {
            subject = strdup([data bytes]);
        }
	}
	
	fields = mailimf_fields_new_with_data_all(date,
											from,
											NULL /* sender */,
											reply_to,
											to,
											cc,
											bcc,
											msgid,
											in_reply_to,
											references,
											subject);
	
	if (_userAgent != nil) {
		struct mailimf_field * field;
		
		field = mailimf_field_new_custom(strdup("X-Mailer"), strdup([_userAgent UTF8String]));
		mailimf_fields_add(fields, field);
	}
	
	return fields;
}

- (NSString *) extractedSubject
{
    return [[self subject] lepExtractedSubject];
}

- (NSString *) partialExtractedSubject
{
    return [[self subject] lepExtractedSubjectAndKeepBracket:YES];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	
	_messageID = [[decoder decodeObjectForKey:@"messageID"] retain];
	_references = [[decoder decodeObjectForKey:@"references"] retain];
	_inReplyTo = [[decoder decodeObjectForKey:@"inReplyTo"] retain];
#if 1
	_sender = [[decoder decodeObjectForKey:@"sender"] retain];
	_from = [[decoder decodeObjectForKey:@"from"] retain];
	_to = [[decoder decodeObjectForKey:@"to"] retain];
	_cc = [[decoder decodeObjectForKey:@"cc"] retain];
	_bcc = [[decoder decodeObjectForKey:@"bcc"] retain];
	_replyTo = [[decoder decodeObjectForKey:@"replyTo"] retain];
#else
    NSString * encoded;
    encoded = [decoder decodeObjectForKey:@"sender"];
    if (encoded != nil) {
        _sender = [[LEPAddress addressWithRFC822String:encoded] retain];
    }
    encoded = [decoder decodeObjectForKey:@"from"];
    if (encoded != nil) {
        _from = [[LEPAddress addressWithRFC822String:encoded] retain];
    }
    encoded = [decoder decodeObjectForKey:@"to"];
    if (encoded != nil) {
        _to = [[LEPAddress addressesWithRFC822String:encoded] retain];
    }
    encoded = [decoder decodeObjectForKey:@"cc"];
    if (encoded != nil) {
        _cc = [[LEPAddress addressesWithRFC822String:encoded] retain];
    }
    encoded = [decoder decodeObjectForKey:@"bcc"];
    if (encoded != nil) {
        _bcc = [[LEPAddress addressesWithRFC822String:encoded] retain];
    }
    encoded = [decoder decodeObjectForKey:@"replyTo"];
    if (encoded != nil) {
        _bcc = [[LEPAddress addressesWithRFC822String:encoded] retain];
    }
#endif
	_subject = [[decoder decodeObjectForKey:@"subject"] retain];
	_date = [[decoder decodeObjectForKey:@"date"] retain];
	_internalDate = [[decoder decodeObjectForKey:@"internalDate"] retain];
	if (_internalDate == nil) {
		_internalDate = [_date retain];
	}
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_messageID forKey:@"messageID"];
	[encoder encodeObject:_references forKey:@"references"];
	[encoder encodeObject:_inReplyTo forKey:@"inReplyTo"];
	[encoder encodeObject:_sender forKey:@"sender"];
	[encoder encodeObject:_from forKey:@"from"];
	[encoder encodeObject:_to forKey:@"to"];
	[encoder encodeObject:_cc forKey:@"cc"];
	[encoder encodeObject:_bcc forKey:@"bcc"];
	[encoder encodeObject:_replyTo forKey:@"replyTo"];
	[encoder encodeObject:_subject forKey:@"subject"];
	[encoder encodeObject:_date forKey:@"date"];
	[encoder encodeObject:_internalDate forKey:@"internalDate"];
}

@end
