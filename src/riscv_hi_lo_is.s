.option norelax
.global _start
_start:
  lui a0, %hi(foo)
  addi a0, a0, %lo(foo)
  lw a0, %lo(foo)(a0)
  sw a0, %lo(foo)(a0)
  lui a0, %hi(bar)
  addi a0, a0, %lo(bar)
  lb a0, %lo(bar)(a0)
  sb a0, %lo(bar)(a0)
  lui a0, %hi(norelax)
  addi a0, a0, %lo(norelax)
  lw a0, %lo(norelax)(a0)
  sw a0, %lo(norelax)(a0)
  lui a0, %hi(undefined_weak)
  addi a0, a0, %lo(undefined_weak)
  lw a0, %lo(undefined_weak)(a0)
  sw a0, %lo(undefined_weak)(a0)
  lui a0, %hi(baz)
  addi a0, a0, %lo(baz)
  lw a0, %lo(baz)(a0)
  sw a0, %lo(baz)(a0)
a:
  addi a0, a0, 1

.section .sdata,"aw"
foo:
  .word 0
  .space 4091
bar:
  .byte 0
norelax:
  .word 0
.weak undefined_weak
