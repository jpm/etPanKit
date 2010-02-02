#import <Foundation/Foundation.h>

@protocol LEPIMAPRequestDelegate;
@class LEPIMAPSession;

@interface LEPIMAPRequest : NSOperation {
	id <LEPIMAPRequestDelegate> _delegate;
	LEPIMAPSession * _session;
	NSError * _error;
    NSMutableArray * _resultUidSet;
	BOOL _started;
}

@property (assign) id <LEPIMAPRequestDelegate> delegate;

// response
@property (nonatomic, readonly, copy) NSError * error;
@property (nonatomic, retain) LEPIMAPSession * session;
@property (nonatomic, readonly, retain) NSArray * resultUidSet;

- (void) startRequest;
- (void) cancel;

// can be overridden
- (void) mainRequest;
- (void) mainFinished;

@end

@protocol LEPIMAPRequestDelegate

- (void) LEPIMAPRequest_finished:(LEPIMAPRequest *)op;

@end
