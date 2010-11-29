#import <Foundation/Foundation.h>
#import <EtPanKit/LEPConstants.h>

@class LEPIMAPRequest;
@class LEPIMAPSession;
@class LEPIMAPFetchFoldersRequest;
@class LEPIMAPFolder;

@interface LEPIMAPAccount : NSObject {
    NSString * _host;
    uint16_t _port;
    NSString * _login;
    NSString * _password;
    LEPAuthType _authType;
	NSString * _realm;
    BOOL _idleEnabled;
	//LEPIMAPSession * _session;
    NSMutableArray * _sessions;
    NSDictionary * _gmailMailboxNames;
    unsigned int _sessionsCount;
    BOOL _checkCertificate;
}

@property (nonatomic, copy) NSString * host;
@property (nonatomic) uint16_t port;
@property (nonatomic, copy) NSString * login;
@property (nonatomic, copy) NSString * password;
@property (nonatomic) LEPAuthType authType;
@property (nonatomic, copy) NSString * realm; // for NTLM
@property (nonatomic) unsigned int sessionsCount;
@property (nonatomic, assign) BOOL checkCertificate;

@property (nonatomic, getter=isIdleEnabled) BOOL idleEnabled;

+ (void) setTimeoutDelay:(NSTimeInterval)timeout;
+ (NSTimeInterval) timeoutDelay;

// after the operation is created, it should be started
- (LEPIMAPFetchFoldersRequest *) fetchSubscribedFoldersRequest;

// after the operation is created, it should be started
- (LEPIMAPFetchFoldersRequest *) fetchAllFoldersRequest;

- (LEPIMAPRequest *) createFolderRequest:(NSString *)path;

- (LEPIMAPFolder *) inboxFolder;
- (LEPIMAPFolder *) folderWithPath:(NSString *)path;

- (void) setupWithFoldersPaths:(NSArray *)paths;

@end
