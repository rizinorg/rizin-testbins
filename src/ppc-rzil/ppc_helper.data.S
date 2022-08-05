# SPDX-FileCopyrightText: 2022 r0t127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.align 12

msg:
    .string "Hello, world!\n"
    len = . - msg       # length of our dear string

.align 4
store_b:
    .byte 0
.align 4
store_h:
    .hword 0
.align 4
store_w:
    .long 0
.align 4
store_d:
    .llong 0
.align 4
load_b:
    .byte 0xff
.align 4
load_h:
    .hword 0xffff
.align 4
load_w:
    .long 0xffffffff
.align 4
load_d:
    .llong 0xffffffffffffffff
.align 5
cache_line:
    .llong 0xffffffffffffffff
    .llong 0xffffffffffffffff
    .llong 0xffffffffffffffff
    .llong 0xffffffffffffffff
.align 4

reg_file:
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0
    .llong 0


store_playground:
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
    .llong 0x0
