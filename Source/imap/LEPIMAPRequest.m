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

- (void) _finished;

@end

@implementation LEPIMAPRequest

@synthesize delegate = _delegate;
@synthesize error = _error;
@synthesize session = _session;
@synthesize resultUidSet = _resultUidSet;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
    [_resultUidSet release];
	[_error release];
	[_session release];
	[super dealloc];
}

- (void) startRequest
{
	[_session queueOperation:self];
}

- (void) cancel
{
	[super cancel];
}

- (void) main
{
	if ([self isCancelled]) {
		return;
	}
	
	[self mainRequest];
	
	[self performSelectorOnMainThread:@selector(_finished) withObject:nil waitUntilDone:YES];
}

- (void) mainRequest
{
}

- (void) mainFinished
{
    if ([_session error] != nil) {
        [self setError:[_session error]];
    }
}

- (void) _finished
{
	if ([self isCancelled]) {
		return;
	}
	
	[self mainFinished];
	[[self delegate] LEPIMAPRequest_finished:self];
}

@end
