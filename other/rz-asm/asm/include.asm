.arch x86
.bits 32
.include bins/other/rz-asm/asm/inc_test.asm

mov ebx, 0
int 0x80
ret
