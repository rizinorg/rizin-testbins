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
    addx %l1, %l2, %l3
    subx %l1, %l2, %l3
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

    # save
    # restore 
    # taddcc %g2, %g1, %g3
    # tsubcc %g2, %g1, %g3
    # taddcctv %g2, %g1, %g3
    # tsubcctv %g2, %g1, %g3
    # membar 15
    # stbar 
    # call %g1+%i2
    # call %o1+8
    # call %g1
    # jmp %g1+%i2
    # jmp %o1+8
    # jmp %g1
    # jmpl %g1+%i2, %g2
    # jmpl %o1+8, %g2
    # jmpl %g1, %g2
    # rett %i7+8
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
    fmovd %f0, %f4
    fmovq %f0, %f4
    fnegs %f0, %f4
    fnegd %f0, %f4
    fnegq %f0, %f4
    fabss %f0, %f4
    fabsd %f0, %f4
    fabsq %f0, %f4
    fsqrts %f0, %f4
    fsqrtd %f0, %f4
    fsqrtq %f0, %f4
    fadds %f0, %f4, %f8
    faddd %f0, %f4, %f8
    faddq %f0, %f4, %f8
    faddd %f32, %f34, %f62
    faddq %f32, %f36, %f60
    fsubs %f0, %f4, %f8
    fsubd %f0, %f4, %f8
    fsubq %f0, %f4, %f8
    fmuls %f0, %f4, %f8
    fmuld %f0, %f4, %f8
    fmulq %f0, %f4, %f8
    fsmuld %f0, %f4, %f8
    fdmulq %f0, %f4, %f8
    fdivs %f0, %f4, %f8
    fdivd %f0, %f4, %f8
    fdivq %f0, %f4, %f8
    fcmps %fcc2, %f0, %f4
    fcmpd %fcc2, %f0, %f4
    fcmpq %fcc2, %f0, %f4
    fcmpes %fcc2, %f0, %f4
    fcmped %fcc2, %f0, %f4
    fcmpeq %fcc2, %f0, %f4
    # FCMP is further tests in sparc64_jmp.s
    # Unsupported by QEMU:
    # flcmpd %fcc1, %f32, %f32
    # flcmpd %fcc1, %f34, %f32
    # flcmpd %fcc1, %f32, %f34
    # flcmpd %fcc1, %f38, %f34
    # flcmpd %fcc1, %f32, %f38
    # flcmpd %fcc1, %f38, %f38
    fxtos %f0, %f4
    fxtod %f0, %f4
    fxtoq %f0, %f4
    fstox %f0, %f4
    fdtox %f0, %f4
    fqtox %f0, %f4

    fzeros %f31
    sllx %l1, %l2, %l0
    sllx %l1, 63, %l0
    srlx %l1, %l2, %l0
    srlx %l1, 63, %l0
    srax %l1, %l2, %l0
    srax %l1, 63, %l0
    mulx %l1, %l2, %l0
    mulx %l1, 63, %l0
    sdivx %l1, %l2, %l0
    sdivx %l1, 63, %l0
    udivx %l1, %l2, %l0
    udivx %l1, 63, %l0
    movne %icc, %l1, %l2
    move %icc, %l1, %l2
    movg %icc, %l1, %l2
    movle %icc, %l1, %l2
    movge %icc, %l1, %l2
    movl %icc, %l1, %l2
    movgu %icc, %l1, %l2
    movleu %icc, %l1, %l2
    movcc %icc, %l1, %l2
    movcs %icc, %l1, %l2
    movpos %icc, %l1, %l2
    movneg %icc, %l1, %l2
    movvc %icc, %l1, %l2
    movvs %icc, %l1, %l2
    movne %xcc, %l1, %l2
    move %xcc, %l1, %l2
    movg %xcc, %l1, %l2
    movle %xcc, %l1, %l2
    movge %xcc, %l1, %l2
    movl %xcc, %l1, %l2
    movgu %xcc, %l1, %l2
    movleu %xcc, %l1, %l2
    movcc %xcc, %l1, %l2
    movcs %xcc, %l1, %l2
    movpos %xcc, %l1, %l2
    movneg %xcc, %l1, %l2
    movvc %xcc, %l1, %l2
    movvs %xcc, %l1, %l2
    movu %fcc0, %l1, %l2
    movg %fcc0, %l1, %l2
    movug %fcc0, %l1, %l2
    movl %fcc0, %l1, %l2
    movul %fcc0, %l1, %l2
    movlg %fcc0, %l1, %l2
    movne %fcc0, %l1, %l2
    move %fcc0, %l1, %l2
    movue %fcc0, %l1, %l2
    movge %fcc0, %l1, %l2
    movuge %fcc0, %l1, %l2
    movle %fcc0, %l1, %l2
    movule %fcc0, %l1, %l2
    movo %fcc0, %l1, %l2
    fmovsne %icc, %f1, %f2
    fmovse %icc, %f1, %f2
    fmovsg %icc, %f1, %f2
    fmovsle %icc, %f1, %f2
    fmovsge %icc, %f1, %f2
    fmovsl %icc, %f1, %f2
    fmovsgu %icc, %f1, %f2
    fmovsleu %icc, %f1, %f2
    fmovscc %icc, %f1, %f2
    fmovscs %icc, %f1, %f2
    fmovspos %icc, %f1, %f2
    fmovsneg %icc, %f1, %f2
    fmovsvc %icc, %f1, %f2
    fmovsvs %icc, %f1, %f2
    fmovsne %xcc, %f1, %f2
    fmovse %xcc, %f1, %f2
    fmovsg %xcc, %f1, %f2
    fmovsle %xcc, %f1, %f2
    fmovsge %xcc, %f1, %f2
    fmovsl %xcc, %f1, %f2
    fmovsgu %xcc, %f1, %f2
    fmovsleu %xcc, %f1, %f2
    fmovscc %xcc, %f1, %f2
    fmovscs %xcc, %f1, %f2
    fmovspos %xcc, %f1, %f2
    fmovsneg %xcc, %f1, %f2
    fmovsvc %xcc, %f1, %f2
    fmovsvs %xcc, %f1, %f2
    fmovsu %fcc0, %f1, %f2
    fmovsg %fcc0, %f1, %f2
    fmovsug %fcc0, %f1, %f2
    fmovsl %fcc0, %f1, %f2
    fmovsul %fcc0, %f1, %f2
    fmovslg %fcc0, %f1, %f2
    fmovsne %fcc0, %f1, %f2
    fmovse %fcc0, %f1, %f2
    fmovsue %fcc0, %f1, %f2
    fmovsge %fcc0, %f1, %f2
    fmovsuge %fcc0, %f1, %f2
    fmovsle %fcc0, %f1, %f2
    fmovsule %fcc0, %f1, %f2
    fmovso %fcc0, %f1, %f2
    movu %fcc1, %l1, %l2
    fmovsg %fcc2, %f1, %f2
    movrz %l1, %l2, %l3
    movrlez %l1, %l2, %l3
    movrlz %l1, %l2, %l3
    movrnz %l1, %l2, %l3
    movrgz %l1, %l2, %l3
    movrgez %l1, %l2, %l3
    fmovrsz %l1, %f2, %f3
    fmovrslez %l1, %f2, %f3
    fmovrslz %l1, %f2, %f3
    fmovrsnz %l1, %f2, %f3
    fmovrsgz %l1, %f2, %f3
    fmovrsgez %l1, %f2, %f3
    # te %xcc, %g0 + 3
    fcmps %f0, %f4
    fcmpd %f32, %f34
    fcmpq %f32, %f40
    fcmpes %f0, %f4
    fcmped %f58, %f60
    fcmpeq %f40, %f48

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

    ldsw [%l2+%g0], %o0
    ldsw [%l2+4], %o1
    ldsw [%l2+8], %o2
    stw %o0, [%l5+%g0]
    stw %o1, [%l5+4]
    stw %o2, [%l5+8]
    xor %g0, %g0, %o0
    xor %g0, %g0, %o1
    xor %g0, %g0, %o2

    lduw [%l2+%g0], %o0
    lduw [%l2+4], %o1
    lduw [%l2+8], %o2
    stw %o0, [%l5+%g0]
    stw %o1, [%l5+4]
    stw %o2, [%l5+8]
    xor %g0, %g0, %o0
    xor %g0, %g0, %o1
    xor %g0, %g0, %o2

    set load_d, %l3
    set store_d, %l5

    ldx [%l3+%g0], %o0
    ldx [%l3+8], %o2
    ldx [%l3+16], %o4
    st %o0, [%l5+%g0]
    st %o2, [%l5+8]
    st %o4, [%l5+16]
    ld [%l3+%g0], %o0
    ld [%l3+8], %o2
    ld [%l3+16], %o4
    std %o0, [%l5+%g0]
    std %o2, [%l5+8]
    std %o4, [%l5+16]
    xor %g0, %g0, %o0
    xor %g0, %g0, %o1
    xor %g0, %g0, %o2

    set load_q, %l4
    set store_q, %l5

    ldq [%l4+%g0], %f0
    ldq [%l4+16], %f8
    ldq [%l4+32], %f32
    stq %f0, [%l5+%g0]
    stq %f8, [%l5+64]
    stq %f32, [%l5+128]

    set random_data_1_rw, %l4
    set random_data_1_rw, %l5
    set 0x10, %l6

    swap [%l4+%l6], %l4
    swap [%l5+32], %l5

    set load_d_rw, %l4
    ldx [%l4], %l5
    set 0x0, %l0
    cas [%l4], %l5, %l0

    set load_d_rw, %l4
    ldx [%l4+8], %l5
    set 0x0, %l0
    casx [%l4], %l5, %l0

    # Not implemented by QEMU
    # set random_data_0, %l0
    # ldx [%l0], %l1
    # ldx [%l0+8], %l2
    # ldx [%l0+16], %l3
    # cmask8 %l1
    # cmask16 %l2
    # cmask32 %l3

