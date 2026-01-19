#ifndef _COMMONCRYPTO_COMMONDIGEST_H_
#define _COMMONCRYPTO_COMMONDIGEST_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>
#include <stdint.h>
#include <openssl/sha.h>

typedef enum
{
    kCCDigestSHA256,
} CCDigestAlgorithm;

static inline int CCDigest(CCDigestAlgorithm alg, const uint8_t *data, size_t len, uint8_t *out)
{
    switch(alg)
    {
        case kCCDigestSHA256: SHA256(data, len, out); return 0;
    }
    return -1;
}

#ifdef __cplusplus
}
#endif

#endif /* _COMMONCRYPTO_COMMONDIGEST_H_ */
