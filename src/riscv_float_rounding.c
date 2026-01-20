#include <stdint.h>
#include <math.h>
#include <fenv.h>

// For GCC/Clang RISC-V, we can use builtins or math functions
// that the compiler will recognize and translate to the appropriate instructions

// FCLASS instructions - use compiler builtins if available
// These classify floating-point values into categories

#ifdef __riscv
// Use RISC-V specific builtins if available
uint64_t fclass_s(float x) {
    // GCC/Clang should have __builtin_riscv_fclass_s or similar
    #if __has_builtin(__builtin_riscv_fclass_s)
        return __builtin_riscv_fclass_s(x);
    #else
        // Fallback: compiler should generate fclass.s from fpclassify + signbit checks
        int cls = fpclassify(x);
        int sign = signbit(x);
        uint64_t result = 0;
        
        if (cls == FP_INFINITE) result = sign ? (1 << 0) : (1 << 7);
        else if (cls == FP_NAN) result = isnan(x) ? ((1 << 9) | (1 << 8)) : 0;
        else if (cls == FP_ZERO) result = sign ? (1 << 3) : (1 << 4);
        else if (cls == FP_SUBNORMAL) result = sign ? (1 << 2) : (1 << 5);
        else if (cls == FP_NORMAL) result = sign ? (1 << 1) : (1 << 6);
        
        return result;
    #endif
}

uint64_t fclass_d(double x) {
    #if __has_builtin(__builtin_riscv_fclass_d)
        return __builtin_riscv_fclass_d(x);
    #else
        int cls = fpclassify(x);
        int sign = signbit(x);
        uint64_t result = 0;
        
        if (cls == FP_INFINITE) result = sign ? (1 << 0) : (1 << 7);
        else if (cls == FP_NAN) result = isnan(x) ? ((1 << 9) | (1 << 8)) : 0;
        else if (cls == FP_ZERO) result = sign ? (1 << 3) : (1 << 4);
        else if (cls == FP_SUBNORMAL) result = sign ? (1 << 2) : (1 << 5);
        else if (cls == FP_NORMAL) result = sign ? (1 << 1) : (1 << 6);
        
        return result;
    #endif
}

#ifdef __riscv_zfh
uint64_t fclass_h(_Float16 x) {
    #if __has_builtin(__builtin_riscv_fclass_h)
        return __builtin_riscv_fclass_h(x);
    #else
        // Convert to float for classification (compiler may optimize)
        float f = (float)x;
        return fclass_s(f);
    #endif
}
#endif

#endif // __riscv

// FROUND instructions - round to integer (ties to even)
// The compiler should generate fround.* instructions with -march=*_zfa

float fround_s(float x) {
    // nearbyintf rounds according to current rounding mode without raising inexact
    // With Zfa extension, compiler generates fround.s
    return nearbyintf(x);
}

double fround_d(double x) {
    // nearbyint for double precision
    return nearbyint(x);
}

#ifdef __riscv_zfh
_Float16 fround_h(_Float16 x) {
    // For half precision, may need to cast
    // Compiler with Zfh+Zfa should generate fround.h
    return (_Float16)nearbyintf((float)x);
}
#endif

// FROUNDNX instructions - round to integer with inexact exception
// These raise the inexact flag unlike nearbyint

float froundnx_s(float x) {
    // rintf rounds and raises inexact exception
    // With Zfa extension, compiler generates froundnx.s
    return rintf(x);
}

double froundnx_d(double x) {
    // rint for double precision
    return rint(x);
}

#ifdef __riscv_zfh
_Float16 froundnx_h(_Float16 x) {
    // For half precision with inexact
    return (_Float16)rintf((float)x);
}
#endif

// Alternative: Use explicit attribute to force instruction generation
// Some compilers support target-specific attributes

#if defined(__GNUC__) || defined(__clang__)
__attribute__((target("arch=+zfa")))
float fround_s_attr(float x) {
    return nearbyintf(x);
}

__attribute__((target("arch=+zfa")))
double fround_d_attr(double x) {
    return nearbyint(x);
}

__attribute__((target("arch=+zfa")))
float froundnx_s_attr(float x) {
    return rintf(x);
}

__attribute__((target("arch=+zfa")))
double froundnx_d_attr(double x) {
    return rint(x);
}
#endif

// Test function to ensure all instructions are used
void test_all_instructions() {
    float f = 3.14159f;
    double d = 2.71828;
    
    // FCLASS tests
    #ifdef __riscv
    volatile uint64_t class_s = fclass_s(f);
    volatile uint64_t class_d = fclass_d(d);
    #ifdef __riscv_zfh
    _Float16 h = 1.414f16;
    volatile uint64_t class_h = fclass_h(h);
    #endif
    #endif
    
    // FROUND tests
    volatile float round_s = fround_s(f);
    volatile double round_d = fround_d(d);
    #ifdef __riscv_zfh
    volatile _Float16 round_h = fround_h(h);
    #endif
    
    // FROUNDNX tests
    volatile float roundnx_s = froundnx_s(f);
    volatile double roundnx_d = froundnx_d(d);
    #ifdef __riscv_zfh
    volatile _Float16 roundnx_h = froundnx_h(h);
    #endif
    
    // Test with attributes if supported
    #if defined(__GNUC__) || defined(__clang__)
    volatile float round_s2 = fround_s_attr(f);
    volatile double round_d2 = fround_d_attr(d);
    volatile float roundnx_s2 = froundnx_s_attr(f);
    volatile double roundnx_d2 = froundnx_d_attr(d);
    #endif
}

int main() {
    test_all_instructions();
    return 0;
}
