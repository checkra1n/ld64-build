#ifndef _MACH_VM_PROT_H_
#define _MACH_VM_PROT_H_

#include <stdint.h>

typedef uint32_t vm_prot_t;

#define VM_PROT_READ    ((vm_prot_t)0x1)
#define VM_PROT_WRITE   ((vm_prot_t)0x2)
#define VM_PROT_EXECUTE ((vm_prot_t)0x4)

#endif /* _MACH_VM_PROT_H_ */
