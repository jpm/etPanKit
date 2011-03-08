#import <EtPanKit/LEPAbstractMessage.h>
#import <EtPanKit/LEPIMAPRequest.h>
#import <EtPanKit/LEPConstants.h>

@class LEPIMAPFetchMessageRequest;
@class LEPIMAPFetchMessageStructureRequest;
@class LEPIMAPFetchAttachmentRequest;
@class LEPIMAPFolder;

@interface LEPIMAPMessage : LEPAbstractMessage <NSCoding, NSCopying> {
    LEPIMAPMessageFlag _flags;
    LEPIMAPMessageFlag _originalFlags;
    uint32_t _uid;
    LEPIMAPFolder * _folder;
	NSArray * _attachments;
}

@property (nonatomic, assign) LEPIMAPMessageFlag originalFlags;
@property (nonatomic, assign) LEPIMAPMessageFlag flags;
@property (nonatomic, readonly) uint32_t uid;
@property (nonatomic, retain) LEPIMAPFolder * folder;
// in case LEPIMAPMessagesRequestKindStructure has been requested
@property (nonatomic, retain, readonly) NSArray * attachments;

- (LEPIMAPFetchMessageStructureRequest *) fetchMessageStructureRequest;
- (LEPIMAPFetchMessageRequest *) fetchMessageRequest;
- (LEPIMAPFetchAttachmentRequest *) fetchAttachmentRequestWithPartID:(NSString *)partID;

@end
