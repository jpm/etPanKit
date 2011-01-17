//
//  LEPSMTPRequest.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 05/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPSMTPRequest.h"

#import "LEPSMTPSession.h"
#import "LEPUtils.h"

@interface LEPSMTPRequest ()

@property (nonatomic, copy) NSError * error;

@end

@implementation LEPSMTPRequest

@synthesize delegate = _delegate;
@synthesize error = _error;
@synthesize session = _session;

- (id) init
{
	self = [super init];
	
	return self;
} 

- (void) dealloc
{
	[_error release];
	[_session release];
	[super dealloc];
}

- (void) startRequest
{
	[self retain];
	_started = YES;
	LEPLog(@"start request %@", _session);
	[_session queueOperation:self];
	LEPLog(@"start request ok");
}

- (void) cancel
{
	[super cancel];
}

- (void) main
{
	LEPLog(@"smtp request");
	if ([self isCancelled]) {
		if (_started) {
			_started = NO;
			[self release];
		}
		return;
	}
	
	[_session performSelectorOnMainThread:@selector(setError:) withObject:nil waitUntilDone:YES];
	
	[self mainRequest];
	
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
	
    if ([_session error] != nil) {
        [self setError:[_session error]];
    }
	[self mainFinished];
	if (_started) {
		_started = NO;
		[self release];
	}
	[[self delegate] LEPSMTPRequest_finished:self];
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
