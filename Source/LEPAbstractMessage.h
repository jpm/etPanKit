#import <Foundation/Foundation.h>

@interface LEPAbstractMessage : NSObject {
}

@property (nonatomic, copy, readonly) NSString * messageID;
@property (nonatomic, copy, readonly) NSArray * reference;
@property (nonatomic, copy, readonly) NSArray * inReplyTo;

@property (nonatomic, copy, readonly) NSString * from;
@property (nonatomic, copy, readonly) NSArray * to;
@property (nonatomic, copy, readonly) NSArray * cc;
@property (nonatomic, copy, readonly) NSArray * bcc;
@property (nonatomic, copy, readonly) NSString * subject;

- (id) init;
- (void) dealloc;

@end
