# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

min_sd:
    .xword 0x8000000000000000
min_sw:
    .word 0x80000000
min_sh:
    .hword 0x8000
min_sb:
    .byte 0x80
min_ud:
    .xword 0x0
min_uw:
    .word 0x0
min_uh:
    .hword 0x0
min_ub:
    .byte 0x0
max_sd:
    .xword 0x7fffffffffffffff
max_sw:
    .word 0x7fffffff
max_sh:
    .hword 0x7fff
max_sb:
    .byte 0x7f
max_ud:
    .xword 0xffffffffffffffff
max_uw:
    .word 0xffffffff
max_uh:
    .hword 0xffff
max_ub:
    .byte 0xff
.align 4
rotate_test_pattern:
    .xword 0xfedcba9876543210
rotate_test_pattern_rev:
    .xword 0x0123456789abcdef
