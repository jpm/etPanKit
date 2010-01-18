#import "LEPIMAPRequest.h"
#import "LEPConstants.h"

@class LEPIMAPFetchFolderMessagesRequest;
@class LEPAbstractMessage;

@interface LEPIMAPFolder : NSObject {
	NSString * _uidValidity;
	char _separator;
}

@property (nonatomic, readonly) NSString * uidValidity;

- (LEPIMAPRequest *) createFolderRequest:(NSString *)name;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequest;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequestFromSequenceNumber:(uint32_t)sequenceNumber;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequestFromUID:(uint32_t)uid;
- (LEPIMAPRequest *) appendMessageRequest:(LEPAbstractMessage *)message;
- (LEPIMAPRequest *) appendMessagesRequest:(NSArray * /* LEPAbstractMessage */)message;

- (LEPIMAPRequest *) subscribeRequest;
- (LEPIMAPRequest *) unsubscribeRequest;

- (LEPIMAPRequest *) deleteRequest;
//- (LEPIMAPRequest *) renameRequest;

@end

@interface LEPIMAPFetchFolderMessagesRequest : LEPIMAPRequest {
	NSArray * _messages;
}

@property (nonatomic, readonly) NSArray * /* LEPIMAPMessage */ messages;

@end
