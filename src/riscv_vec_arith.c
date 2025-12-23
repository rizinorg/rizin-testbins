#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <string.h>

#define N 1024
#define ALIGN 64

// Use restrict and alignment attributes to help vectorization
#define RESTRICT __restrict__
#define ALIGNED __attribute__((aligned(ALIGN)))

// Portable alignment allocation
void* aligned_alloc_portable(size_t alignment, size_t size) {
    void* ptr = NULL;
    posix_memalign(&ptr, alignment, size);
    return ptr;
}

// Tell compiler to assume alignment
#define ASSUME_ALIGNED(ptr) __builtin_assume_aligned(ptr, ALIGN)

// Reduction operations - use OpenMP SIMD pragmas
void test_reductions(int32_t * RESTRICT a, int32_t * RESTRICT b, 
                     float * RESTRICT fa, float * RESTRICT fb) {
    int32_t sum = 0, max_val = a[0], min_val = a[0];
    uint32_t and_val = ~0u, or_val = 0, xor_val = 0;
    float fsum = 0.0f, fmax = fa[0], fmin = fa[0];
    
    // Simple reduction patterns that compilers recognize
    #pragma omp simd reduction(+:sum)
    for (int i = 0; i < N; i++) {
        sum += a[i];
    }
    
    #pragma omp simd reduction(max:max_val)
    for (int i = 0; i < N; i++) {
        max_val = (a[i] > max_val) ? a[i] : max_val;
    }
    
    #pragma omp simd reduction(min:min_val)
    for (int i = 0; i < N; i++) {
        min_val = (a[i] < min_val) ? a[i] : min_val;
    }
    
    #pragma omp simd reduction(&:and_val)
    for (int i = 0; i < N; i++) {
        and_val &= b[i];
    }
    
    #pragma omp simd reduction(|:or_val)
    for (int i = 0; i < N; i++) {
        or_val |= b[i];
    }
    
    #pragma omp simd reduction(^:xor_val)
    for (int i = 0; i < N; i++) {
        xor_val ^= b[i];
    }
    
    #pragma omp simd reduction(+:fsum)
    for (int i = 0; i < N; i++) {
        fsum += fa[i];
    }
    
    #pragma omp simd reduction(max:fmax)
    for (int i = 0; i < N; i++) {
        fmax = (fa[i] > fmax) ? fa[i] : fmax;
    }
    
    #pragma omp simd reduction(min:fmin)
    for (int i = 0; i < N; i++) {
        fmin = (fa[i] < fmin) ? fa[i] : fmin;
    }
    
    printf("Sum: %d, Max: %d, Min: %d, AND: %u, OR: %u, XOR: %u\n", 
           sum, max_val, min_val, and_val, or_val, xor_val);
    printf("Float Sum: %f, Max: %f, Min: %f\n", fsum, fmax, fmin);
}

// Comparison and masking
void test_comparisons(int32_t * RESTRICT a, int32_t * RESTRICT b, int32_t * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    b = ASSUME_ALIGNED(b);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = (a[i] < b[i]) ? a[i] : b[i];
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = (a[i] == b[i]) ? 1 : 0;
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = (a[i] >= 100) ? a[i] : 0;
    }
}

// Shifts
void test_shifts(uint32_t * RESTRICT a, int32_t * RESTRICT sa, uint32_t * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    sa = ASSUME_ALIGNED(sa);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = a[i] << 3;
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = a[i] >> 2;
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = sa[i] >> 4;
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = a[i] << (i & 7);
    }
}

// Bitwise operations
void test_bitwise(uint32_t * RESTRICT a, uint32_t * RESTRICT b, uint32_t * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    b = ASSUME_ALIGNED(b);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = a[i] & b[i];
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = a[i] | b[i];
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = a[i] ^ b[i];
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = ~a[i];
    }
}

// Saturating arithmetic
void test_saturating(int16_t * RESTRICT a, int16_t * RESTRICT b, int16_t * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    b = ASSUME_ALIGNED(b);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        int32_t temp = (int32_t)a[i] + (int32_t)b[i];
        if (temp > 32767) temp = 32767;
        if (temp < -32768) temp = -32768;
        result[i] = (int16_t)temp;
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        int32_t temp = (int32_t)a[i] - (int32_t)b[i];
        if (temp > 32767) temp = 32767;
        if (temp < -32768) temp = -32768;
        result[i] = (int16_t)temp;
    }
}

// Widening operations
void test_widening(int16_t * RESTRICT a, int16_t * RESTRICT b, int32_t * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    b = ASSUME_ALIGNED(b);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = (int32_t)a[i] + (int32_t)b[i];
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = (int32_t)a[i] * (int32_t)b[i];
    }
}

// Narrowing operations
void test_narrowing(int32_t * RESTRICT a, int16_t * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = (int16_t)(a[i] >> 8);
    }
}

