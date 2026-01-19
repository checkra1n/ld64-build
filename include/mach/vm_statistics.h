#ifndef _MACH_VM_STATISTICS_H_
#define _MACH_VM_STATISTICS_H_

#include <mach/machine/vm_types.h>

typedef struct vm_statistics
{
    natural_t pageins;
    natural_t pageouts;
    natural_t faults;
    natural_t active_count;
    natural_t wire_count;
} vm_statistics_data_t, *vm_statistics_t;

#endif /* _MACH_VM_STATISTICS_H_ */
