#import <Foundation/Foundation.h>

@interface LEPAbstractAttachment : NSObject {
    NSString * _filename;
    NSString * _mimeType;
	BOOL _inlineAttachment;
}

@property (nonatomic, copy) NSString * filename;
@property (nonatomic, copy) NSString * mimeType;
@property (nonatomic, assign, getter=isInlineAttachment) BOOL inlineAttachment;

@end
