#import "LEPAbstractMessage.h"

@class LEPMessageHeader;
@class LEPAttachment;

@interface LEPMessage : LEPAbstractMessage {
	NSString * _body;
	NSArray * _attachments;
}

// body will be placed as first attachment
@property (nonatomic, copy) NSString * body;
// can be LEPAttachment or LEPMessageAttachment
@property (nonatomic, retain) NSArray * /* LEPAbstractAttachment */ attachments;

- (void) addAttachment:(LEPAttachment *)attachment;

- (void) parseData:(NSData *)data;
- (NSData *) data;

@end

