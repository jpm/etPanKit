#import "LEPIMAPRequest.h"
#import "LEPConstants.h"

@class LEPIMAPFetchFolderMessagesRequest;
@class LEPMessage;
@class LEPIMAPMessage;
@class LEPIMAPAccount;
@class LEPIMAPFolder;

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

- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequest;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequestFromUID:(uint32_t)uid;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesUIDFlagsRequest;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesUIDFlagsRequestToUID:(uint32_t)uid;

- (LEPIMAPRequest *) appendMessageRequest:(LEPMessage *)message;
- (LEPIMAPRequest *) copyMessages:(NSArray * /* LEPIMAPMessage */)messages toFolder:(LEPIMAPFolder *)folder;

- (LEPIMAPRequest *) subscribeRequest;
- (LEPIMAPRequest *) unsubscribeRequest;

- (LEPIMAPRequest *) deleteRequest;
- (LEPIMAPRequest *) renameRequestWithNewPath:(NSString *)newPath;

- (LEPIMAPRequest *) expungeRequest;

@end
