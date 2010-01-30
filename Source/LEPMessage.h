#import "LEPAbstractMessage.h"

@interface LEPMessage : LEPAbstractMessage {
	NSString * _messageID;
	NSArray * /* NSString */ _references;
	NSArray * /* NSString */ _inReplyTo;
	LEPAddress * _from;
	NSArray * /* LEPAddress */ _to;
	NSArray * /* LEPAddress */ _cc;
	NSArray * /* LEPAddress */ _bcc;
	NSArray * /* LEPAddress */ _replyTo;
	NSString * _subject;
	NSString * _body;
	NSArray * _attachments;
    NSDate * _date;
}

@property (nonatomic, copy) NSString * messageID;
@property (nonatomic, copy) NSArray * /* NSString */ references;
@property (nonatomic, copy) NSArray * /* NSString */ inReplyTo;

@property (nonatomic, retain) NSDate * date;

@property (nonatomic, copy) LEPAddress * from;
@property (nonatomic, copy) NSArray * /* LEPAddress */ to;
@property (nonatomic, copy) NSArray * /* LEPAddress */ cc;
@property (nonatomic, copy) NSArray * /* LEPAddress */ bcc;
@property (nonatomic, copy) NSArray * /* LEPAddress */ replyTo;
@property (nonatomic, copy) NSString * subject;

@property (nonatomic, copy) NSString * body;
@property (nonatomic, copy) NSArray * /* LEPAttachment */ attachments;

- (void) parseData:(NSData *)data;

- (NSData *) data;

@end

