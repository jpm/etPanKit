#import "LEPAbstractMessage.h"

@interface LEPMessage : LEPAbstractMessage {
}

@property (nonatomic, readonly) NSString * stringValue;
@property (nonatomic, readonly) NSData * data;

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

@end

