// Test forward branch at +4094 bytes (maximum forward range)
int test_forward_max(int x) {
    // 4 bytes
    if (x == 0) goto target;
    
    // Need 4094 bytes of padding
    // c.nop is 2 bytes, so we need 2047 nops
    __asm__ volatile (
        ".rept 2045\n"  // 2045 * 2 + 4 = 4090 + 4 = 4094 bytes
        "nop\n"
        ".endr\n"
    );
    
target:
    return 1;
}

// Test forward branch at +4096 bytes (beyond maximum)
int test_forward_over(int x) {
    // 4 bytes
    if (x == 0) goto target;
    
    // 4096 bytes (should exceed B-type range)
    __asm__ volatile (
        ".rept 2046\n"  // 2046 * 2 + 4 = 4092 + 4 = 4096 bytes
        "nop\n"
        ".endr\n"
    );
    
target:
    return 2;
}

// Test backward branch at -4096 bytes (maximum backward range)
int test_backward_max(int x) {
loop_start:
    __asm__ volatile (
        ".rept 2048\n"  // 2048 * 2 = 4096 bytes
        "nop\n"
        ".endr\n"
    );
    
    if (x != 0) goto loop_start;
    
    return 3;
}

// Test backward branch beyond maximum
int test_backward_over(int x) {
loop_start:
    __asm__ volatile (
        ".rept 2049\n"  // 2049 * 2 = 4098 bytes
        "nop\n"
        ".endr\n"
    );
    
    if (x != 0) goto loop_start;
    
    return 4;
}
