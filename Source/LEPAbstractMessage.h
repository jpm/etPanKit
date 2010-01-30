#import <Foundation/Foundation.h>

@class LEPAddress;

@interface LEPAbstractMessage : NSObject {
}

@property (nonatomic, retain, readonly) NSDate * date;

@property (nonatomic, copy, readonly) NSString * messageID;
@property (nonatomic, copy, readonly) NSArray * /* NSString */ references;
@property (nonatomic, copy, readonly) NSArray * /* NSString */ inReplyTo;

@property (nonatomic, copy, readonly) LEPAddress * from;
@property (nonatomic, copy, readonly) NSArray * /* LEPAddress */ to;
@property (nonatomic, copy, readonly) NSArray * /* LEPAddress */ cc;
@property (nonatomic, copy, readonly) NSArray * /* LEPAddress */ bcc;
@property (nonatomic, copy, readonly) NSArray * /* LEPAddress */ replyTo;
@property (nonatomic, copy, readonly) NSString * subject;

- (id) init;
- (void) dealloc;

@end
