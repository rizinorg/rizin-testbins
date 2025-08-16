# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.section ".data"
.align 16
load_zero8:
    .byte 0
load_one8:
    .byte 1
load_two8:
    .byte 2
load_three8:
    .byte 3
load_neg_one8:
    .byte 0xff
load_max_neg8:
    .byte 0x80
load_max_pos8:
    .byte 0x7f
.align 16
load_zero16:
    .hword 0
load_one16:
    .hword 1
load_two16:
    .hword 2
load_three16:
    .hword 3
load_neg_one16:
    .hword 0xffff
load_max_neg16:
    .hword 0x8000
load_max_pos16:
    .hword 0x7fff
.align 16
load_zero32:
    .long 0
.align 16
load_one32:
    .long 1
.align 16
load_two32:
    .long 2
.align 16
load_three32:
    .long 3
.align 16
load_0x2032:
    .long 0x20
.align 16
load_neg_one32:
    .long 0xffffffff
load_max_neg32:
    .long 0x80000000
load_max_pos32:
    .long 0x7fffffff
.align 16
load_zero64:
    .xword 0
load_one64:
    .xword 1
load_two64:
    .xword 2
load_three64:
    .xword 3
load_neg_one64:
    .xword 0xffffffffffffffff
load_max_neg64:
    .xword 0x8000000000000000
load_max_pos64:
    .xword 0x7fffffffffffffff

load_zero128:
    .xword 0
    .xword 0
load_one128:
    .xword 0
    .xword 1
load_two128:
    .xword 0
    .xword 2
load_three128:
    .xword 0
    .xword 3
load_neg_one128:
    .xword 0xffffffffffffffff
    .xword 0xffffffffffffffff
load_max_neg128:
    .xword 0x8000000000000000
    .xword 0x0000000000000000
load_max_pos128:
    .xword 0x7fffffffffffffff
    .xword 0xffffffffffffffff

