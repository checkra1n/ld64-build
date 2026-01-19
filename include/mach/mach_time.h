#ifndef _MACH_MACH_TIME_H_
#define _MACH_MACH_TIME_H_

#include <stdint.h>
#include <time.h>

#include "kern_return.h"

typedef struct mach_timebase_info
{
    uint32_t numer;
    uint32_t denom;
} *mach_timebase_info_t;

static inline kern_return_t mach_timebase_info(mach_timebase_info_t info)
{
    info->numer = 1;
    info->denom = 1;
    return KERN_SUCCESS;
}

static inline uint64_t mach_absolute_time(void)
{
    struct timespec t;
    int r = clock_gettime(CLOCK_MONOTONIC_RAW, &t);
    return r == 0 ? (uint64_t)t.tv_sec * 1000000000L + (uint64_t)t.tv_nsec : 0;
}

#endif /* _MACH_MACH_TIME_H_ */
