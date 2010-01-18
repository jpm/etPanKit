#import "LEPIMAPRequest.h"
#import "LEPConstants.h"

@class LEPIMAPFetchFolderMessagesRequest;
@class LEPAbstractMessage;
@class LEPIMAPAccount;

@interface LEPIMAPFolder : NSObject {
    LEPIMAPAccount * _account;
	NSString * _uidValidity;
	char _delimiter;
    int _flags;
    NSString * _path;
}

@property (nonatomic, assign) LEPIMAPAccount * account;
@property (nonatomic, readonly) NSString * uidValidity;
@property (nonatomic, readonly) NSString * path;

- (NSArray *) pathComponents;

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
