# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

# \file The instructions tested here are not implemented in QEMU
# and need to be run on a real machine.

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
.section ".data"
backup_fp_regs:
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
.section ".text"
    .global run_all_tests
    .type run_all_tests, @function

run_all_tests:
    #
    # Backup FP regs
    #
    # set backup_fp_regs, %l7
    # stq %f0, [%l7+0x00]
    # stq %f4, [%l7+0x10]
    # stq %f8, [%l7+0x20]
    # stq %f12, [%l7+0x30]
    # stq %f16, [%l7+0x40]
    # stq %f20, [%l7+0x50]
    # stq %f24, [%l7+0x60]
    # stq %f28, [%l7+0x70]
    # stq %f32, [%l7+0x80]
    # stq %f36, [%l7+0x90]
    # stq %f40, [%l7+0xa0]
    # stq %f44, [%l7+0xb0]
    # stq %f48, [%l7+0xc0]
    # stq %f52, [%l7+0xd0]
    # stq %f56, [%l7+0xe0]
    # stq %f60, [%l7+0xf0]

    # Setup regs

.ifdef _GLOBAL_OFFSET_TABLE_
    # Load address of random_data_0 into %l7
    # Figured out by doing the same in C and compiling with gcc -s
    # OpenBSD requires to go over the GOT apparently.
    sethi %hi(_GLOBAL_OFFSET_TABLE_-8), %l7
    add %l7, %lo(_GLOBAL_OFFSET_TABLE_-4), %l7
    rd %pc, %o7
    add %l7, %o7, %l7
    sethi %hi(random_data_0), %g1
    or %g1, %lo(random_data_0), %g1
    ldx [%l7+%g1], %l7
.else
    # Otherwise load directly.
    set random_data_0, %l7
.endif

    ld [%l7+0x00], %l0
    ld [%l7+0x10], %l1
    ld [%l7+0x20], %l2
    ld [%l7+0x30], %l3
    ld [%l7+0x40], %l4
    ld [%l7+0x50], %l5
    ld [%l7+0x60], %l6

    ldq [%l7+0x00], %f0
    ldq [%l7+0x10], %f4
    ldq [%l7+0x20], %f8
    ldq [%l7+0x30], %f12
    ldq [%l7+0x40], %f16
    ldq [%l7+0x50], %f20
    ldq [%l7+0x60], %f24
    ldq [%l7+0x70], %f28
    ldq [%l7+0x80], %f32
    ldq [%l7+0x90], %f36
    ldq [%l7+0xa0], %f40
    ldq [%l7+0xb0], %f44
    ldq [%l7+0xc0], %f48
    ldq [%l7+0xd0], %f52
    ldq [%l7+0xe0], %f56
    ldq [%l7+0xf0], %f60

    # Actual important instruction tests.
    # Only those are relevant.

    # BEGIN: Relevant tests

    # bshuffle test
    bmask %l0, %l1, %l6
    bshuffle %f0, %f2, %f16

    #
    # These are not supported by QEMU
    # Need to run on a real machine
    #
    movdtox %f32, %l6
    movdtox %f0, %l6
    movstouw %f0, %l6
    movstosw %f0, %l6
    xmulx %l0, %l1, %l6
    xmulxhi %l0, %l1, %l6
    fhadds %f0, %f4, %f8
    fhaddd %f0, %f4, %f8
    fnhadds %f0, %f4, %f8
    fnhaddd %f0, %f4, %f8
    fhsubs %f0, %f4, %f8
    fhsubd %f0, %f4, %f8
    fnadds %f0, %f4, %f8
    fnaddd %f32, %f34, %f36
    fpadd64 %f0, %f4, %f16
    lzcnt %l2, %l6
    tsubcc %l0, %l2, %l6
    taddcc %l0, %l2, %l6
    # Skipe these, bacause they trap
    # tsubcctv %l0, %l2, %l6
    # taddcctv %l0, %l2, %l6
    pdistn %f0, %f4, %l6
    fmean16 %f0, %f2, %f32
    fchksm16 %f0, %f2, %f32

    # END: Relevant tests

    #
    # Restore regs
    #
    # set backup_fp_regs, %l7
    # ldq [%l7+0x00], %f0
    # ldq [%l7+0x10], %f4
    # ldq [%l7+0x20], %f8
    # ldq [%l7+0x30], %f12
    # ldq [%l7+0x40], %f16
    # ldq [%l7+0x50], %f20
    # ldq [%l7+0x60], %f24
    # ldq [%l7+0x70], %f28
    # ldq [%l7+0x80], %f32
    # ldq [%l7+0x90], %f36
    # ldq [%l7+0xa0], %f40
    # ldq [%l7+0xb0], %f44
    # ldq [%l7+0xc0], %f48
    # ldq [%l7+0xd0], %f52
    # ldq [%l7+0xe0], %f56
    # ldq [%l7+0xf0], %f60

    ret
    nop
