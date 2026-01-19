#ifndef _DISPATCH_DISPATCH_H_
#define _DISPATCH_DISPATCH_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>

typedef _Atomic unsigned int dispatch_once_t;

static inline void dispatch_once(dispatch_once_t *predicate, void (^block)(void))
{
    unsigned int init = 0;
    if(__c11_atomic_compare_exchange_strong(predicate, &init, 1, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST))
    {
        block();
    }
}

typedef void* dispatch_object_t;

static inline void dispatch_release(dispatch_object_t object)
{
    (void)object;
}

typedef void* dispatch_queue_t;
typedef void* dispatch_queue_global_t;
typedef void* dispatch_queue_attr_t;
#define DISPATCH_QUEUE_SERIAL ((dispatch_queue_t)NULL)
#define DISPATCH_APPLY_AUTO   ((dispatch_queue_t)NULL)

static inline dispatch_queue_t dispatch_queue_create(const char *label, dispatch_queue_attr_t attr)
{
    return NULL;
}

static inline dispatch_queue_global_t dispatch_get_global_queue(long priority, unsigned long flags)
{
    return NULL;
}

static inline void dispatch_sync(dispatch_queue_t queue, void (^block)(void))
{
    block();
}

static inline void dispatch_apply(size_t iterations, dispatch_queue_t queue, void (^block)(size_t))
{
    // TODO: multithreading?
    for(size_t i = 0; i < iterations; ++i)
    {
        block(i);
    }
}

typedef void* dispatch_group_t;
#define DISPATCH_TIME_FOREVER (~0ULL)

enum
{
    QOS_CLASS_USER_INITIATED,
};

static inline dispatch_group_t dispatch_group_create(void)
{
    return NULL;
}

static inline void dispatch_group_async(dispatch_group_t group, dispatch_queue_t queue, void (^block)(void))
{
    // TODO: multithreading?
    block();
}

static inline long dispatch_group_wait(dispatch_group_t group, unsigned long long timeout)
{
    // TODO: multithreading?
    return 0;
}

#ifdef __cplusplus
}
#endif

#endif /* _DISPATCH_DISPATCH_H_ */
