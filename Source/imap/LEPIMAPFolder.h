#import <EtPanKit/LEPIMAPRequest.h>
#import <EtPanKit/LEPConstants.h>

@class LEPIMAPFetchFolderMessagesRequest;
@class LEPMessage;
@class LEPIMAPMessage;
@class LEPIMAPAccount;
@class LEPIMAPFolder;
@class LEPIMAPIdleRequest;
@class LEPIMAPCapabilityRequest;

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
@property (nonatomic, readonly) uint32_t uidValidity;
@property (nonatomic, readonly) uint32_t uidNext;
@property (nonatomic, assign, readonly) int flags;

- (NSString *) displayName;
- (NSArray *) pathComponents;

+ (NSString *) encodePathName:(NSString *)path;
+ (NSString *) decodePathName:(NSString *)path;

- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequest;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequestFromUID:(uint32_t)uid;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequestFromUID:(uint32_t)fromUID toUID:(uint32_t)toUID;

- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesUIDRequest;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesUIDRequestFromUID:(uint32_t)uid;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesUIDRequestFromUID:(uint32_t)fromUID toUID:(uint32_t)toUID;

- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesUIDFlagsRequest;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesUIDFlagsRequestFromUID:(uint32_t)uid;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesUIDFlagsRequestFromUID:(uint32_t)fromUID toUID:(uint32_t)toUID;

- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesWithStructureRequest;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesWithStructureRequestFromUID:(uint32_t)uid;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesWithStructureRequestFromUID:(uint32_t)fromUID toUID:(uint32_t)toUID;

- (LEPIMAPRequest *) appendMessageRequest:(LEPMessage *)message;
- (LEPIMAPRequest *) appendMessageRequest:(LEPMessage *)message flags:(LEPIMAPMessageFlag)flags;
- (LEPIMAPRequest *) copyMessages:(NSArray * /* LEPIMAPMessage */)messages toFolder:(LEPIMAPFolder *)folder;
- (LEPIMAPRequest *) copyMessagesUIDs:(NSArray * /* NSNumber uint32_t */)messagesUids toFolder:(LEPIMAPFolder *)folder;

- (LEPIMAPRequest *) subscribeRequest;
- (LEPIMAPRequest *) unsubscribeRequest;

- (LEPIMAPRequest *) deleteRequest;
- (LEPIMAPRequest *) renameRequestWithNewPath:(NSString *)newPath;

- (LEPIMAPRequest *) expungeRequest;

// update uidValidity and uidNext
- (LEPIMAPRequest *) selectRequest;

- (LEPIMAPRequest *) addFlagsToMessagesRequest:(NSArray * /* LEPIMAPMessage */)messages flags:(LEPIMAPMessageFlag)flags;
- (LEPIMAPRequest *) removeFlagsToMessagesRequest:(NSArray * /* LEPIMAPMessage */)messages flags:(LEPIMAPMessageFlag)flags;
- (LEPIMAPRequest *) setFlagsToMessagesRequest:(NSArray * /* LEPIMAPMessage */)messages flags:(LEPIMAPMessageFlag)flags;

- (LEPIMAPIdleRequest *) idleRequest;
- (LEPIMAPCapabilityRequest *) capabilityRequest;

@end
