.include "data64_const.s"
.section ".data"
value_load_label_0:
.xword 0
value_load_label_1:
.xword 1
value_load_label_2:
.xword 2
value_load_label_neg1:
.xword -1
value_load_label_max_unsigned:
.xword 0xFFFFFFFFFFFFFFFF
value_load_label_max_signed:
.xword 0x7FFFFFFFFFFFFFFF
value_load_label_10:
.xword 10
value_load_label_max:
.xword 0x7FFFFFFFFFFFFFFF
value_load_label_32:
.xword 32
value_load_label_64:
.xword 64

.section ".text"
.global ai_tests

ai_tests:
    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l0
    add %l0, %l0, %l1

    set value_load_label_0, %i0
    ldd [%i0], %l0
    add %l0, %l0, %l1

    set value_load_label_neg1, %i0
    ldd [%i0], %l0
    add %l0, %l0, %l1

    set value_load_label_max, %i0
    ldd [%i0], %l0
    add %l0, 10, %l1

    set value_load_label_neg1, %i0
    ldd [%i0], %l0
    addcc %l0, %l0, %l1
    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l0
    addcc %l0, %l0, %l1

    set value_load_label_0, %i0
    ldd [%i0], %l0
    addcc %l0, %l0, %l1

    set value_load_label_neg1, %i0
    ldd [%i0], %l0
    addcc %l0, %l0, %l1

    set value_load_label_max_signed, %i0
    ldd [%i0], %l0
    addcc %l0, 10, %l1

    set value_load_label_neg1, %i0
    ldd [%i0], %l0
    addxcc %l0, %l0, %l1
    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l0
    udiv %l0, %l0, %l1

    set value_load_label_neg1, %i0
    ldd [%i0], %l0
    udiv %l0, %l0, %l1

    set value_load_label_max_signed, %i0
    ldd [%i0], %l0
    udiv %l0, 1, %l1

    set value_load_label_10, %i0
    ldd [%i0], %l0
    udiv %l0, 10, %l1
    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l0
    sdiv %l0, %l0, %l1

    set value_load_label_neg1, %i0
    ldd [%i0], %l0
    sdiv %l0, %l0, %l1

    set value_load_label_max_signed, %i0
    ldd [%i0], %l0
    sdiv %l0, 1, %l1

    set value_load_label_10, %i0
    ldd [%i0], %l0
    sdiv %l0, 10, %l1
    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l0
    and %l0, %l0, %l1

    set value_load_label_0, %i0
    ldd [%i0], %l0
    and %l0, %l0, %l1

    set value_load_label_neg1, %i0
    ldd [%i0], %l0
    and %l0, %l0, %l1

    set value_load_label_max_signed, %i0
    ldd [%i0], %l0
    and %l0, 0, %l1

    set value_load_label_10, %i0
    ldd [%i0], %l0
    and %l0, 10, %l1
    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l0
    andn %l0, %l0, %l1

    set value_load_label_0, %i0
    ldd [%i0], %l0
    andn %l0, %l0, %l1

    set value_load_label_neg1, %i0
    ldd [%i0], %l0
    andn %l0, %l0, %l1

    set value_load_label_max_signed, %i0
    ldd [%i0], %l0
    andn %l0, 0, %l1

    set value_load_label_10, %i0
    ldd [%i0], %l0
    andn %l0, 10, %l1
    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l0
    or %l0, %l0, %l1

    set value_load_label_0, %i0
    ldd [%i0], %l0
    or %l0, %l0, %l1

    set value_load_label_neg1, %i0
    ldd [%i0], %l0
    or %l0, %l0, %l1

    set value_load_label_max_signed, %i0
    ldd [%i0], %l0
    or %l0, 0, %l1

    set value_load_label_10, %i0
    ldd [%i0], %l0
    or %l0, 10, %l1
    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l0
    orn %l0, %l0, %l1

    set value_load_label_0, %i0
    ldd [%i0], %l0
    orn %l0, %l0, %l1

    set value_load_label_neg1, %i0
    ldd [%i0], %l0
    orn %l0, %l0, %l1

    set value_load_label_max_signed, %i0
    ldd [%i0], %l0
    orn %l0, 0, %l1

    set value_load_label_10, %i0
    ldd [%i0], %l0
    orn %l0, 10, %l1
    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l0
    xor %l0, %l0, %l1

    set value_load_label_0, %i0
    ldd [%i0], %l0
    xor %l0, %l0, %l1

    set value_load_label_neg1, %i0
    ldd [%i0], %l0
    xor %l0, %l0, %l1

    set value_load_label_max_signed, %i0
    ldd [%i0], %l0
    xor %l0, 0, %l1

    set value_load_label_10, %i0
    ldd [%i0], %l0
    xor %l0, 10, %l1
    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l0
    xnor %l0, %l0, %l1

    set value_load_label_0, %i0
    ldd [%i0], %l0
    xnor %l0, %l0, %l1

    set value_load_label_neg1, %i0
    ldd [%i0], %l0
    xnor %l0, %l0, %l1

    set value_load_label_max_signed, %i0
    ldd [%i0], %l0
    xnor %l0, 0, %l1

    set value_load_label_10, %i0
    ldd [%i0], %l0
    xnor %l0, 10, %l1
    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l0
    umul %l0, %l0, %l1

    set value_load_label_0, %i0
    ldd [%i0], %l0
    umul %l0, %l0, %l1

    set value_load_label_neg1, %i0
    ldd [%i0], %l0
    umul %l0, %l0, %l1

    set value_load_label_max_signed, %i0
    ldd [%i0], %l0
    umul %l0, 1, %l1

    set value_load_label_10, %i0
    ldd [%i0], %l0
    umul %l0, 10, %l1
    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l0
    smul %l0, %l0, %l1

    set value_load_label_0, %i0
    ldd [%i0], %l0
    smul %l0, %l0, %l1

    set value_load_label_neg1, %i0
    ldd [%i0], %l0
    smul %l0, %l0, %l1

    set value_load_label_max_signed, %i0
    ldd [%i0], %l0
    smul %l0, 1, %l1

    set value_load_label_10, %i0
    ldd [%i0], %l0
    smul %l0, 10, %l1
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
# BUG
    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_1, %i0
    ldd [%i0], %l2
    sll %l4, %l2, %l3

    set value_load_label_32, %i0
    ldd [%i0], %l2
    sll %l4, %l2, %l3

    set value_load_label_64, %i0
    ldd [%i0], %l2
    sll %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l2
    sll %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l2
    sll %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_1, %i0
    ldd [%i0], %l2
    srl %l4, %l2, %l3

    set value_load_label_64, %i0
    ldd [%i0], %l2
    srl %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l2
    srl %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l2
    srl %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_1, %i0
    ldd [%i0], %l2
    sra %l4, %l2, %l3

    set value_load_label_32, %i0
    ldd [%i0], %l2
    sra %l4, %l2, %l3

    set value_load_label_64, %i0
    ldd [%i0], %l2
    sra %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l2
    sra %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l2
    sra %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    sub %l4, %l2, %l3

    set value_load_label_neg1, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    sub %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    sub %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    sub %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_neg1, %i0
    ldd [%i0], %l2
    sub %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    subcc %l4, %l2, %l3

    set value_load_label_neg1, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    subcc %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    subcc %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    subcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_neg1, %i0
    ldd [%i0], %l2
    subcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    subxcc %l4, %l2, %l3

    set value_load_label_neg1, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    subxcc %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    subxcc %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    subxcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_neg1, %i0
    ldd [%i0], %l2
    subxcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    addx %l4, %l2, %l3

    set value_load_label_neg1, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    addx %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    addx %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    addx %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_neg1, %i0
    ldd [%i0], %l2
    addx %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    subx %l4, %l2, %l3

    set value_load_label_neg1, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    subx %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    subx %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    subx %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_neg1, %i0
    ldd [%i0], %l2
    subx %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    umulcc %l4, %l2, %l3

    set value_load_label_neg1, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    umulcc %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    umulcc %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    umulcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_neg1, %i0
    ldd [%i0], %l2
    umulcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    smulcc %l4, %l2, %l3

    set value_load_label_neg1, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    smulcc %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    smulcc %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    smulcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_neg1, %i0
    ldd [%i0], %l2
    smulcc %l4, %l2, %l3

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    set load_0x2032, %i0
    ldd [%i0], %l4
    set load_one32, %i0
    ldd [%i0], %l2
    udivcc %l2, %l4, %l6

    set load_max_pos32, %i0
    ldd [%i0], %l4
    set load_one32, %i0
    ldd [%i0], %l2
    udivcc %l4, %l2, %l3

    set load_max_pos32, %i0
    ldd [%i0], %l4
    set load_one32, %i0
    ldd [%i0], %l2
    udivcc %l4, %l2, %l3

    set load_0x2032, %i0
    ldd [%i0], %l4
    set load_two32, %i0
    ldd [%i0], %l2
    udivcc %l4, %l2, %l3

    set load_max_pos32, %i0
    ldd [%i0], %l4
    set load_two32, %i0
    ldd [%i0], %l2
    udivcc %l4, %l2, %l3

    set load_0x2032, %i0
    ldd [%i0], %l4
    set load_one32, %i0
    ldd [%i0], %l2
    sdivcc %l4, %l2, %l3

    set load_max_pos32, %i0
    ldd [%i0], %l4
    set load_one32, %i0
    ldd [%i0], %l2
    sdivcc %l4, %l2, %l3

    set load_0x2032, %i0
    ldd [%i0], %l4
    set load_two32, %i0
    ldd [%i0], %l2
    sdivcc %l4, %l2, %l3

    set load_max_pos32, %i0
    ldd [%i0], %l4
    set load_two32, %i0
    ldd [%i0], %l2
    sdivcc %l4, %l2, %l3

    set load_zero32, %i0
    ldd [%i0], %l4
    set load_neg_one32, %i0
    ldd [%i0], %l2
    sdivcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    andcc %l4, %l2, %l3

    set value_load_label_neg1, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    andcc %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    andcc %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    andcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_neg1, %i0
    ldd [%i0], %l2
    andcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    andncc %l4, %l2, %l3

    set value_load_label_neg1, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    andncc %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    andncc %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    andncc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_neg1, %i0
    ldd [%i0], %l2
    andncc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    orcc %l4, %l2, %l3

    set value_load_label_neg1, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    orcc %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    orcc %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    orcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_neg1, %i0
    ldd [%i0], %l2
    orcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    orncc %l4, %l2, %l3

    set value_load_label_neg1, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    orncc %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    orncc %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    orncc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_neg1, %i0
    ldd [%i0], %l2
    orncc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    xorcc %l4, %l2, %l3

    set value_load_label_neg1, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    xorcc %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    xorcc %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    xorcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_neg1, %i0
    ldd [%i0], %l2
    xorcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    xnorcc %l4, %l2, %l3

    set value_load_label_neg1, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    xnorcc %l4, %l2, %l3

    set value_load_label_max_unsigned, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    xnorcc %l4, %l2, %l3

    set value_load_label_max_signed, %i0
    ldd [%i0], %l4
    set value_load_label_32, %i0
    ldd [%i0], %l2
    xnorcc %l4, %l2, %l3

    set value_load_label_0, %i0
    ldd [%i0], %l4
    set value_load_label_neg1, %i0
    ldd [%i0], %l2
    xnorcc %l4, %l2, %l3

    set load_zero32, %i0
    ldq [%i0], %f0

    fitos %f0, %f4

    set load_one32, %i0
    ldq [%i0], %f0

    fitod %f0, %f4

    set load_two32, %i0
    ldq [%i0], %f0

    fitoq %f0, %f4

    set load_neg_one32, %i0
    ldq [%i0], %f0

    fstoi %f0, %f4

    set load_max_pos32, %i0
    ldq [%i0], %f0

    fdtoi %f0, %f4

    set load_max_neg32, %i0
    ldq [%i0], %f0

    fqtoi %f0, %f4

    set load_zero32, %i0
    ldq [%i0], %f0

    set load_one32, %i0
    ldq [%i0], %f4

    fstod %f0, %f4

    set load_two32, %i0
    ldq [%i0], %f0

    fstoq %f0, %f4

    set load_three32, %i0
    ldq [%i0], %f0

    fdtos %f0, %f4

    set load_max_pos64, %i0
    ldq [%i0], %f0

    fdtoq %f0, %f4

    set load_neg_one64, %i0
    ldq [%i0], %f0

    fqtos %f0, %f4

    set load_zero64, %i0
    ldq [%i0], %f0

    fqtod %f0, %f4

    set load_one64, %i0
    ldq [%i0], %f0

    fmovs %f0, %f4

    set load_two64, %i0
    ldq [%i0], %f0

    fmovd %f0, %f4

    set load_three64, %i0
    ldq [%i0], %f0

    fmovq %f0, %f4

    set load_neg_one32, %i0
    ldq [%i0], %f0

    fnegs %f0, %f4

    set load_one32, %i0
    ldq [%i0], %f0

    fnegd %f0, %f4

    set load_two32, %i0
    ldq [%i0], %f0

    fnegq %f0, %f4

    set load_three32, %i0
    ldq [%i0], %f0

    fabss %f0, %f4

    set load_neg_one32, %i0
    ldq [%i0], %f0

    fabsd %f0, %f4

    set load_two32, %i0
    ldq [%i0], %f0

    fabsq %f0, %f4

    set load_three32, %i0
    ldq [%i0], %f0

    fsqrts %f0, %f4

    set load_max_pos32, %i0
    ldq [%i0], %f0

    fsqrtd %f0, %f4

    set load_max_pos64, %i0
    ldq [%i0], %f0

    fsqrtq %f0, %f4

    set load_one32, %i0
    ldq [%i0], %f0

    set load_two32, %i0
    ldq [%i0], %f4

    fadds %f0, %f4, %f8

    set load_three32, %i0
    ldq [%i0], %f0

    set load_two32, %i0
    ldq [%i0], %f4

    faddd %f0, %f4, %f8

    set load_one32, %i0
    ldq [%i0], %f0

    set load_three32, %i0
    ldq [%i0], %f4

    faddq %f0, %f4, %f8

    set load_zero32, %i0
    ldq [%i0], %f32

    set load_max_pos32, %i0
    ldq [%i0], %f36

    faddd %f32, %f36, %f60

    set load_zero32, %i0
    ldq [%i0], %f32

    set load_two32, %i0
    ldq [%i0], %f36

    faddq %f32, %f36, %f60

    set load_three32, %i0
    ldq [%i0], %f0

    set load_two32, %i0
    ldq [%i0], %f4

    fsubs %f0, %f4, %f8

    set load_one32, %i0
    ldq [%i0], %f0

    set load_two32, %i0
    ldq [%i0], %f4

    fsubd %f0, %f4, %f8

    set load_three32, %i0
    ldq [%i0], %f0

    set load_two32, %i0
    ldq [%i0], %f4

    fsubq %f0, %f4, %f8

    set load_two32, %i0
    ldq [%i0], %f0

    set load_three32, %i0
    ldq [%i0], %f4

    fmuls %f0, %f4, %f8

    set load_one32, %i0
    ldq [%i0], %f0

    set load_three32, %i0
    ldq [%i0], %f4

    fmuld %f0, %f4, %f8

    set load_two32, %i0
    ldq [%i0], %f0

    set load_three32, %i0
    ldq [%i0], %f4

    fmulq %f0, %f4, %f8

    set load_three32, %i0
    ldq [%i0], %f0

    set load_two32, %i0
    ldq [%i0], %f4

    # fsmuld %f0, %f4, %f8

    set load_one32, %i0
    ldq [%i0], %f0

    set load_two32, %i0
    ldq [%i0], %f4

    # fdmulq %f0, %f4, %f8

    set load_three32, %i0
    ldq [%i0], %f0

    set load_two32, %i0
    ldq [%i0], %f4

    fdivs %f0, %f4, %f8

    set load_one32, %i0
    ldq [%i0], %f0

    set load_two32, %i0
    ldq [%i0], %f4

    fdivd %f0, %f4, %f8

    set load_three32, %i0
    ldq [%i0], %f0

    set load_two32, %i0
    ldq [%i0], %f4

    fdivq %f0, %f4, %f8

    set load_zero32, %i0
    ldq [%i0], %f0
    fxtos %f0, %f4
    set load_neg_one32, %i0
    ldq [%i0], %f0
    fxtod %f0, %f4
    set load_max_pos32, %i0
    ldq [%i0], %f0
    fitoq %f0, %f4
    set load_one32, %i0
    ldq [%i0], %f0
    fstoi %f0, %f4
    set load_max_neg32, %i0
    ldq [%i0], %f0
    fdtoi %f0, %f4
    set load_two32, %i0
    ldq [%i0], %f0
    fqtoi %f0, %f4
    set load_zero32, %i0
    ldq [%i0], %f0
    set load_one32, %i0
    ldq [%i0], %f4
    fstod %f0, %f4
    set load_two32, %i0
    ldq [%i0], %f0
    fstoq %f0, %f4
    set load_three32, %i0
    ldq [%i0], %f0
    fdtos %f0, %f4
    set load_max_pos64, %i0
    ldq [%i0], %f0
    fdtoq %f0, %f4
    set load_neg_one64, %i0
    ldq [%i0], %f0
    fqtos %f0, %f4
    set load_zero64, %i0
    ldq [%i0], %f0
    fqtod %f0, %f4
    set load_one64, %i0
    ldq [%i0], %f0
    fmovs %f0, %f4
    set load_two64, %i0
    ldq [%i0], %f0
    fmovd %f0, %f4
    set load_three64, %i0
    ldq [%i0], %f0
    fmovq %f0, %f4
    set load_neg_one32, %i0
    ldq [%i0], %f0
    fnegs %f0, %f4
    set load_one32, %i0
    ldq [%i0], %f0
    fnegd %f0, %f4
    set load_two32, %i0
    ldq [%i0], %f0
    fnegq %f0, %f4
    set load_three32, %i0
    ldq [%i0], %f0
    fabss %f0, %f4
    set load_neg_one32, %i0
    ldq [%i0], %f0
    fabsd %f0, %f4
    set load_two32, %i0
    ldq [%i0], %f0
    fabsq %f0, %f4
    set load_three32, %i0
    ldq [%i0], %f0
    fsqrts %f0, %f4
    set load_max_pos32, %i0
    ldq [%i0], %f0
    fsqrtd %f0, %f4
    set load_max_pos64, %i0
    ldq [%i0], %f0
    fsqrtq %f0, %f4
    set load_one32, %i0
    ldq [%i0], %f0
    set load_two32, %i0
    ldq [%i0], %f4
    fadds %f0, %f4, %f8
    set load_three32, %i0
    ldq [%i0], %f0
    set load_two32, %i0
    ldq [%i0], %f4
    faddd %f0, %f4, %f8
    set load_one32, %i0
    ldq [%i0], %f0
    set load_three32, %i0
    ldq [%i0], %f4
    faddq %f0, %f4, %f8
    set load_zero32, %i0
    ldq [%i0], %f32

    set load_max_pos32, %i0
    ldq [%i0], %f36
    faddd %f32, %f36, %f60
    set load_zero32, %i0
    ldq [%i0], %f32

    set load_two32, %i0
    ldq [%i0], %f36
    faddq %f32, %f36, %f60
    set load_three32, %i0
    ldq [%i0], %f0
    set load_two32, %i0
    ldq [%i0], %f4
    fsubs %f0, %f4, %f8
    set load_one32, %i0
    ldq [%i0], %f0
    set load_two32, %i0
    ldq [%i0], %f4
    fsubd %f0, %f4, %f8
    set load_three32, %i0
    ldq [%i0], %f0
    set load_two32, %i0
    ldq [%i0], %f4
    fsubq %f0, %f4, %f8
    set load_two32, %i0
    ldq [%i0], %f0
    set load_three32, %i0
    ldq [%i0], %f4
    fmuls %f0, %f4, %f8
    set load_one32, %i0
    ldq [%i0], %f0
    set load_three32, %i0
    ldq [%i0], %f4
    fmuld %f0, %f4, %f8
    set load_two32, %i0
    ldq [%i0], %f0
    set load_three32, %i0
    ldq [%i0], %f4
    fmulq %f0, %f4, %f8
    set load_three32, %i0
    ldq [%i0], %f0
    set load_two32, %i0
    ldq [%i0], %f4
    # fsmuld %f0, %f4, %f8
    set load_one32, %i0
    ldq [%i0], %f0
    set load_two32, %i0
    ldq [%i0], %f4
    # fdmulq %f0, %f4, %f8
    set load_three32, %i0
    ldq [%i0], %f0
    set load_two32, %i0
    ldq [%i0], %f4
    fdivs %f0, %f4, %f8
    set load_one32, %i0
    ldq [%i0], %f0
    set load_two32, %i0
    ldq [%i0], %f4
    fdivd %f0, %f4, %f8
    set load_three32, %i0
    ldq [%i0], %f0
    set load_two32, %i0
    ldq [%i0], %f4
    fdivq %f0, %f4, %f8

    ret
    nop
