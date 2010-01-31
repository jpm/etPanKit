//
//  NSString+LEP.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+LEP.h"

#import <libetpan/libetpan.h>

//#include <libxml2/libxml/xmlmemory.h>
//#include <libxml2/libxml/HTMLparser.h>
#include <libxml/xmlmemory.h>
#include <libxml/HTMLparser.h>

#define DEFAULT_INCOMING_CHARSET "iso-8859-1"
#define DEFAULT_DISPLAY_CHARSET "utf-8"

static inline int to_be_quoted(char * word, size_t size)
{
	int do_quote;
	char * cur;
	size_t i;
	
	do_quote = 0;
	cur = word;
	for(i = 0 ; i < size ; i ++) {
		switch (* cur) {
			case ',':
			case ':':
			case '!':
			case '"':
			case '#':
			case '$':
			case '@':
			case '[':
			case '\\':
			case ']':
			case '^':
			case '`':
			case '{':
			case '|':
			case '}':
			case '~':
			case '=':
			case '?':
			case '_':
				do_quote = 1;
				break;
			default:
				if (((unsigned char) * cur) >= 128)
					do_quote = 1;
				break;
		}
		cur ++;
	}
	
	return do_quote;
}

#define MAX_IMF_LINE 72

static inline void quote_word(char * display_charset,
							  MMAPString * mmapstr, char * word, size_t size)
{
	char * cur;
	size_t i;
	char hex[4];
	int col;
	
	mmap_string_append(mmapstr, "=?");
	mmap_string_append(mmapstr, display_charset);
	mmap_string_append(mmapstr, "?Q?");
	
	col = mmapstr->len;
	
	cur = word;
	for(i = 0 ; i < size ; i ++) {
		int do_quote_char;
		
		if (col + 2 /* size of "?=" */
			+ 3 /* max size of newly added character */
			+ 1 /* minimum column of string in a
				 folded header */ >= MAX_IMF_LINE) {
					 int old_pos;
					 /* adds a concatened encoded word */
					 
					 mmap_string_append(mmapstr, "?=");
					 mmap_string_append(mmapstr, " ");
					 
					 old_pos = mmapstr->len;
					 
					 mmap_string_append(mmapstr, "=?");
					 mmap_string_append(mmapstr, display_charset);
					 mmap_string_append(mmapstr, "?Q?");
					 
					 col = mmapstr->len - old_pos;
				 }
		
		do_quote_char = 0;
		switch (* cur) {
			case ',':
			case ':':
			case '!':
			case '"':
			case '#':
			case '$':
			case '@':
			case '[':
			case '\\':
			case ']':
			case '^':
			case '`':
			case '{':
			case '|':
			case '}':
			case '~':
			case '=':
			case '?':
			case '_':
				do_quote_char = 1;
				break;
				
			default:
				if (((unsigned char) * cur) >= 128)
					do_quote_char = 1;
				break;
		}
		
		if (do_quote_char) {
			snprintf(hex, 4, "=%2.2X", (unsigned char) * cur);
			mmap_string_append(mmapstr, hex);
			col += 3;
		}
		else {
			if (* cur == ' ') {
				mmap_string_append_c(mmapstr, '_');
			}
			else {
				mmap_string_append_c(mmapstr, * cur);
			}
			col += 3;
		}
		cur ++;
	}
	
	mmap_string_append(mmapstr, "?=");
}

static inline void get_word(char * begin, char ** pend, int * pto_be_quoted)
{
	char * cur;
	
	cur = begin;
	
	while ((* cur != ' ') && (* cur != '\t') && (* cur != '\0')) {
		cur ++;
	}
	
	if (cur - begin +
		1  /* minimum column of string in a
            folded header */ > MAX_IMF_LINE)
		* pto_be_quoted = 1;
	else
		* pto_be_quoted = to_be_quoted(begin, cur - begin);
	
	* pend = cur;
}

