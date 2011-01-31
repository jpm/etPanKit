#ifndef LEPSINGLETON_H

#define LEPSINGLETON_H

#define LEPSINGLETON(className) \
{ \
static className * singleton = nil; \
@synchronized (self) { \
if (singleton == nil) { \
singleton = [[className alloc] init]; \
} \
} \
return singleton; \
}

#endif
