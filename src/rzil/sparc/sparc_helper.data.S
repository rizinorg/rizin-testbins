# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.align 16

msg:
    .string "Hello, world!\n"
    len = . - msg

.align 4
store_b:
    .byte 0
.align 4
store_h:
    .hword 0
.align 4
store_w:
    .word 0
.align 4
store_d:
    .xword 0
.align 4
load_b:
    .byte 0xff
.align 4
load_h:
    .hword 0xffff
.align 4
load_w:
    .word 0xffffffff
.align 4
load_d:
    .xword 0xffffffffffffffff
.align 8
cache_line:
    .xword 0xffffffffffffffff
    .xword 0xffffffffffffffff
    .xword 0xffffffffffffffff
    .xword 0xffffffffffffffff
.align 4

reg_file:
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


store_playground:
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
    .xword 0x0
