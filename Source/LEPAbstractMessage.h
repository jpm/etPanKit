#import <Foundation/Foundation.h>

@class LEPMessageHeader;

@interface LEPAbstractMessage : NSObject <NSCoding, NSCopying> {
	LEPMessageHeader * _header;
}

@property (nonatomic, retain, readonly) LEPMessageHeader * header;

@end
