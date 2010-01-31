#import <Foundation/Foundation.h>
#import "LEPConstants.h"

@class LEPIMAPRequest;
@class LEPIMAPSession;

@interface LEPIMAPAccount : NSObject {
    NSString * _host;
    uint16_t _port;
    NSString * _login;
    NSString * _password;
    LEPAuthType _authType;
	NSString * _realm;
    BOOL _idleEnabled;
	LEPIMAPSession * _session;
}

@property (nonatomic, copy) NSString * host;
@property (nonatomic) uint16_t port;
@property (nonatomic, copy) NSString * login;
@property (nonatomic, copy) NSString * password;
@property (nonatomic) LEPAuthType authType;
@property (nonatomic, copy) NSString * realm; // for NTLM

@property (nonatomic, getter=isIdleEnabled) BOOL idleEnabled;

// after the operation is created, it should be started
- (LEPIMAPRequest *) fetchSubscribedFoldersRequest;

// after the operation is created, it should be started
- (LEPIMAPRequest *) fetchAllFoldersRequest;

- (LEPIMAPRequest *) createFolderRequest:(NSString *)path;

@end
