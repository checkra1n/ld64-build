#ifndef _SYS_SYSCTL_H_
#define _SYS_SYSCTL_H_

#include <sys/sysinfo.h>

enum
{
    CTL_HW,
    CTL_KERN,
};

enum
{
    HW_NCPU,
};

enum
{
    KERN_OSRELEASE,
};

static inline int sysctl(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen)
{
    if(newp)
        return -1;

    if(!oldp || !oldlenp)
        return -1;

    if(namelen == 2 && name[0] == CTL_HW && name[1] == HW_NCPU)
    {
        if(*oldlenp < sizeof(unsigned int))
            return -1;

        *(unsigned int*)oldp = get_nprocs();
        *oldlenp = sizeof(unsigned int);

        return 0;
    }

    return -1;
}

#endif /* _SYS_SYSCTL_H_ */
