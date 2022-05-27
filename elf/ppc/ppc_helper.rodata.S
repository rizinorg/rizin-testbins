# SPDX-FileCopyrightText: 2022 r0t127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

min_sd:
    .llong 0x8000000000000000
min_sw:
    .long 0x80000000
min_sh:
    .hword 0x8000
min_sb:
    .byte 0x80
min_ud:
    .llong 0x0
min_uw:
    .long 0x0
min_uh:
    .hword 0x0
min_ub:
    .byte 0x0
max_sd:
    .llong 0x7fffffffffffffff
max_sw:
    .long 0x7fffffff
max_sh:
    .hword 0x7fff
max_sb:
    .byte 0x7f
max_ud:
    .llong 0xffffffffffffffff
max_uw:
    .long 0xffffffff
max_uh:
    .hword 0xffff
max_ub:
    .byte 0xff
.align 4
rotate_test_pattern:
    .llong 0xfedcba9876543210
rotate_test_pattern_rev:
    .llong 0x0123456789abcdef
