/*
By Ma Bingyao <andot@coolcode.cn>
100% Public Domain
*/
#ifndef BIG_INT_SHA1_H
#define BIG_INT_SHA1_H

#include "big_int.h"

#ifdef __cplusplus
extern "C" {
#endif

BIG_INT_API void big_int_sha1(const big_int *a, big_int *answer);

#ifdef __cplusplus
}
#endif

#endif