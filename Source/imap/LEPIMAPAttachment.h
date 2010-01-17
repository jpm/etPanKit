#import "LEPAbstractAttachment.h"
#import "LEPIMAPRequest.h"

@class LEPIMAPFetchAttachmentRequest;

@interface LEPIMAPAttachment : LEPAbstractAttachment {
    NSString * _filename;
    NSString * _mimeType;
}

- (LEPIMAPFetchAttachmentRequest *) fetchRequest;

@end

@interface LEPIMAPFetchAttachmentRequest : LEPIMAPRequest {
	NSData * _data;
}

@property (nonatomic, readonly) NSData * data;

@end
