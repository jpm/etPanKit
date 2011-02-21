//
//  LEPIMAPRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 03/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPIMAPRequest.h"
#import "LEPIMAPSession.h"

@interface LEPIMAPRequest ()

@property (nonatomic, copy) NSError * error;
@property (nonatomic, retain) NSArray * resultUidSet;
@property (nonatomic, retain) NSString * welcomeString;

- (void) _finished;

@end

@implementation LEPIMAPRequest

@synthesize delegate = _delegate;
@synthesize error = _error;
@synthesize session = _session;
@synthesize resultUidSet = _resultUidSet;
@synthesize mailboxSelectionPath = _mailboxSelectionPath;
@synthesize welcomeString = _welcomeString;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
    [_welcomeString release];
    [_mailboxSelectionPath release];
    [_resultUidSet release];
	[_error release];
	[_session release];
	[super dealloc];
}

- (void) startRequest
{
	[self retain];
	_started = YES;
	[_session queueOperation:self];
}

- (void) cancel
{
	[super cancel];
}

- (void) main
{
	if ([self isCancelled]) {
		if (_started) {
			_started = NO;
			[self release];
		}
		return;
	}
	
	[self mainRequest];
	
    if ([_session welcomeString] != nil) {
        [self setWelcomeString:[_session welcomeString]];
    }
    if ([_session error] != nil) {
        [self setError:[_session error]];
    }
	if ([_session resultUidSet] != nil) {
		[self setResultUidSet:[_session resultUidSet]];
	}
    
	[self performSelectorOnMainThread:@selector(_finished) withObject:nil waitUntilDone:NO];
}

- (void) mainRequest
{
}

- (void) mainFinished
{
}

- (void) _finished
{
	if ([self isCancelled]) {
		if (_started) {
			_started = NO;
			[self release];
		}
		return;
	}
	
	[self mainFinished];
	[[self delegate] LEPIMAPRequest_finished:self];
    
	if (_started) {
		_started = NO;
		[self release];
	}
}

- (size_t) currentProgress
{
    return 0;
}

- (size_t) maximumProgress
{
    return 0;
}

@end
