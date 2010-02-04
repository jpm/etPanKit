#import "LEPAbstractAttachment.h"

@class LEPIMAPFetchAttachmentRequest;

@interface LEPIMAPAttachment : LEPAbstractAttachment {
	NSString * _partID;
	int _encoding;
	size_t _size;
}

#warning should implement size, encoding and partID
- (LEPIMAPFetchAttachmentRequest *) fetchRequest;

@end
