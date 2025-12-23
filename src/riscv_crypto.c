/*
 * RISC-V Cryptography Extensions Test Program
 * This program exercises all scalar crypto instructions from:
 * - Zknd (AES Decryption)
 * - Zkne (AES Encryption) 
 * - Zknh (SHA-2 Hash)
 * 
 * Compile with: riscv64-unknown-elf-gcc -march=rv64gc_zknd_zkne_zknh -O2 -o test test.c
 * or for RV32: riscv32-unknown-elf-gcc -march=rv32gc_zknd_zkne_zknh -O2 -o test test.c
 */

#include <stdint.h>
#include <stdio.h>

// ============================================================================
// AES-32 Instructions (RV32 only)
// ============================================================================

#if __riscv_xlen == 32

// AES32DSI - AES Decrypt SubBytes and InvShiftRows (middle rounds)
// Note: bs must be a compile-time constant (0-3)
#define aes32dsi(rs1, rs2, bs) ({ \
    uint32_t _rd; \
    uint32_t _rs1 = (rs1); \
    uint32_t _rs2 = (rs2); \
    __asm__ volatile ("aes32dsi %0, %1, %2, %3" \
                     : "=r"(_rd) \
                     : "r"(_rs1), "r"(_rs2), "i"(bs)); \
    _rd; \
})

// AES32DSMI - AES Decrypt SubBytes and InvShiftRows and InvMixColumns (middle rounds)
#define aes32dsmi(rs1, rs2, bs) ({ \
    uint32_t _rd; \
    uint32_t _rs1 = (rs1); \
    uint32_t _rs2 = (rs2); \
    __asm__ volatile ("aes32dsmi %0, %1, %2, %3" \
                     : "=r"(_rd) \
                     : "r"(_rs1), "r"(_rs2), "i"(bs)); \
    _rd; \
})

// AES32ESI - AES Encrypt SubBytes and ShiftRows (middle rounds)
#define aes32esi(rs1, rs2, bs) ({ \
    uint32_t _rd; \
    uint32_t _rs1 = (rs1); \
    uint32_t _rs2 = (rs2); \
    __asm__ volatile ("aes32esi %0, %1, %2, %3" \
                     : "=r"(_rd) \
                     : "r"(_rs1), "r"(_rs2), "i"(bs)); \
    _rd; \
})

// AES32ESMI - AES Encrypt SubBytes and ShiftRows and MixColumns (middle rounds)
#define aes32esmi(rs1, rs2, bs) ({ \
    uint32_t _rd; \
    uint32_t _rs1 = (rs1); \
    uint32_t _rs2 = (rs2); \
    __asm__ volatile ("aes32esmi %0, %1, %2, %3" \
                     : "=r"(_rd) \
                     : "r"(_rs1), "r"(_rs2), "i"(bs)); \
    _rd; \
})

#endif // RV32

// ============================================================================
// AES-64 Instructions (RV64 only)
// ============================================================================

#if __riscv_xlen == 64

// AES64DS - AES Decrypt final round (SubBytes + InvShiftRows)
static inline uint64_t aes64ds(uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    __asm__ volatile ("aes64ds %0, %1, %2" 
                     : "=r"(rd) 
                     : "r"(rs1), "r"(rs2));
    return rd;
}

// AES64DSM - AES Decrypt middle round (SubBytes + InvShiftRows + InvMixColumns)
static inline uint64_t aes64dsm(uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    __asm__ volatile ("aes64dsm %0, %1, %2" 
                     : "=r"(rd) 
                     : "r"(rs1), "r"(rs2));
    return rd;
}

// AES64ES - AES Encrypt final round (SubBytes + ShiftRows)
static inline uint64_t aes64es(uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    __asm__ volatile ("aes64es %0, %1, %2" 
                     : "=r"(rd) 
                     : "r"(rs1), "r"(rs2));
    return rd;
}

// AES64ESM - AES Encrypt middle round (SubBytes + ShiftRows + MixColumns)
static inline uint64_t aes64esm(uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    __asm__ volatile ("aes64esm %0, %1, %2" 
                     : "=r"(rd) 
                     : "r"(rs1), "r"(rs2));
    return rd;
}

// AES64IM - AES InvMixColumns for key schedule
static inline uint64_t aes64im(uint64_t rs1) {
    uint64_t rd;
    __asm__ volatile ("aes64im %0, %1" 
                     : "=r"(rd) 
                     : "r"(rs1));
    return rd;
}

// AES64KS1I - AES Key Schedule 1 with immediate round constant
// Note: rnum must be a compile-time constant (0-10)
#define aes64ks1i(rs1, rnum) ({ \
    uint64_t _rd; \
    uint64_t _rs1 = (rs1); \
    __asm__ volatile ("aes64ks1i %0, %1, %2" \
                     : "=r"(_rd) \
                     : "r"(_rs1), "i"(rnum)); \
    _rd; \
})