test_edge:

    set 0x00, %l0
    set 0x01, %l1
    edge8 %l0, %l1, %l5
    edge8l %l0, %l1, %l5
    edge8ln %l0, %l1, %l5
    edge8n %l0, %l1, %l5

    set 0x01, %l0
    set 0x02, %l1
    edge8 %l0, %l1, %l5
    edge8l %l0, %l1, %l5
    edge8ln %l0, %l1, %l5
    edge8n %l0, %l1, %l5

    set 0x02, %l0
    set 0x03, %l1
    edge8 %l0, %l1, %l5
    edge8l %l0, %l1, %l5
    edge8ln %l0, %l1, %l5
    edge8n %l0, %l1, %l5

    set 0x03, %l0
    set 0x04, %l1
    edge8 %l0, %l1, %l5
    edge8l %l0, %l1, %l5
    edge8ln %l0, %l1, %l5
    edge8n %l0, %l1, %l5

    set 0x04, %l0
    set 0x05, %l1
    edge8 %l0, %l1, %l5
    edge8l %l0, %l1, %l5
    edge8ln %l0, %l1, %l5
    edge8n %l0, %l1, %l5

    set 0x05, %l0
    set 0x06, %l1
    edge8 %l0, %l1, %l5
    edge8l %l0, %l1, %l5
    edge8ln %l0, %l1, %l5
    edge8n %l0, %l1, %l5

    set 0x06, %l0
    set 0x07, %l1
    edge8 %l0, %l1, %l5
    edge8l %l0, %l1, %l5
    edge8ln %l0, %l1, %l5
    edge8n %l0, %l1, %l5

    set 0x07, %l0
    set 0x00, %l1
    edge8 %l0, %l1, %l5
    edge8l %l0, %l1, %l5
    edge8ln %l0, %l1, %l5
    edge8n %l0, %l1, %l5

    set 0x00, %l0
    set 0x02, %l1
    edge16 %l0, %l1, %l5
    edge16l %l0, %l1, %l5
    edge16ln %l0, %l1, %l5
    edge16n %l0, %l1, %l5

    set 0x02, %l0
    set 0x03, %l1
    edge16 %l0, %l1, %l5
    edge16l %l0, %l1, %l5
    edge16ln %l0, %l1, %l5
    edge16n %l0, %l1, %l5

    set 0x03, %l0
    set 0x00, %l1
    edge16 %l0, %l1, %l5
    edge16l %l0, %l1, %l5
    edge16ln %l0, %l1, %l5
    edge16n %l0, %l1, %l5

    set 0x0f, %l0
    set 0x0f, %l1
    edge16 %l0, %l1, %l5
    edge16l %l0, %l1, %l5
    edge16ln %l0, %l1, %l5
    edge16n %l0, %l1, %l5

    set 0x00, %l0
    set 0x04, %l1
    edge32 %l0, %l1, %l5
    edge32l %l0, %l1, %l5
    edge32ln %l0, %l1, %l5
    edge32n %l0, %l1, %l5

    set 0x04, %l0
    set 0x00, %l1
    edge32 %l0, %l1, %l5
    edge32l %l0, %l1, %l5
    edge32ln %l0, %l1, %l5
    edge32n %l0, %l1, %l5

    set 0x0f, %l0
    set 0x0f, %l1
    edge32 %l0, %l1, %l5
    edge32l %l0, %l1, %l5
    edge32ln %l0, %l1, %l5
    edge32n %l0, %l1, %l5

    mulscc %l5, %l4, %l3
    mulscc %l4, %l3, %l3
    mulscc %l3, %l2, %l3
    mulscc %l2, %l1, %l3

    # Unsupported by QEMU
    # umulxhi %l1, %l2, %l3
    # te %xcc, 0x10
    # tle %icc, %i3
    # wr %i0, %g1, %asr22
    # wr %i0, %g1, %asr25

    wr %i0, %g1, %y
    wr %i0, %g1, %ccr
    wr %i0, %g1, %asi
    wr %i0, %g1, %fprs

    rd %y, %i0
    rd %ccr, %i0
    rd %asi, %i0
    rd %fprs, %i0

    fone %f32
    fones %f0
    fzero %f32
    fzeros %f0

    set load_zero64, %o0
    ld [%o0], %f0
    ldd [%o0], %f16
    ldq [%o0], %f32

    set load_one32, %o0
    ld [%o0], %f1
    fitod %f1, %f18
    fitoq %f1, %f36
    fitos %f1, %f1

    set load_two32, %o0
    ld [%o0], %f2
    fitod %f2, %f20
    fitoq %f2, %f40
    fitos %f2, %f2

    set load_three32, %o0
    ld [%o0], %f3
    fitod %f3, %f22
    fitoq %f3, %f44
    fitos %f3, %f3

    # NaN
    fdivs %f0, %f0, %f4
    fdivd %f16, %f16, %f24
    fdivq %f32, %f32, %f48

    fsqrtq %f40, %f8
    fsqrtd %f20, %f8
    fsqrts %f2, %f8

    fsqrts %f3, %f9
    fsqrtd %f22, %f10
    fsqrtq %f44, %f56

    fnot1 %f8, %f10
    fsrc1 %f8, %f10
    fnot2 %f8, %f10
    fsrc2 %f8, %f10
    fnot1s %f8, %f9
    fsrc1s %f8, %f10
    fnot2s %f8, %f9
    fsrc2s %f8, %f10


    fnand %f8, %f10, %f12
    fnor %f8, %f10, %f12
    fand %f8, %f10, %f12
    fandnot1 %f8, %f10, %f12
    fandnot2 %f8, %f10, %f12
    fxnor %f8, %f10, %f12
    fxor %f8, %f10, %f12
    for %f8, %f10, %f12
    fornot1 %f8, %f10, %f12
    fornot2 %f8, %f10, %f12
    fnands %f8, %f9, %f10
    fnors %f8, %f9, %f10
    fandnot1s %f8, %f9, %f10
    fandnot2s %f8, %f9, %f10
    fands %f8, %f9, %f10
    fxnors %f8, %f9, %f10
    fxors %f8, %f9, %f10
    fornot1s %f8, %f9, %f10
    fornot2s %f8, %f9, %f10
    fors %f8, %f9, %f10

    # Unsupported by QEMU
    # fslas16 %f8, %f10, %f4
    # fslas32 %f8, %f10, %f4
    # fsll16 %f8, %f10, %f4
    # fsll32 %f8, %f10, %f4
    # fsra16 %f8, %f10, %f4
    # fsra32 %f8, %f10, %f4
    # fsrl16 %f8, %f10, %f4
    # fsrl32 %f8, %f10, %f4

    fcmpeq16 %f0, %f4, %i0
    fcmpeq32 %f0, %f4, %i0
    fcmpgt16 %f0, %f4, %i0
    fcmpgt32 %f0, %f4, %i0
    fcmple16 %f0, %f4, %i0
    fcmple32 %f0, %f4, %i0
    fcmpne16 %f0, %f4, %i0
    fcmpne32 %f0, %f4, %i0

done:
    ret
