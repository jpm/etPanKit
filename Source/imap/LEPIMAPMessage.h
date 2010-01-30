#import "LEPAbstractMessage.h"
#import "LEPIMAPRequest.h"
#import "LEPConstants.h"

@class LEPIMAPFetchMessageRequest;
@class LEPIMAPFetchMessageBodyRequest;
@class LEPIMAPFolder;

@interface LEPIMAPMessage : LEPAbstractMessage {
    LEPIMAPMessageFlag _flags;
    uint32_t _uid;
    LEPIMAPFolder * _folder;
}

@property (nonatomic, readonly) LEPIMAPMessageFlag flags;
@property (nonatomic, readonly) uint32_t uid;
@property (nonatomic, retain, readonly) LEPIMAPFolder * folder;

- (LEPIMAPFetchMessageRequest *) fetchRequest;
- (LEPIMAPFetchMessageBodyRequest *) fetchMessageBodyRequest;

@end

@interface LEPIMAPFetchMessageRequest : LEPIMAPRequest {
}

@property (nonatomic, readonly) NSArray * /* LEPIMAPAttachment */ attachements;

@end

@interface LEPIMAPFetchMessageBodyRequest : LEPIMAPRequest {
}

@property (nonatomic, readonly) NSString * body;

@end