// Floating point operations
void test_float_ops(float * RESTRICT a, float * RESTRICT b, float * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    b = ASSUME_ALIGNED(b);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = a[i] + b[i];
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = a[i] - b[i];
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = a[i] / b[i];
    }
    
    // Simplified sqrt - avoid library call issues
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        // Use a[i] directly if positive, compiler may optimize better
        result[i] = (a[i] > 0.0f) ? sqrtf(a[i]) : 0.0f;
    }
}

// FMA operations
void test_fma(float * RESTRICT a, float * RESTRICT b, float * RESTRICT c, float * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    b = ASSUME_ALIGNED(b);
    c = ASSUME_ALIGNED(c);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = a[i] * b[i] + c[i];
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = a[i] * b[i] - c[i];
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = -(a[i] * b[i]) + c[i];
    }
}

// Floating point comparisons
void test_float_comparisons(float * RESTRICT a, float * RESTRICT b, float * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    b = ASSUME_ALIGNED(b);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = (a[i] < b[i]) ? a[i] : b[i];
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = (a[i] == b[i]) ? 1.0f : 0.0f;
    }
}

// Conversion operations
void test_conversions(int32_t * RESTRICT ia, float * RESTRICT fa, 
                     int32_t * RESTRICT result_i, float * RESTRICT result_f) {
    ia = ASSUME_ALIGNED(ia);
    fa = ASSUME_ALIGNED(fa);
    result_i = ASSUME_ALIGNED(result_i);
    result_f = ASSUME_ALIGNED(result_f);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result_f[i] = (float)ia[i];
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result_i[i] = (int32_t)fa[i];
    }
}

// Sign injection
void test_sign_injection(float * RESTRICT a, float * RESTRICT b, float * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    b = ASSUME_ALIGNED(b);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = copysignf(a[i], b[i]);
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = fabsf(a[i]);
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = -fabsf(a[i]);
    }
}

// Strided access - simplified for better vectorization
void test_strided_access(float * RESTRICT a, float * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    result = ASSUME_ALIGNED(result);
    
    // Simple strided pattern
    #pragma omp simd
    for (int i = 0; i < N/2; i++) {
        result[i] = a[i * 2];
    }
    
    // Reverse copy - split into forward loop for better vectorization
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[N - 1 - i] = a[i];
    }
}

// Segment access
void test_segment_access(float * RESTRICT x, float * RESTRICT y, 
                        float * RESTRICT z, float * RESTRICT result) {
    x = ASSUME_ALIGNED(x);
    y = ASSUME_ALIGNED(y);
    z = ASSUME_ALIGNED(z);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = x[i] + y[i] + z[i];
    }
}

// Multi-byte element operations
void test_multi_byte(int64_t * RESTRICT a, int64_t * RESTRICT b, int64_t * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    b = ASSUME_ALIGNED(b);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N/2; i++) {
        result[i] = a[i] + b[i];
    }
}

// Mixed width operations
void test_mixed_width(int8_t * RESTRICT a8, int16_t * RESTRICT a16, int32_t * RESTRICT a32) {
    a8 = ASSUME_ALIGNED(a8);
    a16 = ASSUME_ALIGNED(a16);
    a32 = ASSUME_ALIGNED(a32);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        a8[i] = a8[i] + 1;
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        a16[i] = a16[i] * 2;
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        a32[i] = a32[i] - 1;
    }
}

// Average and rounding
void test_average(uint32_t * RESTRICT a, uint32_t * RESTRICT b, uint32_t * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    b = ASSUME_ALIGNED(b);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = ((uint64_t)a[i] + (uint64_t)b[i]) >> 1;
    }
}

// Clipping/clamping
void test_clip(int32_t * RESTRICT a, int32_t * RESTRICT result, int32_t min_val, int32_t max_val) {
    a = ASSUME_ALIGNED(a);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        int32_t val = a[i];
        val = (val < min_val) ? min_val : val;
        val = (val > max_val) ? max_val : val;
        result[i] = val;
    }
}

// Absolute value and negation
void test_abs_neg(int32_t * RESTRICT a, int32_t * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = (a[i] < 0) ? -a[i] : a[i];
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = -a[i];
    }
}

// Additional operations for better coverage

// Min/Max operations
void test_minmax(int32_t * RESTRICT a, int32_t * RESTRICT b, int32_t * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    b = ASSUME_ALIGNED(b);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = (a[i] > b[i]) ? a[i] : b[i];  // vmax
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = (a[i] < b[i]) ? a[i] : b[i];  // vmin
    }
}

// Unsigned operations
void test_unsigned_ops(uint32_t * RESTRICT a, uint32_t * RESTRICT b, uint32_t * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    b = ASSUME_ALIGNED(b);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = (a[i] > b[i]) ? a[i] : b[i];  // vmaxu
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = (a[i] < b[i]) ? a[i] : b[i];  // vminu
    }
}

