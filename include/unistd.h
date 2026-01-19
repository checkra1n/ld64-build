#ifndef _UNISTD_PATCH_H_
#define _UNISTD_PATCH_H_

#include_next <unistd.h>

#include <errno.h>
#include <string.h>
#include <sys/stat.h>

static inline int mkpath_np(const char *path, mode_t mode)
{
    int old_errno = errno;
    int r = mkdir(path, mode);
    if(r != 0 && errno != EEXIST)
    {
        const char *end = strrchr(path, '/');
        if(end)
        {
            size_t n = end - path;
            char *str = strndupa(path, n);
            end = str + n;
            char *cur = str;
            while(cur[0] == '/')
            {
                ++cur;
            }
            if(cur < end)
            {
                cur = strchr(cur, '/');
                while(1)
                {
                    if(cur)
                    {
                        cur[0] = '\0';
                    }
                    r = mkdir(str, 0777);
                    if(cur)
                    {
                        cur[0] = '/';
                    }

                    if(r != 0)
                    {
                        r = errno;
                        if(r != EEXIST)
                        {
                            goto out;
                        }
                    }

                    if(!cur)
                    {
                        break;
                    }
                    cur = strchr(cur + 1, '/');
                }
            }

            r = mkdir(path, mode);
        }
    }
    if(r != 0)
    {
        r = errno;
        if(r == EEXIST)
        {
            struct stat s;
            r = stat(path, &s);
            if(r == 0)
            {
                r = (s.st_mode & S_IFMT) == S_IFDIR ? EEXIST : ENOTDIR;
            }
            else
            {
                r = errno;
            }
        }
    }
out:;
    errno = old_errno;
    return r;
}

#endif /* _UNISTD_PATCH_H_ */
