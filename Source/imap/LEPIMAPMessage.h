#import "LEPAbstractMessage.h"
#import "LEPIMAPRequest.h"
#import "LEPConstants.h"

@class LEPIMAPFetchMessageRequest;
@class LEPIMAPFetchMessageStructureRequest;
@class LEPIMAPFolder;

@interface LEPIMAPMessage : LEPAbstractMessage <NSCoding> {
    LEPIMAPMessageFlag _flags;
    uint32_t _uid;
    LEPIMAPFolder * _folder;
	NSArray * _attachments;
}

@property (nonatomic, readonly) LEPIMAPMessageFlag flags;
@property (nonatomic, readonly) uint32_t uid;
@property (nonatomic, retain, readonly) LEPIMAPFolder * folder;
// in case LEPIMAPMessagesRequestKindStructure has been requested
@property (nonatomic, retain, readonly) NSArray * attachments;

- (LEPIMAPFetchMessageStructureRequest *) fetchMessageStructureRequest;
- (LEPIMAPFetchMessageRequest *) fetchMessageRequest;

@end
