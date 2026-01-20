#include <stdint.h>
#include <stdio.h>

/* Rotation functions - natural C patterns that compilers recognize */

uint32_t rotate_left_8(uint32_t x) {
    return (x << 8) | (x >> 24);  // Should generate rori or rol
}

uint32_t rotate_right_12(uint32_t x) {
    return (x >> 12) | (x << 20);  // Should generate rori
}

uint32_t rotate_left_var(uint32_t x, unsigned int n) {
    n &= 31;
    return (x << n) | (x >> (32 - n));  // Should generate rol
}

uint32_t rotate_right_var(uint32_t x, unsigned int n) {
    n &= 31;
    return (x >> n) | (x << (32 - n));  // Should generate ror
}

uint64_t rotate_left_64(uint64_t x, unsigned int n) {
    n &= 63;
    return (x << n) | (x >> (64 - n));  // Should generate rol (64-bit)
}

uint64_t rotate_right_64(uint64_t x, unsigned int n) {
    n &= 63;
    return (x >> n) | (x << (64 - n));  // Should generate ror (64-bit)
}

/* 32-bit operations on 64-bit (should generate W variants on RV64) */

uint32_t rotate_right_32on64(uint32_t x, unsigned int n) {
    n &= 31;
    return (x >> n) | (x << (32 - n));  // Should generate rorw on RV64
}

uint32_t rotate_left_16_32bit(uint32_t x) {
    return (x << 16) | (x >> 16);  // Should generate roriw on RV64
}

/* Bit set operations - natural patterns */

uint32_t set_bit_5(uint32_t x) {
    return x | (1u << 5);  // Should generate bseti
}

uint32_t set_bit_var(uint32_t x, unsigned int bit) {
    return x | (1u << bit);  // Should generate bset
}

uint64_t set_bit_40(uint64_t x) {
    return x | (1ull << 40);  // Should generate bseti (64-bit)
}

/* Bit clear operations */

uint32_t clear_bit_7(uint32_t x) {
    return x & ~(1u << 7);  // Should generate bclri
}

uint32_t clear_bit_var(uint32_t x, unsigned int bit) {
    return x & ~(1u << bit);  // Should generate bclr
}

uint64_t clear_bit_50(uint64_t x) {
    return x & ~(1ull << 50);  // Should generate bclri (64-bit)
}

/* Bit invert/toggle operations */

uint32_t toggle_bit_3(uint32_t x) {
    return x ^ (1u << 3);  // Should generate binvi
}

uint32_t toggle_bit_var(uint32_t x, unsigned int bit) {
    return x ^ (1u << bit);  // Should generate binv
}

uint64_t toggle_bit_35(uint64_t x) {
    return x ^ (1ull << 35);  // Should generate binvi (64-bit)
}

/* Bit extract/test operations */

uint32_t extract_bit_9(uint32_t x) {
    return (x >> 9) & 1;  // Should generate bexti
}

uint32_t extract_bit_var(uint32_t x, unsigned int bit) {
    return (x >> bit) & 1;  // Should generate bext
}

uint64_t extract_bit_45(uint64_t x) {
    return (x >> 45) & 1;  // Should generate bexti (64-bit)
}

/* Byte reversal for endian conversion */

uint32_t swap_endian_32(uint32_t x) {
    return ((x & 0xFF000000) >> 24) |
           ((x & 0x00FF0000) >> 8)  |
           ((x & 0x0000FF00) << 8)  |
           ((x & 0x000000FF) << 24);  // Should generate rev8
}

uint64_t swap_endian_64(uint64_t x) {
    return ((x & 0xFF00000000000000ull) >> 56) |
           ((x & 0x00FF000000000000ull) >> 40) |
           ((x & 0x0000FF0000000000ull) >> 24) |
           ((x & 0x000000FF00000000ull) >> 8)  |
           ((x & 0x00000000FF000000ull) << 8)  |
           ((x & 0x0000000000FF0000ull) << 24) |
           ((x & 0x000000000000FF00ull) << 40) |
           ((x & 0x00000000000000FFull) << 56);  // Should generate rev8
}

/* Alternative byte swap patterns */

uint32_t bswap32_alt(uint32_t x) {
    x = ((x << 8) & 0xFF00FF00) | ((x >> 8) & 0x00FF00FF);
    x = (x << 16) | (x >> 16);
    return x;  // May also generate rev8
}

