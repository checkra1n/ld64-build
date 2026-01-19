#ifndef _LIBKERN_OSBYTEORDER_H_
#define _LIBKERN_OSBYTEORDER_H_

#include <stdint.h>

static inline uint16_t OSSwapInt16(uint16_t data)
{
    return __builtin_bswap16(data);
}

static inline uint32_t OSSwapInt32(uint32_t data)
{
    return __builtin_bswap32(data);
}

static inline uint64_t OSSwapInt64(uint64_t data)
{
    return __builtin_bswap64(data);
}

static inline uint16_t _OSReadInt16(const volatile void *base, uintptr_t byteOffset)
{
    return *(const volatile uint16_t*)((uintptr_t)base + byteOffset);
}

static inline uint32_t _OSReadInt32(const volatile void *base, uintptr_t byteOffset)
{
    return *(const volatile uint32_t*)((uintptr_t)base + byteOffset);
}

static inline uint64_t _OSReadInt64(const volatile void *base, uintptr_t byteOffset)
{
    return *(const volatile uint64_t*)((uintptr_t)base + byteOffset);
}

static inline void _OSWriteInt16(volatile void *base, uintptr_t byteOffset, uint16_t data)
{
    *(volatile uint16_t*)((uintptr_t)base + byteOffset) = data;
}

static inline void _OSWriteInt32(volatile void *base, uintptr_t byteOffset, uint32_t data)
{
    *(volatile uint32_t*)((uintptr_t)base + byteOffset) = data;
}

static inline void _OSWriteInt64(volatile void *base, uintptr_t byteOffset, uint64_t data)
{
    *(volatile uint64_t*)((uintptr_t)base + byteOffset) = data;
}

#if defined(__LITTLE_ENDIAN__)

#   define OSReadLittleInt16(base, byteOffset) _OSReadInt16(base, byteOffset)
#   define OSReadLittleInt32(base, byteOffset) _OSReadInt32(base, byteOffset)
#   define OSReadLittleInt64(base, byteOffset) _OSReadInt64(base, byteOffset)

#   define OSWriteLittleInt16(base, byteOffset, data) _OSWriteInt16(base, byteOffset, data)
#   define OSWriteLittleInt32(base, byteOffset, data) _OSWriteInt32(base, byteOffset, data)
#   define OSWriteLittleInt64(base, byteOffset, data) _OSWriteInt64(base, byteOffset, data)

#   define OSReadBigInt16(base, byteOffset) OSSwapInt16(_OSReadInt16(base, byteOffset))
#   define OSReadBigInt32(base, byteOffset) OSSwapInt32(_OSReadInt32(base, byteOffset))
#   define OSReadBigInt64(base, byteOffset) OSSwapInt64(_OSReadInt64(base, byteOffset))

#   define OSWriteBigInt16(base, byteOffset, data) _OSWriteInt16(base, byteOffset, OSSwapInt16(data))
#   define OSWriteBigInt32(base, byteOffset, data) _OSWriteInt32(base, byteOffset, OSSwapInt32(data))
#   define OSWriteBigInt64(base, byteOffset, data) _OSWriteInt64(base, byteOffset, OSSwapInt64(data))

#   define OSSwapBigToHostInt16(x) OSSwapInt16(x)
#   define OSSwapBigToHostInt32(x) OSSwapInt32(x)
#   define OSSwapBigToHostInt64(x) OSSwapInt64(x)

#   define OSSwapHostToBigInt16(x) OSSwapInt16(x)
#   define OSSwapHostToBigInt32(x) OSSwapInt32(x)
#   define OSSwapHostToBigInt64(x) OSSwapInt64(x)

#elif defined(__BIG_ENDIAN__)

#   define OSReadLittleInt16(base, byteOffset) OSSwapInt16(_OSReadInt16(base, byteOffset))
#   define OSReadLittleInt32(base, byteOffset) OSSwapInt32(_OSReadInt32(base, byteOffset))
#   define OSReadLittleInt64(base, byteOffset) OSSwapInt64(_OSReadInt64(base, byteOffset))

#   define OSWriteLittleInt16(base, byteOffset, data) _OSWriteInt16(base, byteOffset, OSSwapInt16(data))
#   define OSWriteLittleInt32(base, byteOffset, data) _OSWriteInt32(base, byteOffset, OSSwapInt32(data))
#   define OSWriteLittleInt64(base, byteOffset, data) _OSWriteInt64(base, byteOffset, OSSwapInt64(data))

#   define OSReadBigInt16(base, byteOffset) _OSReadInt16(base, byteOffset)
#   define OSReadBigInt32(base, byteOffset) _OSReadInt32(base, byteOffset)
#   define OSReadBigInt64(base, byteOffset) _OSReadInt64(base, byteOffset)

#   define OSWriteBigInt16(base, byteOffset, data) _OSWriteInt16(base, byteOffset, data)
#   define OSWriteBigInt32(base, byteOffset, data) _OSWriteInt32(base, byteOffset, data)
#   define OSWriteBigInt64(base, byteOffset, data) _OSWriteInt64(base, byteOffset, data)

#   define OSSwapBigToHostInt16(x) (x)
#   define OSSwapBigToHostInt32(x) (x)
#   define OSSwapBigToHostInt64(x) (x)

#   define OSSwapHostToBigInt16(x) (x)
#   define OSSwapHostToBigInt32(x) (x)
#   define OSSwapHostToBigInt64(x) (x)

#else

#   error Unknown endianness

#endif

#endif /* _LIBKERN_OSBYTEORDER_H_ */