// AES64KS2 - AES Key Schedule 2
static inline uint64_t aes64ks2(uint64_t rs1, uint64_t rs2) {
    uint64_t rd;
    __asm__ volatile ("aes64ks2 %0, %1, %2" 
                     : "=r"(rd) 
                     : "r"(rs1), "r"(rs2));
    return rd;
}

#endif // RV64

// ============================================================================
// SHA-256 Instructions (RV32 and RV64)
// ============================================================================

// SHA256SIG0 - SHA-256 Sigma0 transformation
static inline unsigned long sha256sig0(unsigned long rs1) {
    unsigned long rd;
    __asm__ volatile ("sha256sig0 %0, %1" 
                     : "=r"(rd) 
                     : "r"(rs1));
    return rd;
}

// SHA256SIG1 - SHA-256 Sigma1 transformation
static inline unsigned long sha256sig1(unsigned long rs1) {
    unsigned long rd;
    __asm__ volatile ("sha256sig1 %0, %1" 
                     : "=r"(rd) 
                     : "r"(rs1));
    return rd;
}

// SHA256SUM0 - SHA-256 Sum0 transformation
static inline unsigned long sha256sum0(unsigned long rs1) {
    unsigned long rd;
    __asm__ volatile ("sha256sum0 %0, %1" 
                     : "=r"(rd) 
                     : "r"(rs1));
    return rd;
}

// SHA256SUM1 - SHA-256 Sum1 transformation
static inline unsigned long sha256sum1(unsigned long rs1) {
    unsigned long rd;
    __asm__ volatile ("sha256sum1 %0, %1" 
                     : "=r"(rd) 
                     : "r"(rs1));
    return rd;
}

// ============================================================================
// SHA-512 Instructions
// ============================================================================

#if __riscv_xlen == 64

// SHA512SIG0 - SHA-512 Sigma0 transformation (RV64 only)
static inline uint64_t sha512sig0(uint64_t rs1) {
    uint64_t rd;
    __asm__ volatile ("sha512sig0 %0, %1" 
                     : "=r"(rd) 
                     : "r"(rs1));
    return rd;
}

// SHA512SIG1 - SHA-512 Sigma1 transformation (RV64 only)
static inline uint64_t sha512sig1(uint64_t rs1) {
    uint64_t rd;
    __asm__ volatile ("sha512sig1 %0, %1" 
                     : "=r"(rd) 
                     : "r"(rs1));
    return rd;
}

// SHA512SUM0 - SHA-512 Sum0 transformation (RV64 only)
static inline uint64_t sha512sum0(uint64_t rs1) {
    uint64_t rd;
    __asm__ volatile ("sha512sum0 %0, %1" 
                     : "=r"(rd) 
                     : "r"(rs1));
    return rd;
}

// SHA512SUM1 - SHA-512 Sum1 transformation (RV64 only)
static inline uint64_t sha512sum1(uint64_t rs1) {
    uint64_t rd;
    __asm__ volatile ("sha512sum1 %0, %1" 
                     : "=r"(rd) 
                     : "r"(rs1));
    return rd;
}

#endif // RV64

#if __riscv_xlen == 32

// SHA512SIG0H - SHA-512 Sigma0 high half (RV32 only)
static inline uint32_t sha512sig0h(uint32_t rs1, uint32_t rs2) {
    uint32_t rd;
    __asm__ volatile ("sha512sig0h %0, %1, %2" 
                     : "=r"(rd) 
                     : "r"(rs1), "r"(rs2));
    return rd;
}

// SHA512SIG0L - SHA-512 Sigma0 low half (RV32 only)
static inline uint32_t sha512sig0l(uint32_t rs1, uint32_t rs2) {
    uint32_t rd;
    __asm__ volatile ("sha512sig0l %0, %1, %2" 
                     : "=r"(rd) 
                     : "r"(rs1), "r"(rs2));
    return rd;
}

// SHA512SIG1H - SHA-512 Sigma1 high half (RV32 only)
static inline uint32_t sha512sig1h(uint32_t rs1, uint32_t rs2) {
    uint32_t rd;
    __asm__ volatile ("sha512sig1h %0, %1, %2" 
                     : "=r"(rd) 
                     : "r"(rs1), "r"(rs2));
    return rd;
}

// SHA512SIG1L - SHA-512 Sigma1 low half (RV32 only)
static inline uint32_t sha512sig1l(uint32_t rs1, uint32_t rs2) {
    uint32_t rd;
    __asm__ volatile ("sha512sig1l %0, %1, %2" 
                     : "=r"(rd) 
                     : "r"(rs1), "r"(rs2));
    return rd;
}

