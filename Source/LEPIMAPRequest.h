#import <Foundation/Foundation.h>

@protocol LEPIMAPRequestDelegate;

@interface LEPIMAPRequest : NSObject {
}

@property (assign) id <LEPIMAPRequestDelegate> delegate;

@property (nonatomic, readonly, copy) NSError * error;

- (void) start;
- (void) cancel;

@end

@protocol LEPIMAPRequestDelegate

- (void) LEPIMAPRequest_finished:(LEPIMAPRequest *)op;

@end

// internal

@interface LEPIMAPRequestQueue : NSObject {
}

@end
