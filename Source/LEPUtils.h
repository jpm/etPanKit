/*
 *  LEPUtils.h
 *  etPanKit
 *
 *  Created by DINH Viêt Hoà on 04/01/2010.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#define LEPLogOutputFilenameKey @"LEPLogOutputFilenameKey"
#define LEPLogDisabledFilenamesKey @"LEPLogDisabledFilenames"
// In your user defaults, you can set an array of filenames which LEPLog messages you want to disable.
// Do not include path extension (e.g. "LEPIMAPRequest" to disabled LEPIMAPRequest's LEPLog messages)

#ifdef LEPLOG_DISABLE

#define LEPLogStack(...)
#define LEPLog(...)
#define LEPLOG(...)
#define LEPASSERT(condition) NSAssert(condition, @#condition)
#define LEPAssert(condition) NSAssert(condition, @#condition)
#define		LEP_DEBUG_METHOD_BEGIN
#define		LEP_DEBUG_LOG(...)
#define LEPCRASH() NSAssert(0, @"LEPCRASH")

#define LEPPROPERTY(propName)    @#propName

#define		LEPDebugDefaultsBoolForKey( key, placeholder )		( placeholder )
#define		LEPDebugDefaultsIntegerForKey( key, placeholder )	( placeholder )
#define		LEPDebugDefaultsFloatForKey( key, placeholder )		( placeholder )
#define		LEPDebugDefaultsDoubleForKey( key, placeholder )		( placeholder )
#define		LEPDebugDefaultsObjectForKey( key, placeholder )		( placeholder )

#else

#define LEPLogStack(...) LEPLogInternal(__FILE__, __LINE__, 1, __VA_ARGS__)
#define LEPLog(...) LEPLogInternal(__FILE__, __LINE__, 0, __VA_ARGS__)
#define LEPLOG(...) LEPLogInternal(__FILE__, __LINE__, 0, __VA_ARGS__)
#define LEPASSERT(condition) NSAssert(condition, @#condition)
#define LEPAssert(condition) NSAssert(condition, @#condition)
#define		LEP_DEBUG_METHOD_BEGIN			NSLog(@"%s (%@:%d)", __PRETTY_FUNCTION__, [[NSString stringWithFormat:@"%s", __FILE__] lastPathComponent], __LINE__);
#define		LEP_DEBUG_LOG(...) LEPLogInternal(__FILE__, __LINE__, 0, __VA_ARGS__)
#define LEPCRASH() NSAssert(0, @"LEPCRASH")

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
