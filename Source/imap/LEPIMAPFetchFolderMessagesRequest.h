//
//  LEPIMAPFetchFolderMessagesRequest.h
//  etPanKit
//
//  Created by DINH Viêt Hoà on 20/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EtPanKit/LEPIMAPRequest.h>
#import <EtPanKit/LEPConstants.h>

@class LEPIMAPFolder;

@interface LEPIMAPFetchFolderMessagesRequest : LEPIMAPRequest {
	NSArray * _messages;
    uint32_t _fromUID;
    uint32_t _toUID;
    NSString * _path;
    LEPIMAPMessagesRequestKind _fetchKind;
	LEPIMAPFolder * _folder;
    unsigned int _progressCount;
    LEPIMAPWorkaround _workaround;
}

@property (nonatomic, copy) NSString * path;
@property (nonatomic) uint32_t fromUID;
@property (nonatomic) uint32_t toUID;
@property (nonatomic) LEPIMAPMessagesRequestKind fetchKind;
@property (nonatomic, retain) LEPIMAPFolder * folder;
@property (nonatomic, assign) LEPIMAPWorkaround workaround;

@property (nonatomic, retain, readonly) NSArray * /* LEPIMAPMessage */ messages;

// progress
@property (nonatomic, assign, readonly) unsigned int progressCount;

@end
