/*
 *  LEPUtils.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 04/01/2010.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#define LEPLogOutputFilename @"LEPLogOutputFilename"
#define LEPLogEnabledFilenames @"LEPLogEnabledFilenames"
// In your user defaults, you can set an array of filenames which LEPLog messages you want to disable.
// Do not include path extension (e.g. "LEPIMAPRequest" to disabled LEPIMAPRequest's LEPLog messages)

#if defined(LEPLOG_DISABLE) || defined (LEPLOG_DISABLED)

#define LEPLogStack(...)
#define LEPLog(...)
#define LEPAssert(condition) NSAssert(condition, @#condition)
#define LEPCrash() NSAssert(0, @"LEPCrash")

#define LEPPROPERTY(propName)    @#propName

#define		LEPDebugDefaultsBoolForKey( key, placeholder )		( placeholder )
#define		LEPDebugDefaultsIntegerForKey( key, placeholder )	( placeholder )
#define		LEPDebugDefaultsFloatForKey( key, placeholder )		( placeholder )
#define		LEPDebugDefaultsDoubleForKey( key, placeholder )		( placeholder )
#define		LEPDebugDefaultsObjectForKey( key, placeholder )		( placeholder )

#else

#define LEPLogStack(...) LEPLogInternal(__FILE__, __LINE__, 1, __VA_ARGS__)
#define LEPLog(...) LEPLogInternal(__FILE__, __LINE__, 0, __VA_ARGS__)
#define LEPAssert(condition) NSAssert(condition, @#condition)
#define LEPCrash() NSAssert(0, @"LEPCrash")

//
// Use LEPPROPERTY for safer KVC.
// Instead of writing valueForKey(@"keyName"), 
// use valueForKey(LEPPROPERTY(keyName)).
// To be used with -Wundeclared-selector.
#define LEPPROPERTY(propName)    NSStringFromSelector(@selector(propName))

#endif

__BEGIN_DECLS
void LEPLogInternal(const char * filename, unsigned int line, int dumpStack, NSString * format, ...);
__END_DECLS
