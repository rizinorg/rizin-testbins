# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.section ".data"

.align 16
store_b:
    .byte 0
    .byte 0
    .byte 0
.align 16
store_h:
    .hword 0
    .hword 0
    .hword 0
.align 16
store_w:
    .long 0
    .long 0
    .long 0
.align 16
store_d:
    .xword 0
    .xword 0
    .xword 0
.align 64
store_q:
    .xword 0
    .xword 0
    .xword 0
    .xword 0
    .xword 0
    .xword 0
    .xword 0
    .xword 0

    .xword 0
    .xword 0
    .xword 0
    .xword 0
    .xword 0
    .xword 0
    .xword 0
    .xword 0

    .xword 0
    .xword 0
    .xword 0
    .xword 0
    .xword 0
    .xword 0
    .xword 0
    .xword 0
.align 16
load_b:
    .byte 0xff
    .byte 0xee
    .byte 0xdd
.align 16
load_h:
    .hword 0xffff
    .hword 0xeeee
    .hword 0xdddd
.align 16
load_w:
    .long 0xffffffff
    .long 0xeeeeeeee
    .long 0xdddddddd
.align 16
load_d:
    .xword 0xffffffffffffffff
    .xword 0xeeeeeeeeeeeeeeee
    .xword 0xdddddddddddddddd
.align 16
load_q:
    .xword 0xffffffffffffffff
    .xword 0xffffffffffffffff
    .xword 0xeeeeeeeeeeeeeeee
    .xword 0xeeeeeeeeeeeeeeee
    .xword 0xdddddddddddddddd
    .xword 0xdddddddddddddddd

.align 16
random_data_1_rw:
    .xword 0x2dee87a88f15ba65
    .xword 0x7265ec29d2fadfcb
    .xword 0x2be623a17f30071a
    .xword 0x61f5ee52f9d04c09
    .xword 0x40d14daeb24cdc54
    .xword 0x22922065aeb58805
    .xword 0x70ed544d2bdad4f2
    .xword 0x29962fbd17cef8c8
    .xword 0x36fb6db10856409
    .xword 0x36d7e2a3cf88f953
    .xword 0x2f3c1f2dc124d83
    .xword 0x4b6304e2bf648222
    .xword 0x3b152e527965850
    .xword 0x7288475cd6ab04e5
    .xword 0x4fd5bd16f973f618
    .xword 0x258411dc2f3b7482
    .xword 0x22f3e5e08f8b3b87
    .xword 0x5a750be6947a54e2
    .xword 0xdaf3cac4ffb63f2
    .xword 0x226d7ddcd19e0e5e
    .xword 0x63fbd4957e9ec5c7
    .xword 0x731d3e1374d74837
    .xword 0x3e6d788e12834a96
    .xword 0x7e293bb1f050d6df
    .xword 0x4dc162d9d3479806
    .xword 0x6c341bf98830a55a
    .xword 0x4fa7153aa6c3d674
    .xword 0x66297e50389aa9fc
    .xword 0x5d93a9178f3c9da8
    .xword 0x3fcae79ea348b403
    .xword 0x3ffa11665c4ef0b2
    .xword 0x61c2b7366cadfff4
    .xword 0x52b3e8f2e4b2ea7c
    .xword 0x73de45fe523737dd
    .xword 0x6809d8d03efeab2b
    .xword 0x79b25101b637f114
    .xword 0x322e5a04f046face
    .xword 0x4899c749d2c700e2
    .xword 0x68f5cb6f5c43f91
    .xword 0x3b71f5095489368a
    .xword 0x5b9e5c9dbb41d4e2
    .xword 0x3af5925c0ef6740a
    .xword 0x76c6a6cae3741561
    .xword 0x246158ec4dcb3353
    .xword 0x61eddcd204eb3412
    .xword 0x7d267a3a2778839e
    .xword 0x536ab5ddc4cb6686
    .xword 0x2c53ad3aec770868
    .xword 0x43806909309132bd
    .xword 0x94a294e80a3f158
    .xword 0xae69be3a9572b9c
    .xword 0x6e2c64e2925564d0
    .xword 0x7eb935fc121d0686
    .xword 0x1b9ecb49959672c0
    .xword 0x6e158a44391b36b0
    .xword 0xd5ece03780ea68d
    .xword 0x1aee8aebd8e4e596
    .xword 0x5e14c9540abee8f5
    .xword 0x450642999c0b2539
    .xword 0xc42d19340e98957
    .xword 0x59b94dd993f788f0
    .xword 0x6a7197860051f1a1
    .xword 0x33afe3ceb109776b
    .xword 0x6e6753c620b058de

