#import "LEPAbstractMessage.h"
#import "LEPIMAPRequest.h"

typedef enum {
	LEPIMAPMessageFlagSeen          = 1 << 0,
	LEPIMAPMessageFlagAnswered      = 1 << 1,
	LEPIMAPMessageFlagFlagged       = 1 << 2,
	LEPIMAPMessageFlagDeleted       = 1 << 3,
	LEPIMAPMessageFlagDraft         = 1 << 4,
	LEPIMAPMessageFlagRecent        = 1 << 5,
	LEPIMAPMessageFlagMDNSent       = 1 << 6,
	LEPIMAPMessageFlagForwarded     = 1 << 7,
	LEPIMAPMessageFlagSubmitPending = 1 << 8,
	LEPIMAPMessageFlagSubmitted     = 1 << 9,
} LEPIMAPMessageFlag;

@class LEPIMAPFetchMessageRequest;
@class LEPIMAPFetchMessageBodyRequest;

@interface LEPIMAPMessage : LEPAbstractMessage {
    LEPIMAPMessageFlag _flags;
}

@property (nonatomic, readonly) LEPIMAPMessageFlag flags;

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
