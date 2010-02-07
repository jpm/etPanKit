#import "LEPIMAPRequest.h"
#import "LEPConstants.h"

@class LEPIMAPFetchFolderMessagesRequest;
@class LEPMessage;
@class LEPIMAPMessage;
@class LEPIMAPAccount;
@class LEPIMAPFolder;

@interface LEPIMAPFolder : NSObject {
    LEPIMAPAccount * _account;
	char _delimiter;
    int _flags;
    NSString * _path;
	uint32_t _uidValidity;
	uint32_t _uidNext;
}

@property (nonatomic, readonly, retain) LEPIMAPAccount * account;
@property (nonatomic, readonly) NSString * path;
#warning this should be filled in
@property (nonatomic, readonly) uint32_t uidValidity;
@property (nonatomic, readonly) uint32_t uidNext;

- (NSArray *) pathComponents;

- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequest;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequestFromUID:(uint32_t)uid;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequestFromUID:(uint32_t)uid toUID:(uint32_t)uid;

- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesUIDFlagsRequest;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesUIDFlagsRequestFromUID:(uint32_t)uid;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesUIDFlagsRequestFromUID:(uint32)fromUID toUID:(uint32_t)toUID;

- (LEPIMAPRequest *) appendMessageRequest:(LEPMessage *)message;
- (LEPIMAPRequest *) copyMessages:(NSArray * /* LEPIMAPMessage */)messages toFolder:(LEPIMAPFolder *)folder;

- (LEPIMAPRequest *) subscribeRequest;
- (LEPIMAPRequest *) unsubscribeRequest;

- (LEPIMAPRequest *) deleteRequest;
- (LEPIMAPRequest *) renameRequestWithNewPath:(NSString *)newPath;

- (LEPIMAPRequest *) expungeRequest;

@end
