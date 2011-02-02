//
//  LEPUtils.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 04/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPUtils.h"

#import <Foundation/Foundation.h>
#import <libgen.h>
#import <time.h>
#import <sys/time.h>
#include <execinfo.h>
#include <pthread.h>

static NSSet * enabledFilesSet = nil;
static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;

void LEPLogInternal(const char * filename, unsigned int line, int dumpStack, NSString * format, ...)
{
	va_list argp;
	NSString * str;
	NSAutoreleasePool * pool;
	char * filenameCopy;
	char * lastPathComponent;
	struct timeval tv;
	struct tm tm_value;
	//NSDictionary * enabledFilenames;
    
	pool = [[NSAutoreleasePool alloc] init];
	
    pthread_mutex_lock(&lock);
    if (enabledFilesSet == nil) {
        enabledFilesSet = [[NSSet alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:LEPLogEnabledFilenames]];
    }
    pthread_mutex_unlock(&lock);
    
    NSString * fn;
    fn = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:filename length:strlen(filename)];
    fn = [fn lastPathComponent];
    if (![enabledFilesSet containsObject:fn]) {
        [pool release];
        return;
    }
    
	va_start(argp, format);
	str = [[NSString alloc] initWithFormat:format arguments:argp];
	va_end(argp);
	
	NSString * outputFileName = [[NSUserDefaults standardUserDefaults] stringForKey:LEPLogOutputFilename];
	static FILE * outputfileStream = NULL;
	if ( ( NULL == outputfileStream ) && outputFileName )
	{
		outputfileStream = fopen( [outputFileName UTF8String], "w+" );
	}
    
	if ( NULL == outputfileStream )
		outputfileStream = stderr;
	
	gettimeofday(&tv, NULL);
	localtime_r(&tv.tv_sec, &tm_value);
	fprintf(outputfileStream, "%04u-%02u-%02u %02u:%02u:%02u.%03u ", tm_value.tm_year + 1900, tm_value.tm_mon + 1, tm_value.tm_mday, tm_value.tm_hour, tm_value.tm_min, tm_value.tm_sec, tv.tv_usec / 1000);
	//fprintf(stderr, "%10s ", [[[NSDate date] description] UTF8String]);
	fprintf(outputfileStream, "[%s:%u] ", [[[NSProcessInfo processInfo] processName] UTF8String], [[NSProcessInfo processInfo] processIdentifier]);
	filenameCopy = strdup(filename);
	lastPathComponent = basename(filenameCopy);
	fprintf(outputfileStream, "(%s:%u) ", lastPathComponent, line);
	free(filenameCopy);
	fprintf(outputfileStream, "%s\n", [str UTF8String]);
	[str release];
	
    if (dumpStack) {
        void * frame[128];
        int frameCount;
        int i;
        
        frameCount = backtrace(frame, 128);
        for(i = 0 ; i < frameCount ; i ++) {
            fprintf(outputfileStream, "  %p\n", frame[i]);
        }
    }
	
	if ( outputFileName )
	{
		fflush(outputfileStream);
	}
    
	[pool release];
}
