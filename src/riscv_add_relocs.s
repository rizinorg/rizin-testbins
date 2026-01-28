# Test file for RISC-V ADD/SUB relocations
# This file forces the assembler to generate relocations using .reloc directives

.global _start
_start:
.L0:
  ret           # 4 bytes
  nop           # 4 bytes
  nop           # 4 bytes
.L1:
  ret           # 4 bytes
.L2:

# Expected values:
# .L1 - .L0 = 12 (0x0c)
# .L2 - .L0 = 16 (0x10)
# .L2 - .L1 = 4  (0x04)

.section .rodata
.align 3

# Test 1: 64-bit ADD/SUB (.L1 - .L0 = 12)
test_64bit_1:
.reloc ., R_RISCV_ADD64, .L1
.reloc ., R_RISCV_SUB64, .L0
.quad 0

# Test 2: 32-bit ADD/SUB (.L1 - .L0 = 12)
test_32bit_1:
.reloc ., R_RISCV_ADD32, .L1
.reloc ., R_RISCV_SUB32, .L0
.word 0

# Test 3: 16-bit ADD/SUB (.L1 - .L0 = 12)
test_16bit_1:
.reloc ., R_RISCV_ADD16, .L1
.reloc ., R_RISCV_SUB16, .L0
.half 0

# Test 4: 8-bit ADD/SUB (.L1 - .L0 = 12)
test_8bit_1:
.reloc ., R_RISCV_ADD8, .L1
.reloc ., R_RISCV_SUB8, .L0
.byte 0

# Test 5: 64-bit ADD/SUB (.L2 - .L1 = 4)
.align 3
test_64bit_2:
.reloc ., R_RISCV_ADD64, .L2
.reloc ., R_RISCV_SUB64, .L1
.quad 0

# Test 6: 32-bit ADD/SUB (.L2 - .L1 = 4)
test_32bit_2:
.reloc ., R_RISCV_ADD32, .L2
.reloc ., R_RISCV_SUB32, .L1
.word 0

# Test 7: 16-bit ADD/SUB (.L2 - .L0 = 16)
test_16bit_2:
.reloc ., R_RISCV_ADD16, .L2
.reloc ., R_RISCV_SUB16, .L0
.half 0

# Test 8: 8-bit ADD/SUB (.L2 - .L1 = 4)
test_8bit_2:
.reloc ., R_RISCV_ADD8, .L2
.reloc ., R_RISCV_SUB8, .L1
.byte 0

# Debug section test
.section .debug_info
.reloc ., R_RISCV_ADD64, .L2
.reloc ., R_RISCV_SUB64, .L0
.quad 0
