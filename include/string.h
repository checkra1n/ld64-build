#ifndef _STRING_PATCH_H_
#define _STRING_PATCH_H_

#include_next <string.h>

static inline size_t strlcpy(char *dst, const char *src, size_t dstsize)
{
    size_t len = strlen(src);
    if(dstsize > 0)
    {
        --dstsize;
        size_t max = len > dstsize ? dstsize : len;
        memcpy(dst, src, max);
        dst[max] = '\0';
    }
    return len;
}

static inline size_t strlcat(char *dst, const char *src, size_t dstsize)
{
    size_t len = strlen(src);
    if(dstsize > 0)
    {
        --dstsize;
        size_t off = strlen(dst);
        size_t max = dstsize - off;
        max = len > max ? max : len;
        memcpy(dst + off, src, max);
        len += off;
        dst[off+max] = '\0';
    }
    return len;
}

#endif /* _STRING_PATCH_H_ */
