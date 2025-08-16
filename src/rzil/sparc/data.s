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
load_b_rw:
    .byte 0xff
    .byte 0xee
    .byte 0xdd
.align 16
load_h_rw:
    .hword 0xffff
    .hword 0xeeee
    .hword 0xdddd
.align 16
load_w_rw:
    .long 0xffffffff
    .long 0xeeeeeeee
    .long 0xdddddddd
.align 16
load_d_rw:
    .xword 0xffffffffffffffff
    .xword 0xeeeeeeeeeeeeeeee
    .xword 0xdddddddddddddddd
.align 16
load_q_rw:
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
