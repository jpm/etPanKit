#import "LEPAbstractMessage.h"

@interface LEPMessage : LEPAbstractMessage {
	NSString * _messageID;
	NSArray * _reference;
	NSArray * _inReplyTo;
	NSString * _from;
	NSArray * _to;
	NSArray * _cc;
	NSArray * _bcc;
	NSString * _subject;
	NSString * _body;
	NSArray * _attachments;
}

@property (nonatomic, copy) NSString * messageID;
@property (nonatomic, copy) NSArray * reference;
@property (nonatomic, copy) NSArray * inReplyTo;

@property (nonatomic, copy) NSString * from;
@property (nonatomic, copy) NSArray * to;
@property (nonatomic, copy) NSArray * cc;
@property (nonatomic, copy) NSArray * bcc;
@property (nonatomic, copy) NSString * subject;

@property (nonatomic, copy) NSString * body;
@property (nonatomic, copy) NSArray * /* LEPAttachment */ attachments;

- (void) parseData:(NSData *)data;
- (void) parseString:(NSString *)stringValue;

- (NSString *) stringValue;
- (NSData *) data;

@end

