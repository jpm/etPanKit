#import <EtPanKit/LEPAbstractMessage.h>

@class LEPMessageHeader;
@class LEPAbstractAttachment;

@interface LEPMessage : LEPAbstractMessage <NSCoding, NSCopying> {
	NSString * _body;
	NSString * _HTMLBody;
	NSArray * _attachments;
    // not serialized
    NSString * _boundaryPrefix;
}

- (id) initWithData:(NSData *)data;

// body will be placed as first attachment
@property (nonatomic, copy) NSString * body;
// HTMLBody will be placed as first attachment with text alternative if no body is set
@property (nonatomic, copy) NSString * HTMLBody;
// can be LEPAttachment or LEPMessageAttachment
@property (nonatomic, retain) NSArray * /* LEPAbstractAttachment */ attachments;
@property (nonatomic, copy) NSString * boundaryPrefix;

- (void) addAttachment:(LEPAbstractAttachment *)attachment;

- (void) parseData:(NSData *)data;
- (NSData *) data;
- (NSData *) dataForSending:(BOOL)filter;

@end