.section ".rodata"

.align 16
random_data_0:
    .xword 0x682c5f5d709b6285
    .xword 0x32aa9fb6ae96b088
    .xword 0x21d217428b54dc66
    .xword 0x59cf8853dddd117f
    .xword 0x78005d7e1b6adfa1
    .xword 0x5b5140d109107291
    .xword 0x7f06d817d0f2abd4
    .xword 0x79ec5b2b34bcbd40
    .xword 0x6e3e2aaff4eebbba
    .xword 0x7c07325b59c673be
    .xword 0x2144e5119f930b25
    .xword 0x319914cc70f34212
    .xword 0x782490386d9ffb09
    .xword 0xfb1215eccfd0b56
    .xword 0x2858b12a39388021
    .xword 0x1202b141ae83bfbe
    .xword 0x2f699354061447e9
    .xword 0x6b146cfe3a992b09
    .xword 0x1fef656f47f1578f
    .xword 0x77b09980fca87ef1
    .xword 0x746258c749423f07
    .xword 0x128ee6ee1ce7324a
    .xword 0x54da4cfa7faf7000
    .xword 0x4ce12cd84a109754
    .xword 0x30b7ee244b14ec74
    .xword 0x4c86b4723e95182f
    .xword 0x76a485f2afddec0a
    .xword 0x6f95e7854453d073
    .xword 0x5fbcafe53dad42
    .xword 0x7b4c17ee1e2703cd
    .xword 0x475e1268be6010d9
    .xword 0x3c64c7bd1ee3a5c7
    .xword 0x21d1ff163d56f0b8
    .xword 0x1e56369f72b73679
    .xword 0x5b5e2c0579710b6a
    .xword 0x535d42dc8ddef036
    .xword 0x52f384d9827fe566
    .xword 0x335b2cb337660656
    .xword 0x7befd0b35f0eecab
    .xword 0x15749ab8acbc5331
    .xword 0x27031376b67a6fc4
    .xword 0x774652cd9557194
    .xword 0x4be4589a8eed797a
    .xword 0x1d5c123d79ac8c9b
    .xword 0x7998da36c430ed74
    .xword 0x436a7db33eb16149
    .xword 0x138fc986117f17a3
    .xword 0x2fe76ba34a90dba
    .xword 0x6fe4a0ec7c5d3e14
    .xword 0x66ae5d1c6cd1371d
    .xword 0x31da478921b93893
    .xword 0x6f84d51486802e17
    .xword 0x346ed21e68d2f170
    .xword 0x6b62bf056286f491
    .xword 0x307c0df183cb7ae7
    .xword 0x3d1c019a4a13e9d3
    .xword 0x1371035c2df0de5a
    .xword 0xc94cfb7f073b088
    .xword 0x687c6d6658cbba02
    .xword 0x52261afa68fdaa80
    .xword 0x56b71f5edfa68f7b
    .xword 0x69b44b9edd796c8f
    .xword 0x47286ccdbcffeded
    .xword 0x143221efd07daca4


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

    set load_d, %l4
    ldx [%l4], %l5
    set 0x0, %l0
    cas [%l4], %l5, %l0

    set load_d, %l4
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
done:
    ret
