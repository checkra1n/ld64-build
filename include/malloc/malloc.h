#ifndef _MALLOC_MALLOC_H_
#define _MALLOC_MALLOC_H_

#include <malloc.h>

static inline size_t malloc_size(const void *ptr)
{
    return malloc_usable_size((void*)ptr);
}

#endif