// SHA512SUM0R - SHA-512 Sum0 (RV32 only)
static inline uint32_t sha512sum0r(uint32_t rs1, uint32_t rs2) {
    uint32_t rd;
    __asm__ volatile ("sha512sum0r %0, %1, %2" 
                     : "=r"(rd) 
                     : "r"(rs1), "r"(rs2));
    return rd;
}

// SHA512SUM1R - SHA-512 Sum1 (RV32 only)
static inline uint32_t sha512sum1r(uint32_t rs1, uint32_t rs2) {
    uint32_t rd;
    __asm__ volatile ("sha512sum1r %0, %1, %2" 
                     : "=r"(rd) 
                     : "r"(rs1), "r"(rs2));
    return rd;
}

#endif // RV32

// ============================================================================
// Test Functions
// ============================================================================

void test_aes32_instructions() {
#if __riscv_xlen == 32
    uint32_t state = 0x12345678;
    uint32_t key = 0x9abcdef0;
    
    printf("Testing AES-32 instructions...\n");
    
    // Test all byte select positions (0-3)
    state = aes32dsi(state, key, 0);
    state = aes32dsmi(state, key, 1);
    state = aes32esi(state, key, 2);
    state = aes32esmi(state, key, 3);
    
    printf("AES-32 result: 0x%08x\n", state);
#else
    printf("AES-32 instructions only available on RV32\n");
#endif
}

void test_aes64_instructions() {
#if __riscv_xlen == 64
    uint64_t state1 = 0x0123456789abcdefULL;
    uint64_t state2 = 0xfedcba9876543210ULL;
    uint64_t key = 0x0f0e0d0c0b0a0908ULL;
    
    printf("Testing AES-64 instructions...\n");
    
    // Test decryption
    state1 = aes64ds(state1, state2);
    state1 = aes64dsm(state1, state2);
    
    // Test encryption
    state1 = aes64es(state1, state2);
    state1 = aes64esm(state1, state2);
    
    // Test key schedule
    key = aes64im(key);
    key = aes64ks1i(key, 1);
    key = aes64ks2(key, state1);
    
    printf("AES-64 result: 0x%016lx\n", key);
#else
    printf("AES-64 instructions only available on RV64\n");
#endif
}

void test_sha256_instructions() {
    unsigned long w = 0x6a09e667;
    unsigned long result;
    
    printf("Testing SHA-256 instructions...\n");
    
    result = sha256sig0(w);
    printf("SHA256SIG0: 0x%lx\n", result);
    
    result = sha256sig1(w);
    printf("SHA256SIG1: 0x%lx\n", result);
    
    result = sha256sum0(w);
    printf("SHA256SUM0: 0x%lx\n", result);
    
    result = sha256sum1(w);
    printf("SHA256SUM1: 0x%lx\n", result);
}

void test_sha512_instructions() {
#if __riscv_xlen == 64
    uint64_t w = 0x6a09e667f3bcc908ULL;
    uint64_t result;
    
    printf("Testing SHA-512 instructions (RV64)...\n");
    
    result = sha512sig0(w);
    printf("SHA512SIG0: 0x%016lx\n", result);
    
    result = sha512sig1(w);
    printf("SHA512SIG1: 0x%016lx\n", result);
    
    result = sha512sum0(w);
    printf("SHA512SUM0: 0x%016lx\n", result);
    
    result = sha512sum1(w);
    printf("SHA512SUM1: 0x%016lx\n", result);
    
#else
    uint32_t w_hi = 0x6a09e667;
    uint32_t w_lo = 0xf3bcc908;
    uint32_t result_hi, result_lo;
    
    printf("Testing SHA-512 instructions (RV32)...\n");
    
    result_hi = sha512sig0h(w_hi, w_lo);
    result_lo = sha512sig0l(w_hi, w_lo);
    printf("SHA512SIG0H/L: 0x%08x%08x\n", result_hi, result_lo);
    
    result_hi = sha512sig1h(w_hi, w_lo);
    result_lo = sha512sig1l(w_hi, w_lo);
    printf("SHA512SIG1H/L: 0x%08x%08x\n", result_hi, result_lo);
    
    result_hi = sha512sum0r(w_hi, w_lo);
    printf("SHA512SUM0R: 0x%08x\n", result_hi);
    
    result_hi = sha512sum1r(w_hi, w_lo);
    printf("SHA512SUM1R: 0x%08x\n", result_hi);
#endif
}

// ============================================================================
// Main Program
// ============================================================================

int main() {
    printf("RISC-V Cryptography Extensions Test\n");
    printf("====================================\n\n");
    
#if __riscv_xlen == 64
    printf("Architecture: RV64\n\n");
#else
    printf("Architecture: RV32\n\n");
#endif
    
    test_aes32_instructions();
    printf("\n");
    
    test_aes64_instructions();
    printf("\n");
    
    test_sha256_instructions();
    printf("\n");
    
    test_sha512_instructions();
    printf("\n");
    
    printf("All cryptography instructions tested!\n");
    
    return 0;
}