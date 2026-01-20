.global _start

_start:
    .reloc ., R_RISCV_JAL, foo
    jal x0, 0
    .reloc ., R_RISCV_JAL, bar
    jal x1, 0

.set foo, _start+0xffffe
.set bar, _start+4-0x100000

