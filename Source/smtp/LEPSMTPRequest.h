#import <Foundation/Foundation.h>

@protocol LEPSMTPRequestDelegate;

@interface LEPSMTPRequest : NSObject {
	id <LEPSMTPRequestDelegate> _delegate;
	NSError * _error;
}

@property (assign) id <LEPSMTPRequestDelegate> delegate;

@property (nonatomic, readonly, copy) NSError * error;

- (void) startRequest;
- (void) cancel;

@end

@protocol LEPSMTPRequestDelegate

- (void) LEPSMTPRequest_finished:(LEPSMTPRequest *)op;

@end
