#ifndef _CORECRYPTO_CCDIGEST_H_
#define _CORECRYPTO_CCDIGEST_H_

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <openssl/sha.h>

#if 0
struct ccdigest_info
{
    //size_t output_size;
    //size_t state_size;
    //size_t block_size;
    //size_t oid_size;
    //const unsigned char *oid;
    //const void *initial_state;
    //void (*compress)(ccdigest_state_t state, size_t nblocks, const void *data);
    //void (*final)(const struct ccdigest_info *di, ccdigest_ctx_t ctx, unsigned char *digest);
    //cc_impl_t impl;
};

struct ccdigest_ctx
{
    uint8_t state[1];
} __attribute__((aligned(8)));



//#define ccdigest_di_decl(_di_, _name_) struct ccdigest_ctx _name_ [((((_di_)->state_size + sizeof(uint64_t) + (_di_)->block_size + sizeof(unsigned int)) + sizeof(struct ccdigest_ctx) - 1) / sizeof(struct ccdigest_ctx))];
#define ccdigest_di_decl(_di_, _name_) struct ccdigest_ctx _name_ [1 /* TODO */];

#endif

#define CCSHA1_OUTPUT_SIZE 20
#define CCSHA256_OUTPUT_SIZE 32

struct ccdigest_info
{
    uint8_t hashsize;
};

static inline const struct ccdigest_info* ccsha1_di(void)
{
    static const struct ccdigest_info di = { CCSHA1_OUTPUT_SIZE };
    return &di;
}

static inline const struct ccdigest_info* ccsha256_di(void)
{
    static const struct ccdigest_info di = { CCSHA256_OUTPUT_SIZE };
    return &di;
}

typedef union ccdigest_ctx
{
    SHA_CTX sha1;
    SHA256_CTX sha256;
} *ccdigest_ctx_t;

#define ccdigest_di_decl(_di_, _name_) union ccdigest_ctx _name_[1]

static inline void ccdigest_init(const struct ccdigest_info *di, ccdigest_ctx_t ctx)
{
    int r = 0;
    switch(di->hashsize)
    {
        case CCSHA1_OUTPUT_SIZE:   r = SHA1_Init(  &ctx->sha1  ); break;
        case CCSHA256_OUTPUT_SIZE: r = SHA256_Init(&ctx->sha256); break;
    }
    if(r != 1)
        abort();
}

static inline void ccdigest_update(const struct ccdigest_info *di, ccdigest_ctx_t ctx, size_t len, const void *data)
{
    int r = 0;
    switch(di->hashsize)
    {
        case CCSHA1_OUTPUT_SIZE:   r = SHA1_Update(  &ctx->sha1  , data, len); break;
        case CCSHA256_OUTPUT_SIZE: r = SHA256_Update(&ctx->sha256, data, len); break;
    }
    if(r != 1)
        abort();
}

static inline void ccdigest_final(const struct ccdigest_info *di, ccdigest_ctx_t ctx, unsigned char *digest)
{
    int r = 0;
    switch(di->hashsize)
    {
        case CCSHA1_OUTPUT_SIZE:   r = SHA1_Final(  digest, &ctx->sha1  ); break;
        case CCSHA256_OUTPUT_SIZE: r = SHA256_Final(digest, &ctx->sha256); break;
    }
    if(r != 1)
        abort();
}

#endif /* _CORECRYPTO_CCDIGEST_H_ */
