#import <Foundation/Foundation.h>

@interface LEPAbstractAttachment : NSObject {
}

@property (nonatomic, copy, readonly) NSString * filename;
@property (nonatomic, copy, readonly) NSString * mimeType;

- (id) init;
- (void) dealloc;

@end