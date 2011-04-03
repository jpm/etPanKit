//
//  NSString+LEP.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 31/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+LEP.h"

#import <libetpan/libetpan.h>
#import "LEPUtils.h"
#include <pthread.h>
#import "NSData+LEPUTF8.h"

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
	free(buf);
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
	free(buf);
	return NULL;
}

#pragma mark quote headers string

static inline int to_be_quoted(char * word, size_t size, int subject)
{
	int do_quote;
	char * cur;
	size_t i;
	
	do_quote = 0;
	cur = word;
	for(i = 0 ; i < size ; i ++) {
		if (* cur == '=')
			do_quote = 1;
		
		if (!subject) {
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
			}
		}
		if (((unsigned char) * cur) >= 128)
			do_quote = 1;
		
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

static inline void get_word(char * begin, char ** pend, int subject, int * pto_be_quoted)
{
	char * cur;
	
	cur = begin;
	
	while ((* cur != ' ') && (* cur != '\t') && (* cur != '\0')) {
		cur ++;
	}
	while (((* cur == ' ') || (* cur == '\t')) && (* cur != '\0')) {
		cur ++;
	}
	
	if (cur - begin +
		1  /* minimum column of string in a
            folded header */ > MAX_IMF_LINE)
		* pto_be_quoted = 1;
	else
		* pto_be_quoted = to_be_quoted(begin, cur - begin, subject);
	
	* pend = cur;
}

static char * etpan_make_full_quoted_printable(char * display_charset,
                                               char * phrase)
{
    int needs_quote;
    char * str;
    
    needs_quote = to_be_quoted(phrase, strlen(phrase), 0);
    if (needs_quote) {
        MMAPString * mmapstr;
        
        mmapstr = mmap_string_new("");
        quote_word(display_charset, mmapstr, phrase, strlen(phrase));
        str = strdup(mmapstr->str);
        mmap_string_free(mmapstr);
    }
    else {
        str = strdup(phrase);
    }
	
	return str;
}

static char * etpan_make_quoted_printable(char * display_charset,
										  char * phrase, int subject)
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
			get_word(cur, &cur, subject, &do_quote);
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

#pragma mark extract subject

static inline int skip_subj_blob(char * subj, size_t * begin,
								 size_t length, int keep_bracket)
{
    if (keep_bracket)
        return 0;
    
	/* subj-blob       = "[" *BLOBCHAR "]" *WSP */
	size_t cur_token;
	
	cur_token = * begin;
	
	if (subj[cur_token] != '[')
		return 0;
	
	cur_token ++;
	
	while (1) {
		if (cur_token >= length)
			return 0;
		
		if (subj[cur_token] == '[')
			return 0;
		
		if (subj[cur_token] == ']')
			break;
		
		cur_token ++;
	}
	
	cur_token ++;
	
	while (1) {
		if (cur_token >= length)
			break;
		
		if (subj[cur_token] != ' ')
			break;
		
		cur_token ++;
	}
	
	* begin = cur_token;
	
	return 1;
}

static inline int skip_subj_refwd(char * subj, size_t * begin,
								  size_t length, int keep_bracket)
{
	/* subj-refwd      = ("re" / ("fw" ["d"])) *WSP [subj-blob] ":" */
	size_t cur_token;
	int prefix;
	
	cur_token = * begin;
	prefix = 0;
	if (!prefix) {
		if (length >= 7) {
			if (strncasecmp(subj + cur_token, "Antwort", 7) == 0) {
				cur_token += 1;
				prefix = 1;
			}
		}
	}
	if (!prefix) {
		if (length >= 5) {
			// é is 2 chars in utf-8
			if (strncasecmp(subj + cur_token, "réf.", 5) == 0) {
				cur_token += 5;
				prefix = 1;
			}
			else if (strncasecmp(subj + cur_token, "rép.", 5) == 0) {
				cur_token += 5;
				prefix = 1;
			}
			else if (strncasecmp(subj + cur_token, "trans", 5) == 0) {
				cur_token += 5;
				prefix = 1;
			}
		}
	}
	if (!prefix) {
		if (length >= 4) {
			if (strncasecmp(subj + cur_token, "antw", 4) == 0) {
				cur_token += 4;
				prefix = 1;
			}
		}
	}
	if (!prefix) {
		if (length >= 3) {
			if (strncasecmp(subj + cur_token, "fwd", 3) == 0) {
				cur_token += 3;
				prefix = 1;
			}
		}
	}
	if (!prefix) {
		if (length >= 2) {
			if (strncasecmp(subj + cur_token, "fw", 2) == 0) {
				cur_token += 2;
				prefix = 1;
			}
			else if (strncasecmp(subj + cur_token, "re", 2) == 0) {
				cur_token += 2;
				prefix = 1;
			}
			else if (strncasecmp(subj + cur_token, "tr", 2) == 0) {
				cur_token += 2;
				prefix = 1;
			}
			else if (strncasecmp(subj + cur_token, "aw", 2) == 0) {
				cur_token += 2;
				prefix = 1;
			}
			else if (strncasecmp(subj + cur_token, "sv", 2) == 0) {
				cur_token += 2;
				prefix = 1;
			}
		}
	}
	if (!prefix) {
		if (length >= 1) {
			if (strncasecmp(subj + cur_token, "r", 1) == 0) {
				cur_token += 1;
				prefix = 1;
			}
		}
	}
	
	if (!prefix)
		return 0;
	
	while (1) {
		if (cur_token >= length)
			break;
		
		if (subj[cur_token] != ' ')
			break;
		
		cur_token ++;
	}
	
	skip_subj_blob(subj, &cur_token, length, keep_bracket);
	
	if (subj[cur_token] != ':')
		return 0;
	
	cur_token ++;
	
	* begin = cur_token;
	
	return 1;
}

static inline int skip_subj_leader(char * subj, size_t * begin,
								   size_t length, int keep_bracket)
{
	size_t cur_token;
	
	cur_token = * begin;
	
	/* subj-leader     = (*subj-blob subj-refwd) / WSP */
	
	if (subj[cur_token] == ' ') {
		cur_token ++;
	}
	else {
		while (cur_token < length) {
			if (!skip_subj_blob(subj, &cur_token, length, keep_bracket))
				break;
		}
		if (!skip_subj_refwd(subj, &cur_token, length, keep_bracket))
			return 0;
	}
	
	* begin = cur_token;
	
	return 1;
}

static char * extract_subject(char * str, int keep_bracket)
{
	char * subj;
	char * cur;
	char * write_pos;
	size_t len;
	size_t begin;
	int do_repeat_5;
	int do_repeat_6;
	
	/*
	 (1) Convert any RFC 2047 encoded-words in the subject to
	 UTF-8.
	 We work on UTF-8 string -- DVH
	 */
	
	subj = strdup(str);
	if (subj == NULL)
		return NULL;
	
	len = strlen(subj);
	
	/*
	 Convert all tabs and continuations to space.
	 Convert all multiple spaces to a single space.
	 */
	
	cur = subj;
	write_pos = subj;
	while (* cur != '\0') {
		int cont;
		
		switch (* cur) {
			case '\t':
			case '\r':
			case '\n':
				cont = 1;
				
				cur ++;
				while (* cur && cont) {
					switch (* cur) {
						case '\t':
						case '\r':
						case '\n':
							cont = 1;
							break;
						default:
							cont = 0;
							break;
					}
					cur ++;
				}
				
				* write_pos = ' ';
				write_pos ++;
				
				break;
				
			default:
				* write_pos = * cur;
				write_pos ++;
				
				cur ++;
				
				break;
		}
	}
	* write_pos = '\0';
	
	begin = 0;
	
	do {
		do_repeat_6 = 0;
		
		/*
		 (2) Remove all trailing text of the subject that matches
		 the subj-trailer ABNF, repeat until no more matches are
		 possible.
		 */
		
		while (len > 0) {
			int chg;
			
			chg = 0;
			
			/* subj-trailer    = "(fwd)" / WSP */
			if (subj[len - 1] == ' ') {
				subj[len - 1] = '\0';
				len --;
			}
			else {
				if (len < 5)
					break;
				
				if (strncasecmp(subj + len - 5, "(fwd)", 5) != 0)
					break;
				
				subj[len - 5] = '\0';
				len -= 5;
			}
		}
		
		do {
			size_t saved_begin;
			
			do_repeat_5 = 0;
			
			/*
			 (3) Remove all prefix text of the subject that matches the
			 subj-leader ABNF.
			 */
			
			if (skip_subj_leader(subj, &begin, len, keep_bracket))
				do_repeat_5 = 1;
			
			/*
			 (4) If there is prefix text of the subject that matches the
			 subj-blob ABNF, and removing that prefix leaves a non-empty
			 subj-base, then remove the prefix text.
			 */
			
			saved_begin = begin;
			if (skip_subj_blob(subj, &begin, len, keep_bracket)) {
				if (begin == len) {
					/* this will leave a empty subject base */
					begin = saved_begin;
				}
				else
					do_repeat_5 = 1;
			}
			
			/*
			 (5) Repeat (3) and (4) until no matches remain.
			 Note: it is possible to defer step (2) until step (6),
			 but this requires checking for subj-trailer in step (4).
			 */
			
		}
		while (do_repeat_5);
		
		/*
		 (6) If the resulting text begins with the subj-fwd-hdr ABNF
		 and ends with the subj-fwd-trl ABNF, remove the
		 subj-fwd-hdr and subj-fwd-trl and repeat from step (2).
		 */
		
		if (len >= 5) {
			size_t saved_begin;
			
			saved_begin = begin;
			if (strncasecmp(subj + begin, "[fwd:", 5) == 0) {
				begin += 5;
				
				if (subj[len - 1] != ']')
					saved_begin = begin;
				else {
					subj[len - 1] = '\0';
					len --;
					do_repeat_6 = 1;
				}
			}
		}
		
	}
	while (do_repeat_6);
	
	/*
	 (7) The resulting text is the "base subject" used in
	 threading.
	 */
	
	/* convert to upper case */
	
	cur = subj + begin;
	write_pos = subj;
	
	while (* cur != '\0') {
		* write_pos = * cur;
		cur ++;
		write_pos ++;
	}
	* write_pos = '\0';
	
	return subj;
}

@implementation NSString (LEP)

+ (NSString *) lepStringByDecodingMIMEHeaderValue:(const char *)phrase
{
    size_t cur_token;
    char * decoded;
	NSString * result;
    BOOL hasEncoding;
    
    if (phrase == NULL)
        return @"";
    
    if (* phrase == '\0') {
        return @"";
    }
    
    hasEncoding = NO;
    if (strstr(phrase, "=?") != NULL) {
        if ((strcasestr(phrase, "?Q?") != NULL) || (strcasestr(phrase, "?B?") != NULL)) {
            hasEncoding = YES;
        }
    }
    
    if (!hasEncoding) {
        return [[NSData dataWithBytes:phrase length:strlen(phrase)] lepStringWithDetectedCharset];
    }
    
    cur_token = 0;
	decoded = NULL;
    mailmime_encoded_phrase_parse(DEFAULT_INCOMING_CHARSET,
                                  phrase, strlen(phrase),
                                  &cur_token, DEFAULT_DISPLAY_CHARSET,
                                  &decoded);
    
    result = nil;
    if (decoded != NULL) {
        result = [NSString stringWithUTF8String:decoded];
    }
    else {
        fprintf(stderr, "could not decode: %s\n", phrase);
    }
	
    free(decoded);
	
	return result;
}

- (NSData *) lepEncodedAddressDisplayNameValue
{
	char * str;
	NSData * result;
	
    str = etpan_make_full_quoted_printable(DEFAULT_DISPLAY_CHARSET, (char *) [self UTF8String]);
	result = [NSData dataWithBytes:str length:strlen(str) + 1];
	free(str);
    
    return result;
}

- (NSData *) lepEncodedMIMEHeaderValue
{
	char * str;
	NSData * result;
	
	str = etpan_make_quoted_printable(DEFAULT_DISPLAY_CHARSET, (char *) [self UTF8String], 0);
	result = [NSData dataWithBytes:str length:strlen(str) + 1];
	free(str);
	
	return result;
}

- (NSData *) lepEncodedMIMEHeaderValueForSubject
{
	char * str;
	NSData * result;
	
	str = etpan_make_quoted_printable(DEFAULT_DISPLAY_CHARSET, (char *) [self UTF8String], 1);
	result = [NSData dataWithBytes:str length:strlen(str) + 1];
	free(str);
	
	return result;
}

#pragma mark strip HTML

struct parserState {
	int level;
	int enabled;
	int disabledLevel;
	NSMutableString * result;
	int logEnabled;
    int hasQuote;
    int quoteLevel;
    BOOL hasText;
    BOOL lastCharIsWhitespace;
    BOOL showBlockQuote;
    BOOL hasReturnToLine;
};

static void appendQuote(struct parserState * state);

static void charactersParsed(void* context,
							 const xmlChar* ch, int len)
/*" Callback function for stringByStrippingHTML. "*/
{
	struct parserState * state;
	
	state = context;
	NSMutableString* result = state->result;
	
	if (!state->enabled) {
		return;
    }
	
	if (state->logEnabled) {
		LEPLog(@"text %s", ch);
	}
	NSString* parsedString;
	parsedString = [[NSString alloc] initWithBytesNoCopy:
					(xmlChar*) ch length: len encoding:
					NSUTF8StringEncoding freeWhenDone: NO];
    if (parsedString != nil) {
        NSMutableString * modifiedString;
        
        if (!state->hasQuote) {
            appendQuote(state);
            state->hasQuote = YES;
        }
        
        modifiedString = [parsedString mutableCopy];
        [modifiedString replaceOccurrencesOfString:@"\r\n" withString:@" " options:0 range:NSMakeRange(0, [modifiedString length])];
        [modifiedString replaceOccurrencesOfString:@"\n" withString:@" " options:0 range:NSMakeRange(0, [modifiedString length])];
        [modifiedString replaceOccurrencesOfString:@"\r" withString:@" " options:0 range:NSMakeRange(0, [modifiedString length])];
        [modifiedString replaceOccurrencesOfString:@"\t" withString:@" " options:0 range:NSMakeRange(0, [modifiedString length])];
        unichar ch;
        ch = 160;
        [modifiedString replaceOccurrencesOfString:[NSString stringWithCharacters:&ch length:1] withString:@" " options:0 range:NSMakeRange(0, [modifiedString length])];
        ch = 133;
        [modifiedString replaceOccurrencesOfString:[NSString stringWithCharacters:&ch length:1] withString:@" " options:0 range:NSMakeRange(0, [modifiedString length])];
        
        while ([modifiedString replaceOccurrencesOfString:@"  " withString:@" " options:0 range:NSMakeRange(0, [modifiedString length])] > 0) {
        }
        
        if ([modifiedString length] > 0) {
            BOOL lastIsWhiteSpace;
            BOOL isWhiteSpace;
            
            isWhiteSpace = NO;
            lastIsWhiteSpace = NO;
            if ([modifiedString length] > 0) {
                if ([modifiedString characterAtIndex:[modifiedString length] - 1] == ' ') {
                    lastIsWhiteSpace = YES;
                }
            }
            if (lastIsWhiteSpace && ([modifiedString length] == 1)) {
                isWhiteSpace = YES;
            }
            
            if (isWhiteSpace) {
                if (state->lastCharIsWhitespace) {
                    // do nothing
                }
                else if (!state->hasText) {
                    // do nothing
                }
                else {
                    [result appendString:@" "];
                    state->lastCharIsWhitespace = YES;
                    state->hasText = YES;
                }
            }
            else {
                [result appendString:modifiedString];
                state->lastCharIsWhitespace = lastIsWhiteSpace;
                state->hasText = YES;
            }
        }
        [modifiedString release];
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

static void appendQuote(struct parserState * state)
{
    if (state->quoteLevel < 0) {
        NSLog(@"error consistency in quote level");
        state->lastCharIsWhitespace = YES;
        return;
    }
    for(unsigned int i = 0 ; i < state->quoteLevel ; i ++) {
        [state->result appendString:@"> "];
    }
    state->lastCharIsWhitespace = YES;
}

static void returnToLine(struct parserState * state)
{
    if (!state->hasQuote) {
        appendQuote(state);
        state->hasQuote = YES;
    }
    
    [state->result appendString:@"\n"];
    //appendQuote(state);
    state->hasText = NO;
    state->lastCharIsWhitespace = YES;
    state->hasQuote = NO;
    state->hasReturnToLine = NO;
}

static void returnToLineAtBeginningOfBlock(struct parserState * state)
{
    if (state->hasText) {
        returnToLine(state);
    }
}

static NSSet * blockElements(void)
{
    static NSMutableSet * elements = nil;
    
    if (elements == nil) {
        elements = [[NSMutableSet alloc] init];
        [elements addObject:@"address"];
        [elements addObject:@"div"];
        [elements addObject:@"p"];
        [elements addObject:@"h1"];
        [elements addObject:@"h2"];
        [elements addObject:@"h3"];
        [elements addObject:@"h4"];
        [elements addObject:@"h5"];
        [elements addObject:@"h6"];
        [elements addObject:@"pre"];
        [elements addObject:@"ul"];
        [elements addObject:@"ol"];
        [elements addObject:@"li"];
        [elements addObject:@"dl"];
        [elements addObject:@"dt"];
        [elements addObject:@"dd"];
        [elements addObject:@"form"];
        // tables
        [elements addObject:@"col"];
        [elements addObject:@"colgroup"];
        [elements addObject:@"th"];
        [elements addObject:@"tbody"];
        [elements addObject:@"thead"];
        [elements addObject:@"tfoot"];
        [elements addObject:@"table"];
        [elements addObject:@"tr"];
        [elements addObject:@"td"];
    }
    
    return elements;
}

static void elementStarted(void * ctx, const xmlChar * name, const xmlChar ** atts)
{
	struct parserState * state;
	
	state = ctx;
	
	if (state->logEnabled) {
		LEPLog(@"parsed element %s", name);
	}
    
    if (strcasecmp((const char *) name, "blockquote") == 0) {
        state->quoteLevel ++;
    }
    
	if (state->enabled) {
		if (state->level == 1) {
			if (strcasecmp((const char *) name, "head") == 0) {
				state->enabled = 0;
				state->disabledLevel = state->level;
			}
		}
		if (strcasecmp((const char *) name, "style") == 0) {
			state->enabled = 0;
			state->disabledLevel = state->level;
		}
		else if (strcasecmp((const char *) name, "script") == 0) {
			state->enabled = 0;
			state->disabledLevel = state->level;
		}
        else if ([blockElements() containsObject:[[NSString stringWithUTF8String:(const char *) name] lowercaseString]]) {
            returnToLineAtBeginningOfBlock(state);
        }
		else if (strcasecmp((const char *) name, "blockquote") == 0) {
            if (!state->showBlockQuote) {
                state->enabled = 0;
                state->disabledLevel = state->level;
            }
            else {
                returnToLineAtBeginningOfBlock(state);
            }
		}
        else if (strcasecmp((const char *) name, "br") == 0) {
            returnToLine(state);
            state->hasReturnToLine = YES;
        }
	}
	
	state->level ++;
}

static void elementEnded(void * ctx, const xmlChar * name)
{
	struct parserState * state;
    
	state = ctx;
	
	if (state->logEnabled) {
		LEPLog(@"ended element %s", name);
	}
    
    if (strcasecmp((const char *) name, "blockquote") == 0) {
        state->quoteLevel --;
    }
    
	state->level --;
	if (!state->enabled) {
		if (state->level == state->disabledLevel) {
			state->enabled = 1;
		}
	}
    
	BOOL hasReturnToLine;
    
    hasReturnToLine = NO;
    if ([blockElements() containsObject:[[NSString stringWithUTF8String:(const char *) name] lowercaseString]]) {
        hasReturnToLine = YES;
    }
    else if (strcasecmp((const char *) name, "blockquote") == 0) {
        hasReturnToLine = YES;
    }
    
    if (hasReturnToLine) {
        if (state->enabled) {
            if (!state->hasReturnToLine) {
                returnToLine(state);
            }
        }
    }
}

static void commentParsed(void * ctx, const xmlChar * value)
{
	struct parserState * state;
	
	state = ctx;
	
	if (state->logEnabled) {
		LEPLog(@"comments %s", value);
	}
}

- (NSString*) lepFlattenHTMLAndShowBlockquote:(BOOL)showBlockquote
/*" Interpretes the receiver als HTML, removes all tags
 and returns the plain text. "*/
{
    [NSString lepInitializeLibXML];    
    
	int mem_base = xmlMemBlocks();
	NSMutableString* result = [NSMutableString string];
	xmlSAXHandler handler;
	bzero(&handler, sizeof(xmlSAXHandler));
	handler.characters = &charactersParsed;
	handler.startElement = elementStarted;
	handler.endElement = elementEnded;
	handler.comment = commentParsed;
	struct parserState state;
	state.result = result;
	state.level = 0;
	state.enabled = 1;
	state.logEnabled = 0;
	state.disabledLevel = 0;
    state.quoteLevel = 0;
    state.hasText = NO;
    state.hasQuote = NO;
    state.hasReturnToLine = NO;
    state.showBlockQuote = showBlockquote;
	
	htmlSAXParseDoc((xmlChar*)[self UTF8String], "utf-8",
					&handler, &state);
    
	if (mem_base != xmlMemBlocks()) {
		NSLog( @"Leak of %d blocks found in htmlSAXParseDoc",
			  xmlMemBlocks() - mem_base);
	}
	return result;
}

- (NSString*) lepFlattenHTML
{
    return [self lepFlattenHTMLAndShowBlockquote:YES];
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

- (NSString *) lepExtractedSubject
{
    return [self lepExtractedSubjectAndKeepBracket:NO];
}

- (NSString *) lepExtractedSubjectAndKeepBracket:(BOOL)keepBracket
{
	char * result;
	NSString * str;
	
	result = extract_subject((char *) [self UTF8String], keepBracket);
	str = [NSString stringWithUTF8String:result];
	free(result);
	
	return str;
}

+ (void) lepInitializeLibXML
{
    static BOOL initDone = NO;
    static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
    
    pthread_mutex_lock(&lock);
    if (!initDone) {
        initDone = YES;
        xmlInitParser();
        
        /* GCS: override structuredErrorFunc to mine so
         I can ignore errors */
        xmlSetStructuredErrorFunc(xmlGenericErrorContext,
                                  &structuredError);
    }
    pthread_mutex_unlock(&lock);
}


struct baseURLParserState {
    int headClosed;
    NSString * baseURL;
};

static void baseURLElementStarted(void * ctx, const xmlChar * name, const xmlChar ** atts)
{
	struct baseURLParserState * state;
	
	state = ctx;
    
    // fast path
    if (state->headClosed)
        return;
	
    if (atts == NULL)
        return;
    
    if (strcasecmp((const char *) name, "base") != 0) {
        return;
    }
    
    for(const xmlChar ** curAtt = atts ; * curAtt != NULL ; curAtt += 2) {
        const xmlChar * attrName;
        const xmlChar * attrValue;
        
        attrName = * curAtt;
        attrValue = * (curAtt + 1);
        if (strcasecmp((const char *) attrName, "href") == 0) {
            state->baseURL = [NSString stringWithUTF8String:(const char *) attrValue];
        }
    }
}

static void baseURLElementEnded(void * ctx, const xmlChar * name)
{
	struct baseURLParserState * state;
	
	state = ctx;
    
    // fast path
    if (state->headClosed)
        return;
    
    if (strcasecmp((const char *) name, "head") == 0) {
        state->headClosed = 1;
    }
}

- (NSURL *) lepBaseURLFromHTMLString:(NSString *)html
{
    // init
    [NSString lepInitializeLibXML];
    
	xmlSAXHandler handler;
	bzero(&handler, sizeof(handler));
	handler.startElement = baseURLElementStarted;
    handler.endElement = baseURLElementEnded;
    
	struct baseURLParserState state;
    bzero(&state, sizeof(state));
    
	htmlSAXParseDoc((xmlChar*)[self UTF8String], "utf-8",
					&handler, &state);
    
    if (state.baseURL == nil)
        return nil;
    
    return [NSURL URLWithString:state.baseURL];
}


@end