static char * etpan_make_quoted_printable(char * display_charset,
										  char * phrase)
{
	char * str;
	char * cur;
	MMAPString * mmapstr;
	
	mmapstr = mmap_string_new("");
	
	cur = phrase;
	while (* cur != '\0') {
		char * begin;
		char * end;
		int do_quote;
		int quote_words;
		
		begin = cur;
		end = begin;
		quote_words = 0;
		do_quote = 1;
		
		while (* cur != '\0') {
			get_word(cur, &cur, &do_quote);
			if (do_quote) {
				quote_words = 1;
				end = cur;
			}
			else
				break;
			if (* cur != '\0')
				cur ++;
		}
		
		if (quote_words) {
			quote_word(display_charset, mmapstr, begin, end - begin);
			
			if ((* end == ' ') || (* end == '\t')) {
				mmap_string_append_c(mmapstr, * end);
				end ++;
			}
			
			if (* end != '\0') {
				mmap_string_append_len(mmapstr, end, cur - end);
			}
		}
		else {
			mmap_string_append_len(mmapstr, begin, cur - begin);
		}
		
		if ((* cur == ' ') || (* cur == '\t')) {
			mmap_string_append_c(mmapstr, * cur);
			cur ++;
		}
	}
	
	str = strdup(mmapstr->str);
	mmap_string_free(mmapstr);
	
	return str;
}

@implementation NSString (LEP)

+ (NSString *) lepStringByDecodingMIMEHeaderValue:(const char *)phrase;
{
    size_t cur_token;
    char * decoded;
	NSString * result;
    
    if (* phrase == '\0') {
        decoded = strdup("");
        return @"";
    }
    
    cur_token = 0;
    mailmime_encoded_phrase_parse(DEFAULT_INCOMING_CHARSET,
                                  phrase, strlen(phrase),
                                  &cur_token, DEFAULT_DISPLAY_CHARSET,
                                  &decoded);
    
	result = [NSString stringWithUTF8String:decoded];
	
    free(decoded);
	
	return result;
}

- (NSData *) lepEncodedMIMEHeaderValue
{
	char * str;
	NSData * result;
	
	str = etpan_make_quoted_printable(DEFAULT_DISPLAY_CHARSET, (char *) [self UTF8String]);
	result = [NSData dataWithBytes:str length:strlen(str)];
	free(str);
	
	return result;
}

#pragma mark strip HTML

static void charactersParsed(void* context,
							 const xmlChar* ch, int len)
/*" Callback function for stringByStrippingHTML. "*/
{
	NSMutableString* result = context;
	NSString* parsedString;
	parsedString = [[NSString alloc] initWithBytesNoCopy:
					(xmlChar*) ch length: len encoding:
					NSUTF8StringEncoding freeWhenDone: NO];
	[result appendString: parsedString];
	[parsedString release];
}

/* GCS: custom error function to ignore errors */
static void structuredError(void * userData,
							xmlErrorPtr error)
{
	/* ignore all errors */
	(void)userData;
	(void)error;
}

- (NSString*) lepFlattenHTML
/*" Interpretes the receiver als HTML, removes all tags
 and returns the plain text. "*/
{
	int mem_base = xmlMemBlocks();
	NSMutableString* result = [NSMutableString string];
	xmlSAXHandler handler; bzero(&handler,
								 sizeof(xmlSAXHandler));
	handler.characters = &charactersParsed;
	
	/* GCS: override structuredErrorFunc to mine so
	 I can ignore errors */
	xmlSetStructuredErrorFunc(xmlGenericErrorContext,
							  &structuredError);
	
	htmlSAXParseDoc((xmlChar*)[self UTF8String], "utf-8",
					&handler, result);
    
	if (mem_base != xmlMemBlocks()) {
		NSLog( @"Leak of %d blocks found in htmlSAXParseDoc",
			  xmlMemBlocks() - mem_base);
	}
	return result;
}

@end
