# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.include "data.s"
.include "rodata.s"
.include "data64_const.s"

.align 16
.section ".text"
    .global run_all_tests
    .global add_insns
    # .global sub_insns
    # .global store_insns
    # .global load_insns

    .type run_all_tests, @function
    .type add_insns, @function
    # .type sub_insns, @function
    # .type store_insns, @function
    # .type load_insns, @function

#
# Instructions which are PC/LR independed below
#

run_all_tests:

add_tests:
    add %l0, 1, %l2
    add %l2, 3, %l2

random_data_tests:

    set random_data_0, %l7

    ld [%l7+0x1c], %l0
    ld [%l7+0x20], %l1
    ld [%l7+0x24], %l2
    ld [%l7+0x28], %l3
    ld [%l7+0x2c], %l4
    ld [%l7+0x30], %l5
    ld [%l7+0x34], %l6

llvm_asm_test_insn:
    add %l0, %l0, %l0
    add %l1, %l2, %l3
    add %l0, %l1, %l0
    add %l0, 10, %l0
    addcc %l1, %l2, %l3
    addxcc %l1, %l2, %l3
    udiv %l1, %l2, %l3
    sdiv %l2, %l3, %l4
    and %l2, %l3, %l4
    andn %l2, %l3, %l4
    or %l2, %l3, %l4
    orn %l2, %l3, %l4
    xor %l2, %l3, %l4
    xnor %l2, %l3, %l4
    umul %l2, %l3, %l4
    smul %l2, %l3, %l4
    nop 
    sethi 10, %l0
    sll %l1, %l2, %l3
    sll %l1, 31, %l3
    srl %l1, %l2, %l3
    srl %l1, 31, %l3
    sra %l1, %l2, %l3
    sra %l1, 31, %l3
    sub %l1, %l2, %l3
    subcc %l1, %l2, %l3
    subxcc %l1, %l2, %l3
    mov %l1, %l2
    mov 0xff, %l3
    umulcc %l1, %l2, %l3
    smulcc %l1, %l2, %l3
    udivcc %l1, %l2, %l3
    sdivcc %l1, %l2, %l3
    andcc %l1, %l2, %l3
    andncc %l1, %l2, %l3
    orcc %l1, %l2, %l3
    orncc %l1, %l2, %l3
    xorcc %l1, %l2, %l3
    xnorcc %l1, %l2, %l3

    fitos %f0, %f4
    fitod %f0, %f4
    fitoq %f0, %f4
    fstoi %f0, %f4
    fdtoi %f0, %f4
    fqtoi %f0, %f4
    fstod %f0, %f4
    fstoq %f0, %f4
    fdtos %f0, %f4
    fdtoq %f0, %f4
    fqtos %f0, %f4
    fqtod %f0, %f4
    fmovs %f0, %f4
    fnegs %f0, %f4
    fabss %f0, %f4
    fsqrts %f0, %f4
    fadds %f0, %f4, %f8
    fsubs %f0, %f4, %f8
    fmuls %f0, %f4, %f8
    fdivs %f0, %f4, %f8

    fcmps %f0, %f4
    fcmpes %f0, %f4

    nop
    nop
    nop
    nop
    nop
    nop

