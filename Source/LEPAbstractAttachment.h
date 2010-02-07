#import <Foundation/Foundation.h>

@class LEPAbstractMessage;

@interface LEPAbstractAttachment : NSObject {
    NSString * _filename;
    NSString * _mimeType;
	NSString * _charset;
	BOOL _inlineAttachment;
	LEPAbstractMessage * _message;
}

@property (nonatomic, copy) NSString * filename;
@property (nonatomic, copy) NSString * mimeType;
@property (nonatomic, copy) NSString * charset;
@property (nonatomic, assign, getter=isInlineAttachment) BOOL inlineAttachment;
@property (nonatomic, assign) LEPAbstractMessage * message;

@end
