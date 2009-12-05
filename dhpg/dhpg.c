#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdlib.h> /* for rand() */
#include <time.h>
#include "basic_funcs.h"
#include "number_theory.h"
#include "bitset_funcs.h"
#include "sha1.h"

int random(int min, int max) { 
    return (int)((max - min) * (rand() / (float)RAND_MAX)) + min;
}

// L >= 512     
int generation_of_p_q(int L, big_int *p, big_int *q) {
    int m = 1;
    int l = (int)ceil(L / 160.0);
    int N = (int)ceil(L / 1024.0) * 4096;
    int i, is_prime, counter, cmp_flag, result;
    big_int *one, *two, *modulus, *seed, *U, *R, *V, *W, *X, *t1, *t2, *t3, *t4;
    one = big_int_create(1);
    two = big_int_create(1);
    modulus = big_int_create(1);
    seed = big_int_create(1);
    U = big_int_create(1);
    R = big_int_create(1);
    V = big_int_create(1);
    W = big_int_create(1);
    X = big_int_create(1);
    t1 = big_int_create(1);
    t2 = big_int_create(1);
    t3 = big_int_create(1);
    t4 = big_int_create(1);
    big_int_from_int(1, one);
    big_int_from_int(2, two);
    big_int_pow(two, 160, modulus);

    do {
        big_int_rand(rand, random(160, L), seed);
        // U = sha1(seed) xor sha1((seed + 1) mod 2^160);
        big_int_sha1(seed, t1);
        big_int_add(seed, one, t2);
        big_int_mod(t2, modulus, t4);
        big_int_sha1(t4, t2);
        big_int_xor(t1, t2, 0, U);
        // q = U mod 2^160;
        big_int_mod(U, modulus, q);
        // q = q or 2^(160 - 1) or 1;
        big_int_set_bit(q, 159, q);
        big_int_set_bit(q, 0, q);
        big_int_is_prime(q, 10, 2, &is_prime);
    } while(!is_prime);
    counter = 0;
    do {
        big_int_from_int(2 + l * counter, t1);
        big_int_add(seed, t1, R);
        big_int_from_int(0, V);
        big_int_copy(modulus, t2);
        for (i = 0; i < l; i++) {
            // V = V + sha1(R + i) * (2 ^ (160 * i));
            big_int_add(R, one, R);
            big_int_sha1(R, t1);
            big_int_mul(t2, modulus, t2);
            big_int_mul(t1, t2, t3);
            big_int_add(V, t3, V);
        }
        // W = V mod 2^L;
        big_int_pow(two, L, t2);
        big_int_mod(V, t2, W);
        // X = W OR 2^(L-1);
        big_int_rshift(t2, 1, t1);
        big_int_or(W, t1, 0, X);
        // p = X - (X mod (2*q)) + 1;
        big_int_mul(two, q, t2);
        big_int_mod(X, t2, t3);
        big_int_sub(X, t3, t4);
        big_int_add(t4, one, p);
        big_int_cmp_abs(p, t1, &cmp_flag);
        if (cmp_flag > 0) {
            big_int_is_prime(p, 10, 2, &is_prime);
            if (is_prime) {
                result = 1;
                goto done;
            }
        }
        counter++;
    } while (counter < N);
    result = 0;

done:
    big_int_destroy(one);
    big_int_destroy(two);
    big_int_destroy(modulus);
    big_int_destroy(seed);
    big_int_destroy(U);
    big_int_destroy(R);
    big_int_destroy(V);
    big_int_destroy(W);
    big_int_destroy(X);
    big_int_destroy(t1);
    big_int_destroy(t2);
    big_int_destroy(t3);
    big_int_destroy(t4);
    return result;
}

// L >= 512
void generation_of_g(int L, const big_int *p, const big_int *q, big_int *g) {
    int cmp_flag;
    big_int *one, *two, *h, *j, *t;
    one = big_int_create(1);
    two = big_int_create(1);
    h = big_int_create(1);
    j = big_int_create(1);
    t = big_int_create(1);

    big_int_from_int(1, one);
    big_int_from_int(2, two);

    // j = (p - 1)/q;
    big_int_sub(p, one, t);
    big_int_div(t, q, j);
    
    big_int_sub(p, one, t);
    do {
        big_int_rand(rand, random(1, L), h);
        big_int_cmp_abs(h, t, &cmp_flag);
        while (cmp_flag >= 0) {
            big_int_rshift(h, 1, h);
            big_int_cmp_abs(h, t, &cmp_flag);
        }
        big_int_powmod(h, j, p, g);
        big_int_cmp_abs(g, one, &cmp_flag);
    } while (cmp_flag <= 0);
    big_int_destroy(one);
    big_int_destroy(two);
    big_int_destroy(h);
    big_int_destroy(j);
    big_int_destroy(t);
}

// L < 512
void generation_of_p_q_g(int L, big_int *p, big_int *q, big_int *g) {
    int cmp_flag, is_prime;
    big_int *one, *two, *t;
    one = big_int_create(1);
    two = big_int_create(1);
    t = big_int_create(1);
    do {
        big_int_rand(rand, L - 1, t);
        big_int_set_bit(t, L - 2, t);
        big_int_next_prime(t, q);
        big_int_lshift(q, 1, t);
        big_int_set_bit(t, 0, p);
        big_int_is_prime(p, 10, 2, &is_prime);
    } while (!is_prime);
    do {
        big_int_rand(rand, L - 1, t);
        big_int_set_bit(t, L - 2, t);
        big_int_set_bit(t, 0, g);
        big_int_powmod(g, two, p, t);
        big_int_cmp_abs(t, one, &cmp_flag);
        if (cmp_flag == 0) continue;
        big_int_powmod(g, q, p, t);
        big_int_cmp_abs(t, one, &cmp_flag);
    } while (cmp_flag == 0);
    big_int_destroy(one);
    big_int_destroy(two);
    big_int_destroy(t);
}

int main(int argc, char *argv[]) {
    big_int_str *str;
    big_int *l, *p, *q, *g;
    int L, i, n, f = 1, len;
    str = big_int_str_create(1);

    if (argc < 2) {
        L = 1024;
    }
    else {
        l = big_int_create(1);
        big_int_str_copy_s(argv[1], strlen(argv[1]), str);
        big_int_from_str(str, 10, l);
        big_int_to_int(l, &L);
        big_int_destroy(l);
    }

    if (argc < 3) {
        n = 1;
    }
    else {
        l = big_int_create(1);
        big_int_str_copy_s(argv[2], strlen(argv[2]), str);
        big_int_from_str(str, 10, l);
        big_int_to_int(l, &n);
        big_int_destroy(l);
    }

    srand((unsigned)time(NULL));

    p = big_int_create(1);
    q = big_int_create(1);
    g = big_int_create(1);

    printf("a:%d:{", n);
    for (i = 0; i < n; i++) {
        if (L < 512) {
            generation_of_p_q_g(L, p, q, g);
        }
        else if (f = generation_of_p_q(L, p, q)) {
            generation_of_g(L, p, q, g);
        }

        if (f) {
            printf("i:%d;a:2:{", i);
            big_int_to_str(p, 10, str);
            len = strlen(str->str);
            printf("s:1:\"p\";s:%d:\"%s\";", len, str->str);
            big_int_to_str(g, 10, str);
            len = strlen(str->str);
            printf("s:1:\"g\";s:%d:\"%s\";", len, str->str);
            printf("}");
        }
        else {
            i--;
        }
    }
    printf("}");

    big_int_str_destroy(str);
    big_int_destroy(g);
    big_int_destroy(p);
    big_int_destroy(q);
    return 0;
}

