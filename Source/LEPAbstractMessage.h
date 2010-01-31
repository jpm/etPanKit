#import <Foundation/Foundation.h>

@class LEPMessageHeader;

@interface LEPAbstractMessage : NSObject {
	LEPMessageHeader * _header;
}

@property (nonatomic, retain, readonly) LEPMessageHeader * header;

@end
