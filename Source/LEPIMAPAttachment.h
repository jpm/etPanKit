#import "LEPAbstractAttachment.h"
#import "LEPIMAPRequest.h"

@class LEPIMAPFetchAttachmentRequest;

@interface LEPIMAPAttachment : LEPAbstractAttachment {
    NSString * _filename;
    NSString * _mimeType;
}

- (LEPIMAPFetchAttachmentRequest *) fetch;

@end

@interface LEPIMAPFetchAttachmentRequest : LEPIMAPRequest {
}

@property (nonatomic, readonly) NSData * data;

@end