memory_tests:


    xor %g0, %g0, %o0
    xor %g0, %g0, %o1
    xor %g0, %g0, %o2

    set load_b, %l0
    set store_b, %l5

    ldsb [%l0+%g0], %o0
    ldsb [%l0+1], %o1
    ldsb [%l0+2], %o2
    stb %o0, [%l5+%g0]
    stb %o1, [%l5+2]
    stb %o2, [%l5+2]
    xor %g0, %g0, %o0
    xor %g0, %g0, %o1
    xor %g0, %g0, %o2

    ldub [%l0+%g0], %o0
    ldub [%l0+1], %o1
    ldub [%l0+2], %o2
    stb %o0, [%l5+%g0]
    stb %o1, [%l5+2]
    stb %o2, [%l5+2]
    xor %g0, %g0, %o0
    xor %g0, %g0, %o1
    xor %g0, %g0, %o2

    set load_h, %l1
    set store_h, %l5

    ldsh [%l1+%g0], %o0
    ldsh [%l1+2], %o1
    ldsh [%l1+4], %o2
    sth %o0, [%l5+%g0]
    sth %o1, [%l5+2]
    sth %o2, [%l5+4]
    xor %g0, %g0, %o0
    xor %g0, %g0, %o1
    xor %g0, %g0, %o2

    lduh [%l1+%g0], %o0
    lduh [%l1+2], %o1
    lduh [%l1+4], %o2
    sth %o0, [%l5+%g0]
    sth %o1, [%l5+2]
    sth %o2, [%l5+4]
    xor %g0, %g0, %o0
    xor %g0, %g0, %o1
    xor %g0, %g0, %o2

    set load_w, %l2
    set store_w, %l5

    ld [%l2+%g0], %o0
    ld [%l2+4], %o1
    ld [%l2+8], %o2
    st %o0, [%l5+%g0]
    st %o1, [%l5+4]
    st %o2, [%l5+8]
    xor %g0, %g0, %o0
    xor %g0, %g0, %o1
    xor %g0, %g0, %o2

    ld [%l2+%g0], %o0
    ld [%l2+4], %o1
    ld [%l2+8], %o2
    st %o0, [%l5+%g0]
    st %o1, [%l5+4]
    st %o2, [%l5+8]
    xor %g0, %g0, %o0
    xor %g0, %g0, %o1
    xor %g0, %g0, %o2

    set load_d, %l3
    set store_d, %l5

    ldd [%l3+%g0], %o0
    ldd [%l3+8], %o2
    ldd [%l3+16], %o4
    std %o0, [%l5+%g0]
    std %o2, [%l5+8]
    std %o4, [%l5+16]
    xor %g0, %g0, %o0
    xor %g0, %g0, %o1
    xor %g0, %g0, %o2

    set random_data_1_rw, %l4
    set random_data_1_rw, %l5
    set 0x10, %l6

    swap [%l4+%l6], %l4
    swap [%l5+32], %l5

    mulscc %l5, %l4, %l3
    mulscc %l4, %l3, %l3
    mulscc %l3, %l2, %l3
    mulscc %l2, %l1, %l3

    nop
    nop
    nop
    nop
    nop
    nop

    # Unsupported by QEMU
    # umulxhi %l1, %l2, %l3
    # te %xcc, 0x10
    # tle %icc, %i3
    # wr %i0, %g1, %asr22
    # wr %i0, %g1, %asr25

    wr %i0, %g1, %y

    rd %y, %i0

    # Correct loading order
    set load_zero8, %o0
    set store_q, %o1
    lduh [%o0], %l2
    sth %l2, [%o1]
    set load_neg_one8, %o0
    lduh [%o0], %l0
    sth %l0, [%o1]

    set load_zero16, %o0
    set store_q, %o1
    ld [%o0], %l2
    st %l2, [%o1]
    set load_neg_one16, %o0
    ld [%o0], %l0
    st %l0, [%o1]

    set load_zero32, %o0
    set store_q, %o1
    ldd [%o0], %f0
    std %f0, [%o1]
    set load_neg_one32, %o0
    ldd [%o0], %f0
    std %f0, [%o1]

    set load_zero64, %o0
    ld [%o0], %f0
    ldd [%o0], %f16

    set load_one32, %o0
    ld [%o0], %f1
    fitos %f1, %f1

    set load_two32, %o0
    ld [%o0], %f2
    fitos %f2, %f2

    set load_three32, %o0
    ld [%o0], %f3
    fitos %f3, %f3

    # NaN
    fdivs %f0, %f0, %f4

    fsqrts %f2, %f8

    fsqrts %f3, %f9

    nop
    nop
    nop
    nop
    nop
    nop

add_carry:
    set load_neg_one64, %i0
    set load_one64, %i1
    ldd [%i0], %l0
    ldd [%i1], %l2
    # Set carry
    addcc %l0, %l2, %l4
    # Should set carry as well.
    addxcc %l0, %l0, %l4
    # Set carry
    subcc %l0, %l0, %l4
    # Should set carry as well.
    subxcc %l0, %l0, %l4

done:
    ret
    nop
