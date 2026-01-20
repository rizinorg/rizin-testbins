/*
 * Freestanding C code with explicit RISC-V CM.PUSH and CM.POP instructions
 * Using .insn directive for Clang compatibility
 * 
 * Compile with Clang:
 * clang --target=riscv64 -march=rv64ima_zcmp -mabi=lp64 -O2 -ffreestanding -nostdlib -nostartfiles --gcc-toolchain=/opt/riscv --sysroot=/opt/riscv/sysroot -fuse-ld=lld -o output.elf
 */

typedef unsigned int uint32_t;
typedef unsigned long uint64_t;

volatile uint32_t global_var = 0;

/*
 * CM.PUSH encodings (using .insn directive):
 * cm.push {ra, s0-s1}, -16  -> .insn cr 0xa002, 5, 8
 * cm.pop {ra, s0-s1}, 16    -> .insn cr 0xba02, 5, 8
 * 
 * For now, let's use a simpler approach - raw instruction bytes
 */

/*
 * Function using explicit CM.PUSH and CM.POP via raw encoding
 */
uint32_t explicit_cm_push_pop(uint32_t a, uint32_t b) {
    uint32_t result;
    
    __asm__ volatile (
        ".2byte 0xb8a2\n\t"  // cm.push {ra, s0-s1}, -16
        "mv s0, %1\n\t"
        "mv s1, %2\n\t"
        "add s0, s0, s1\n\t"
        "mv %0, s0\n\t"
        ".2byte 0xbaa2\n\t"  // cm.pop {ra, s0-s1}, 16
        : "=r" (result)
        : "r" (a), "r" (b)
        : "s0", "s1", "memory"
    );
    
    return result;
}

/*
 * Function with CM.PUSH/POP of more registers  
 */
uint32_t cm_push_pop_many_regs(uint32_t a, uint32_t b, uint32_t c) {
    uint32_t result;
    
    __asm__ volatile (
        ".2byte 0xb8b2\n\t"  // cm.push {ra, s0-s5}, -48
        "mv s0, %1\n\t"
        "mv s1, %2\n\t"
        "mv s2, %3\n\t"
        "add s3, s0, s1\n\t"
        "add s4, s1, s2\n\t"
        "add s5, s3, s4\n\t"
        "mv %0, s5\n\t"
        ".2byte 0xbab2\n\t"  // cm.pop {ra, s0-s5}, 48
        : "=r" (result)
        : "r" (a), "r" (b), "r" (c)
        : "s0", "s1", "s2", "s3", "s4", "s5", "memory"
    );
    
    return result;
}

/*
 * Function demonstrating CM.PUSH with all saved registers
 */
uint32_t cm_push_pop_all_saved(uint32_t seed) {
    uint32_t result;
    
    __asm__ volatile (
        ".2byte 0xb8be\n\t"  // cm.push {ra, s0-s11}, -96
        "mv s0, %1\n\t"
        "addi s1, s0, 1\n\t"
        "addi s2, s0, 2\n\t"
        "addi s3, s0, 3\n\t"
        "addi s4, s0, 4\n\t"
        "addi s5, s0, 5\n\t"
        "addi s6, s0, 6\n\t"
        "addi s7, s0, 7\n\t"
        "addi s8, s0, 8\n\t"
        "addi s9, s0, 9\n\t"
        "addi s10, s0, 10\n\t"
        "addi s11, s0, 11\n\t"
        "add s0, s0, s1\n\t"
        "add s0, s0, s2\n\t"
        "add s0, s0, s3\n\t"
        "add s0, s0, s4\n\t"
        "add s0, s0, s5\n\t"
        "add s0, s0, s6\n\t"
        "add s0, s0, s7\n\t"
        "add s0, s0, s8\n\t"
        "add s0, s0, s9\n\t"
        "add s0, s0, s10\n\t"
        "add s0, s0, s11\n\t"
        "mv %0, s0\n\t"
        ".2byte 0xbabe\n\t"  // cm.pop {ra, s0-s11}, 96
        : "=r" (result)
        : "r" (seed)
        : "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7",
          "s8", "s9", "s10", "s11", "memory"
    );
    
    return result;
}

/*
 * Function showing CM.POPRET
 */
uint32_t cm_popret_example(uint32_t a, uint32_t b) {
    uint32_t result;
    
    __asm__ volatile (
        ".2byte 0xb8a2\n\t"  // cm.push {ra, s0-s1}, -16
        "mv s0, %1\n\t"
        "mv s1, %2\n\t"
        "mul s0, s0, s1\n\t"
        "mv a0, s0\n\t"
        ".2byte 0xbea2\n\t"  // cm.popret {ra, s0-s1}, 16
        : "=r" (result)
        : "r" (a), "r" (b)
        : "s0", "s1", "a0", "memory"
    );
    
    return result;
}

/*
 * Function showing CM.POPRETZ
 */
void cm_popretz_example(uint32_t *ptr, uint32_t val) {
    __asm__ volatile (
        ".2byte 0xb8a2\n\t"  // cm.push {ra, s0-s1}, -16
        "mv s0, %0\n\t"
        "mv s1, %1\n\t"
        "sw s1, 0(s0)\n\t"
        ".2byte 0xbca2\n\t"  // cm.popretz {ra, s0-s1}, 16
        :
        : "r" (ptr), "r" (val)
        : "s0", "s1", "memory"
    );
}

/*
 * Demonstrate CM.PUSH with just ra
 */
uint32_t cm_push_ra_only(uint32_t x) {
    uint32_t result;
    
    __asm__ volatile (
        ".2byte 0xb882\n\t"  // cm.push {ra}, -16
        "slli a0, %1, 2\n\t"
        "addi a0, a0, 10\n\t"
        "mv %0, a0\n\t"
        ".2byte 0xba82\n\t"  // cm.pop {ra}, 16
        : "=r" (result)
        : "r" (x)
        : "a0", "memory"
    );
    
    return result;
}

void _start(void) {
    uint32_t result = 0;
    uint32_t temp = 0;
    
    // Test explicit CM.PUSH/POP functions
    result += explicit_cm_push_pop(10, 20);
    result += cm_push_pop_many_regs(5, 10, 15);
    result += cm_push_pop_all_saved(100);
    result += cm_popret_example(3, 4);
    result += cm_push_ra_only(50);
    
    // Test cm.popretz
    cm_popretz_example(&temp, 42);
    result += temp;
    
    // Store result
    global_var = result;
    
    // Halt
    while(1) {
        __asm__ volatile ("wfi");
    }
}
