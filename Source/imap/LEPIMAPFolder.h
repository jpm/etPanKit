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

- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequest;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequestFromSequenceNumber:(uint32_t)sequenceNumber;
- (LEPIMAPFetchFolderMessagesRequest *) fetchMessagesRequestFromUID:(uint32_t)uid;
- (LEPIMAPRequest *) appendMessageRequest:(LEPAbstractMessage *)message;
- (LEPIMAPRequest *) appendMessagesRequest:(NSArray * /* LEPAbstractMessage */)message;

- (LEPIMAPRequest *) subscribeRequest;
- (LEPIMAPRequest *) unsubscribeRequest;

- (LEPIMAPRequest *) deleteRequest;
- (LEPIMAPRequest *) renameRequestWithNewPath:(NSString *)newPath;

@end
