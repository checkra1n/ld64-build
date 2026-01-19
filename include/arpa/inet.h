#ifndef _ARPA_INET_H_
#define _ARPA_INET_H_

#include <libkern/OSByteOrder.h>

#define ntohs(x)  OSSwapBigToHostInt16(x)
#define ntohl(x)  OSSwapBigToHostInt32(x)
#define ntohll(x) OSSwapBigToHostInt64(x)

#define htons(x)  OSSwapHostToBigInt16(x)
#define htonl(x)  OSSwapHostToBigInt32(x)
#define htonll(x) OSSwapHostToBigInt64(x)

#endif /* _ARPA_INET_H_ */
