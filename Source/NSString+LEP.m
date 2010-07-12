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

#pragma mark modified UTF-7

static int Index_64[128] = {
    -1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1,
    -1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1,
    -1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,62, 63,-1,-1,-1,
    52,53,54,55, 56,57,58,59, 60,61,-1,-1, -1,-1,-1,-1,
    -1, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,
    15,16,17,18, 19,20,21,22, 23,24,25,-1, -1,-1,-1,-1,
    -1,26,27,28, 29,30,31,32, 33,34,35,36, 37,38,39,40,
    41,42,43,44, 45,46,47,48, 49,50,51,-1, -1,-1,-1,-1
};

static char B64Chars[64] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
	'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
	'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
	't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '+', ','
};

static char * utf7_to_utf8(const char *u7, size_t u7len, char ** u8, size_t * u8len)
{
	char * buf, * p;
	int b, ch, k;
	
	p = buf = malloc (u7len + u7len / 8 + 1);
	
	for (; u7len; u7++, u7len--) {
		if (*u7 == '&') {
			u7++, u7len--;
			
			if (u7len && *u7 == '-') {
				*p++ = '&';
				continue;
			}
			
			ch = 0;
			k = 10;
			for (; u7len; u7++, u7len--) {
				if ((*u7 & 0x80) || (b = Index_64[(int)*u7]) == -1)
					break;
				if (k > 0) {
					ch |= b << k;
					k -= 6;
				}
				else {
					ch |= b >> (-k);
					if (ch < 0x80) {
						if (0x20 <= ch && ch < 0x7f)
						/* Printable US-ASCII */
							goto bail;
						*p++ = ch;
					}
					else if (ch < 0x800) {
						*p++ = 0xc0 | (ch >> 6);
						*p++ = 0x80 | (ch & 0x3f);
					}
					else {
						*p++ = 0xe0 | (ch >> 12);
						*p++ = 0x80 | ((ch >> 6) & 0x3f);
						*p++ = 0x80 | (ch & 0x3f);
					}
					ch = (b << (16 + k)) & 0xffff;
					k += 10;
				}
			}
			if (ch || k < 6)
			/* Non-zero or too many extra bits */
				goto bail;
			if (!u7len || * u7 != '-')
			/* BASE64 not properly terminated */
				goto bail;
			if (u7len > 2 && u7[1] == '&' && u7[2] != '-')
			/* Adjacent BASE64 sections */
				goto bail;
		}
		else if (* u7 < 0x20 || * u7 >= 0x7f)
		/* Not printable US-ASCII */
			goto bail;
		else
			* p ++ = * u7;
	}
	*p++ = '\0';
	if (u8len)
		*u8len = p - buf;
	
	//safe_realloc ((void **) &buf, p - buf);
	if (u8)
		* u8 = buf;
	return buf;
	
bail:
	free(&buf);
	return NULL;
}

static char *utf8_to_utf7(const char * u8, size_t u8len, char ** u7, size_t * u7len)
{
	char *buf, *p;
	int ch;
	int n, i, b = 0, k = 0;
	int base64 = 0;
	
	/*
	 * In the worst case we convert 2 chars to 7 chars. For example:
	 * "\x10&\x10&..." -> "&ABA-&-&ABA-&-...".
	 */
	p = buf = malloc((u8len / 2) * 7 + 6);
	
	while (u8len)
	{
		unsigned char c = *u8;
		
		if (c < 0x80)
			ch = c, n = 0;
		else if (c < 0xc2)
			goto bail;
		else if (c < 0xe0)
			ch = c & 0x1f, n = 1;
		else if (c < 0xf0)
			ch = c & 0x0f, n = 2;
		else if (c < 0xf8)
			ch = c & 0x07, n = 3;
		else if (c < 0xfc)
			ch = c & 0x03, n = 4;
		else if (c < 0xfe)
			ch = c & 0x01, n = 5;
		else
			goto bail;
		
		u8++, u8len--;
		if (n > u8len)
			goto bail;
		for (i = 0; i < n; i++)
		{
			if ((u8[i] & 0xc0) != 0x80)
				goto bail;
			ch = (ch << 6) | (u8[i] & 0x3f);
		}
		if (n > 1 && !(ch >> (n * 5 + 1)))
			goto bail;
		u8 += n, u8len -= n;
		
		if (ch < 0x20 || ch >= 0x7f)
		{
			if (!base64)
			{
				*p++ = '&';
				base64 = 1;
				b = 0;
				k = 10;
			}
			if (ch & ~0xffff)
				ch = 0xfffe;
			*p++ = B64Chars[b | ch >> k];
			k -= 6;
			for (; k >= 0; k -= 6)
				*p++ = B64Chars[(ch >> k) & 0x3f];
			b = (ch << (-k)) & 0x3f;
			k += 16;
		}
		else
		{
			if (base64)
			{
				if (k > 10)
					*p++ = B64Chars[b];
				*p++ = '-';
				base64 = 0;
			}
			*p++ = ch;
			if (ch == '&')
				*p++ = '-';
		}
	}
	
	if (u8len)
	{
		free(&buf);
		return NULL;
	}
	
	if (base64)
	{
		if (k > 10)
			*p++ = B64Chars[b];
		*p++ = '-';
	}
	
	*p++ = '\0';
	if (u7len)
		*u7len = p - buf;
	//safe_realloc ((void **) &buf, p - buf);
	if (u7)  *u7 = buf;
	
	return buf;
	
bail:
	free(&buf);
	return NULL;
}

#pragma mark quote headers string

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
		
#if 0
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
#endif
		
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
	if (parsedString != nil) {
		[result appendString: parsedString];
	}
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

- (NSString *) lepDecodeFromModifiedUTF7
{
	char * utf8str;
	size_t utf8len;
	const char * utf7str;
	NSString * result;
	
	utf7str = [self UTF8String];
	if (utf7_to_utf8(utf7str, strlen(utf7str), &utf8str, &utf8len) == NULL)
		return [[self copy] autorelease];
	
	result = [NSString stringWithUTF8String:utf8str];
	free(utf8str);
	return result;
}

- (NSString *) lepEncodeToModifiedUTF7
{
	char * utf7str;
	size_t utf7len;
	const char * utf8str;
	NSString * result;
	
	utf8str = [self UTF8String];
	if (utf8_to_utf7(utf8str, strlen(utf8str), &utf7str, &utf7len) == NULL)
		return [[self copy] autorelease];
	
	result = [NSString stringWithUTF8String:utf7str];
	free(utf7str);
	return result;
}

@end
