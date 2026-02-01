.section .text
.org 0x100000          # Start at 1 MiB

.global _start

_start:
    .reloc ., R_RISCV_JAL, foo
    jal x0, 0
    .reloc ., R_RISCV_JAL, bar
    jal x1, 0

.set foo, _start+0xffffe      # Just under +1 MiB from _start
.set bar, _start+4-0x100000   # Just under -1 MiB from _start+4

