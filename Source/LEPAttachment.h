#import "LEPAbstractAttachment.h"

@interface LEPAttachment : LEPAbstractAttachment {
    NSString * _filename;
    NSString * _mimeType;
    NSData * _data;
}

@property (nonatomic, copy) NSString * filename;
@property (nonatomic, copy) NSString * mimeType;

@property (nonatomic, copy) NSData * data;

@end
