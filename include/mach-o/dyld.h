#ifndef _MACH_O_DYLD_H_
#define _MACH_O_DYLD_H_

#include <stdint.h>

static inline int _NSGetExecutablePath(char *buf, uint32_t *bufsize)
{
    // TODO?
    return -1;
}

#endif /* _MACH_O_DYLD_H_ */
