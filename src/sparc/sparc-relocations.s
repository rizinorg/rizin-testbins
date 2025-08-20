.align 16
.section ".text"

.global test_sym

test_sym:
nop
nop
nop

call foo
or %g1, %lo(test_sym), %g3
sethi %hi(test_sym), %l0
sethi %h44(test_sym), %l0
or %g1, %m44(test_sym), %g3
or %g1, %l44(test_sym), %g3
sethi %hh(test_sym), %l0
or %g1, %hm(test_sym), %g3
sethi %lm(test_sym), %l0
or %g1, test_sym, %g3
or %g1, (test_sym+4), %g3
sethi %hix(test_sym), %g1
xor %g1, %lox(test_sym), %g1
# See https://docs.oracle.com/cd/E53394_01/html/E54833/gpvxz.html
# for an explanation of GOT patching.
sethi %gdop_hix22(foo), %l1
or %l1, %gdop_lox10(foo), %l1
ldx [%l7 + %l1], %l2, %gdop(foo)

.align 16
.section ".got"
.xword test_sym
.xword foo

.section ".rodata"
.align 16
.byte test_sym
.align 16
.half test_sym
.align 16
.word test_sym
.align 16
.xword test_sym

