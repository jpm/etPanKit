#import "LEPAbstractMessage.h"

@class LEPMessageHeader;
@class LEPAttachment;

@interface LEPMessage : LEPAbstractMessage {
	NSString * _body;
	NSString * _HTMLBody;
	NSArray * _attachments;
}

- (id) initWithData:(NSData *)data;

// body will be placed as first attachment
@property (nonatomic, copy) NSString * body;
// HTMLBody will be placed as first attachment with text alternative if no body is set
@property (nonatomic, copy) NSString * HTMLBody;
// can be LEPAttachment or LEPMessageAttachment
@property (nonatomic, retain) NSArray * /* LEPAbstractAttachment */ attachments;

- (void) addAttachment:(LEPAttachment *)attachment;

- (void) parseData:(NSData *)data;
- (NSData *) data;

@end

