#ifndef _LIBKERN_OSATOMIC_H_
#define _LIBKERN_OSATOMIC_H_

// NOTE: Must not include <stdatomic.h> here. Doing so conflicts heavily
//       with stdlibc++'s <atomic>, which may be included later.
#include <stdint.h>

static inline int32_t OSAtomicAdd32(int32_t amount, volatile int32_t *value)
{
    return __c11_atomic_fetch_add((_Atomic(int32_t)*)value, amount, __ATOMIC_SEQ_CST);
}

static inline int64_t OSAtomicAdd64(int64_t amount, volatile int64_t *value)
{
    return __c11_atomic_fetch_add((_Atomic(int64_t)*)value, amount, __ATOMIC_SEQ_CST);
}

#define OSAtomicIncrement32(value) OSAtomicAdd32(1, value)

#endif /* _LIBKERN_OSATOMIC_H_ */
