#ifndef _STDLIB_PATCH_H_
#define _STDLIB_PATCH_H_

#include_next <stdlib.h>

#include <stddef.h>

static inline void* reallocf(void *ptr, size_t size)
{
    void *mem = realloc(ptr, size);
    if(!mem)
    {
        free(ptr);
    }
    return mem;
}

typedef struct
{
    void *thunk;
    int (*compar)(void *, const void *, const void *);
} _qsort_r_compat_t;

static inline int _qsort_r_compat_helper(const void *one, const void *two, void *thunk)
{
    _qsort_r_compat_t *compat = (_qsort_r_compat_t*)thunk;
    return compat->compar(compat->thunk, one, two);
}

static inline void _qsort_r_compat(void *base, size_t nel, size_t width, void *thunk, int (*compar)(void *, const void *, const void *))
{
    _qsort_r_compat_t compat = { thunk, compar };
    qsort_r(base, nel, width, &_qsort_r_compat_helper, &compat);
}

#define qsort_r(...) _qsort_r_compat(__VA_ARGS__)

#endif /* _STDLIB_PATCH_H_ */
