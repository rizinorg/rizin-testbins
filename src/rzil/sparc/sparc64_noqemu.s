# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

# Contains instructions currently not implemented by QEMU.

.include "data.s"
.include "rodata.s"
.include "data64_const.s"

.align 16
.section ".text"
    .global run_all_tests

    .type run_all_tests, @function

run_all_tests:

random_data_tests:

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

    movdtox %f32, %i0
    movdtox %f0, %i0
    movstouw %f0, %i0
    movstosw %f0, %i0
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
    tsubcctv %l0, %l2, %l6
    taddcctv %l0, %l2, %l6
    pdistn %f0, %f4, %i0
    fmean16 %f0, %f2, %f32
    fchksm16 %f0, %f2, %f32

done:
    ret
    restore
