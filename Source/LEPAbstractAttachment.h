#import <Foundation/Foundation.h>

@class LEPAbstractMessage;

@interface LEPAbstractAttachment : NSObject <NSCoding, NSCopying> {
    NSString * _filename;
    NSString * _mimeType;
	NSString * _charset;
    NSString * _contentID;
    NSString * _contentLocation;
	BOOL _inlineAttachment;
	LEPAbstractMessage * _message;
}

@property (nonatomic, copy) NSString * filename;
@property (nonatomic, copy) NSString * mimeType;
@property (nonatomic, copy) NSString * charset;
@property (nonatomic, copy) NSString * contentID;
@property (nonatomic, copy) NSString * contentLocation;
@property (nonatomic, assign, getter=isInlineAttachment) BOOL inlineAttachment;
@property (nonatomic, assign) LEPAbstractMessage * message;

@end
