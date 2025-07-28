# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.align 16
.section ".data"
load_zero32:
    .long 0
load_one32:
    .long 1
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
load_neg_one64:
    .xword 0xffffffffffffffff
load_max_neg64:
    .xword 0x8000000000000000
load_max_pos64:
    .xword 0x7fffffffffffffff

