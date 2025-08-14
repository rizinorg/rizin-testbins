# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.include "data.s"
.include "rodata.s"
.include "data64_const.s"

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

    set random_data_0, %l7

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
