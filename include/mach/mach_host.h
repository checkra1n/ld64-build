#ifndef _MACH_MACH_HOST_H_
#define _MACH_MACH_HOST_H_

#include <stdint.h>

#include <mach/kern_return.h>
//#include <mach/vm_statistics.h>

typedef uint32_t host_t;
#define mach_host_self() ((host_t)0)

typedef enum
{
    HOST_VM_INFO
} host_flavor_t;

typedef integer_t *host_info_t;

static inline kern_return_t host_statistics(host_t host_priv, host_flavor_t flavor, host_info_t host_info_out, mach_msg_type_number_t *host_info_outCnt)
{
    // TODO?
    return -1;
}

#endif /* _MACH_MACH_HOST_H_ */