// Multiply-add patterns
void test_madd(int32_t * RESTRICT a, int32_t * RESTRICT b, int32_t * RESTRICT c, 
               int32_t * RESTRICT result) {
    a = ASSUME_ALIGNED(a);
    b = ASSUME_ALIGNED(b);
    c = ASSUME_ALIGNED(c);
    result = ASSUME_ALIGNED(result);
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = a[i] * b[i] + c[i];  // vmadd
    }
    
    #pragma omp simd
    for (int i = 0; i < N; i++) {
        result[i] = c[i] - a[i] * b[i];  // vnmsub
    }
}

int main() {
    // Allocate aligned arrays
    int32_t *a32 = aligned_alloc_portable(ALIGN, N * sizeof(int32_t));
    int32_t *b32 = aligned_alloc_portable(ALIGN, N * sizeof(int32_t));
    int32_t *c32 = aligned_alloc_portable(ALIGN, N * sizeof(int32_t));
    int32_t *r32 = aligned_alloc_portable(ALIGN, N * sizeof(int32_t));
    
    int16_t *a16 = aligned_alloc_portable(ALIGN, N * sizeof(int16_t));
    int16_t *b16 = aligned_alloc_portable(ALIGN, N * sizeof(int16_t));
    int16_t *r16 = aligned_alloc_portable(ALIGN, N * sizeof(int16_t));
    
    int8_t *a8 = aligned_alloc_portable(ALIGN, N * sizeof(int8_t));
    
    int64_t *a64 = aligned_alloc_portable(ALIGN, N * sizeof(int64_t));
    int64_t *b64 = aligned_alloc_portable(ALIGN, N * sizeof(int64_t));
    int64_t *r64 = aligned_alloc_portable(ALIGN, N * sizeof(int64_t));
    
    float *fa = aligned_alloc_portable(ALIGN, N * sizeof(float));
    float *fb = aligned_alloc_portable(ALIGN, N * sizeof(float));
    float *fc = aligned_alloc_portable(ALIGN, N * sizeof(float));
    float *fr = aligned_alloc_portable(ALIGN, N * sizeof(float));
    
    uint32_t *ua = aligned_alloc_portable(ALIGN, N * sizeof(uint32_t));
    uint32_t *ub = aligned_alloc_portable(ALIGN, N * sizeof(uint32_t));
    uint32_t *ur = aligned_alloc_portable(ALIGN, N * sizeof(uint32_t));
    
    // Initialize
    for (int i = 0; i < N; i++) {
        a32[i] = i - N/2;
        b32[i] = (i * 7) % 256;
        c32[i] = (i * 3) % 128;
        a16[i] = i - N/2;
        b16[i] = (i * 3) % 128;
        a8[i] = i % 128;
        fa[i] = (float)i / 10.0f + 1.0f;  // Ensure positive for sqrt
        fb[i] = (float)(N - i) / 10.0f + 1.0f;
        fc[i] = (float)(i % 100) / 10.0f;
        ua[i] = i * 13;
        ub[i] = (N - i) * 17;
    }
    
    for (int i = 0; i < N/2; i++) {
        a64[i] = i * 1000;
        b64[i] = (N - i) * 1000;
    }
    
    printf("Testing RISC-V Vector Instructions via Improved Auto-Vectorization\n\n");
    
    test_reductions(a32, b32, fa, fb);
    test_comparisons(a32, b32, r32);
    test_shifts(ua, a32, ur);
    test_bitwise(ua, ub, ur);
    test_saturating(a16, b16, r16);
    test_widening(a16, b16, r32);
    test_narrowing(a32, r16);
    test_float_ops(fa, fb, fr);
    test_fma(fa, fb, fc, fr);
    test_float_comparisons(fa, fb, fr);
    test_conversions(a32, fa, r32, fr);
    test_sign_injection(fa, fb, fr);
    test_strided_access(fa, fr);
    test_segment_access(fa, fb, fc, fr);
    test_multi_byte(a64, b64, r64);
    test_mixed_width(a8, a16, a32);
    test_average(ua, ub, ur);
    test_clip(a32, r32, -100, 100);
    test_abs_neg(a32, r32);
    test_minmax(a32, b32, r32);
    test_unsigned_ops(ua, ub, ur);
    test_madd(a32, b32, c32, r32);
    
    printf("\nAll tests completed successfully!\n");
    
    // Cleanup
    free(a32); free(b32); free(c32); free(r32);
    free(a16); free(b16); free(r16);
    free(a8);
    free(a64); free(b64); free(r64);
    free(fa); free(fb); free(fc); free(fr);
    free(ua); free(ub); free(ur);
    
    return 0;
}