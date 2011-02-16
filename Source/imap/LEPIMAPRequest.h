#import <Foundation/Foundation.h>

@protocol LEPIMAPRequestDelegate;
@class LEPIMAPSession;

@interface LEPIMAPRequest : NSOperation {
	id <LEPIMAPRequestDelegate> _delegate;
	LEPIMAPSession * _session;
	NSError * _error;
    NSMutableArray * _resultUidSet;
	BOOL _started;
    NSString * _mailboxSelectionPath;
    NSString * _welcomeString;
}

@property (nonatomic, assign) id <LEPIMAPRequestDelegate> delegate;
@property (nonatomic, copy) NSString * mailboxSelectionPath;

// response
@property (nonatomic, readonly, copy) NSError * error;
@property (nonatomic, retain) LEPIMAPSession * session;
@property (nonatomic, readonly, retain) NSArray * resultUidSet;
@property (nonatomic, readonly, retain) NSString * welcomeString;

// progress
@property (nonatomic, assign, readonly) size_t currentProgress;
@property (nonatomic, assign, readonly) size_t maximumProgress;

- (void) startRequest;
- (void) cancel;

// can be overridden
- (void) mainRequest;
- (void) mainFinished;

@end

@protocol LEPIMAPRequestDelegate

- (void) LEPIMAPRequest_finished:(LEPIMAPRequest *)op;

@end