/* Multi-bit operations that should still use single instructions */

uint32_t set_multiple_known_bits(uint32_t x) {
    x = x | (1u << 2);   // bseti
    x = x | (1u << 7);   // bseti
    x = x | (1u << 15);  // bseti
    return x;
}

uint32_t clear_multiple_known_bits(uint32_t x) {
    x = x & ~(1u << 4);   // bclri
    x = x & ~(1u << 11);  // bclri
    x = x & ~(1u << 20);  // bclri
    return x;
}

/* Practical use cases */

typedef struct {
    uint32_t flags;
} device_register_t;

void enable_device_flag(device_register_t *reg, unsigned int flag_bit) {
    reg->flags = reg->flags | (1u << flag_bit);  // bset
}

void disable_device_flag(device_register_t *reg, unsigned int flag_bit) {
    reg->flags = reg->flags & ~(1u << flag_bit);  // bclr
}

int is_flag_set(device_register_t *reg, unsigned int flag_bit) {
    return (reg->flags >> flag_bit) & 1;  // bext
}

/* Network byte order conversion */

uint32_t network_to_host(uint32_t net_value) {
    return ((net_value & 0xFF000000) >> 24) |
           ((net_value & 0x00FF0000) >> 8)  |
           ((net_value & 0x0000FF00) << 8)  |
           ((net_value & 0x000000FF) << 24);  // rev8
}

uint32_t host_to_network(uint32_t host_value) {
    return ((host_value & 0xFF000000) >> 24) |
           ((host_value & 0x00FF0000) >> 8)  |
           ((host_value & 0x0000FF00) << 8)  |
           ((host_value & 0x000000FF) << 24);  // rev8
}

/* Circular shift for hash functions */

uint32_t hash_rotate(uint32_t value, uint32_t seed) {
    uint32_t rotated = (value << 13) | (value >> 19);  // rori
    return rotated ^ seed;
}

/* Test and demonstration function */

void demonstrate_all_operations(void) {
    uint32_t x32 = 0x12345678;
    uint64_t x64 = 0x123456789ABCDEF0ull;
    
    printf("32-bit rotate left 8:  0x%08X\n", rotate_left_8(x32));
    printf("32-bit rotate right 12: 0x%08X\n", rotate_right_12(x32));
    printf("32-bit rotate left var: 0x%08X\n", rotate_left_var(x32, 7));
    printf("32-bit rotate right var: 0x%08X\n", rotate_right_var(x32, 11));
    
    printf("64-bit rotate left:  0x%016llX\n", (unsigned long long)rotate_left_64(x64, 13));
    printf("64-bit rotate right: 0x%016llX\n", (unsigned long long)rotate_right_64(x64, 21));
    
    printf("Set bit 5:   0x%08X\n", set_bit_5(x32));
    printf("Set bit var: 0x%08X\n", set_bit_var(x32, 10));
    printf("Clear bit 7: 0x%08X\n", clear_bit_7(x32));
    printf("Clear bit var: 0x%08X\n", clear_bit_var(x32, 12));
    printf("Toggle bit 3: 0x%08X\n", toggle_bit_3(x32));
    printf("Toggle bit var: 0x%08X\n", toggle_bit_var(x32, 15));
    printf("Extract bit 9: %u\n", extract_bit_9(x32));
    printf("Extract bit var: %u\n", extract_bit_var(x32, 20));
    
    printf("Swap endian 32: 0x%08X\n", swap_endian_32(x32));
    printf("Swap endian 64: 0x%016llX\n", (unsigned long long)swap_endian_64(x64));
    
    printf("Network to host: 0x%08X\n", network_to_host(0xAABBCCDD));
    printf("Hash rotate: 0x%08X\n", hash_rotate(x32, 0xDEADBEEF));
    
    device_register_t reg = {0};
    enable_device_flag(&reg, 5);
    enable_device_flag(&reg, 12);
    printf("Device flags after enable: 0x%08X\n", reg.flags);
    printf("Is flag 5 set? %d\n", is_flag_set(&reg, 5));
    printf("Is flag 7 set? %d\n", is_flag_set(&reg, 7));
    disable_device_flag(&reg, 5);
    printf("Device flags after disable: 0x%08X\n", reg.flags);
}

int main(void) {
    demonstrate_all_operations();
    return 0;
}
