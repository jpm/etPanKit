#import <Foundation/Foundation.h>
#import <EtPanKit/LEPConstants.h>

@class LEPIMAPRequest;
@class LEPIMAPSession;
@class LEPIMAPFetchFoldersRequest;
@class LEPIMAPFolder;
@class LEPIMAPCapabilityRequest;
@class LEPIMAPNamespaceRequest;
@class LEPIMAPNamespace;
@class LEPIMAPCheckRequest;

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
    NSDictionary * _xListMapping;
    unsigned int _sessionsCount;
    BOOL _checkCertificate;
    char _defaultDelimiter;
    LEPIMAPNamespace * _defaultNamespace;
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
- (LEPIMAPFetchFoldersRequest *) fetchAllFoldersUsingXListRequest;

- (LEPIMAPRequest *) createFolderRequest:(NSString *)path;

- (LEPIMAPFolder *) inboxFolder;
- (LEPIMAPFolder *) folderWithPath:(NSString *)path;

- (LEPIMAPRequest *) renameRequestPath:(NSString *)path toNewPath:(NSString *)newPath;
- (LEPIMAPRequest *) deleteRequestPath:(NSString *)path;

- (LEPIMAPCapabilityRequest *) capabilityRequest;
- (LEPIMAPNamespaceRequest *) namespaceRequest;

- (LEPIMAPCheckRequest *) checkRequest;

- (void) cancel;

- (LEPIMAPNamespace *) defaultNamespace;

- (void) setupWithFoldersPaths:(NSArray *)paths;
- (void) setupNamespaceWithPrefix:(NSString *)prefix delimiter:(char)delimiter;

@end
