#ifndef _OS_LOCK_PRIVATE_H_
#define _OS_LOCK_PRIVATE_H_

#ifdef __cplusplus

#include <mutex>

#define os_lock_unfair_s std::mutex
#define OS_LOCK_UNFAIR_INIT std::mutex{}

static inline void os_lock_lock(std::mutex *lock)
{
    lock->lock();
}

static inline void os_lock_unlock(std::mutex *lock)
{
    lock->unlock();
}

#endif /* __cplusplus */

#endif /* _OS_LOCK_PRIVATE_H_ */
