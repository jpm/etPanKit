#import "LEPAbstractAttachment.h"

@class LEPIMAPFetchAttachmentRequest;

@interface LEPIMAPAttachment : LEPAbstractAttachment <NSCoding> {
	NSString * _partID;
	int _encoding;
	size_t _size;
}

@property (nonatomic, retain, readonly) NSString * partID;

- (LEPIMAPFetchAttachmentRequest *) fetchRequest;

@end
