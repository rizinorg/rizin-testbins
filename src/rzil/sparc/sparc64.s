# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.section ".data"
.include "sparc_helper.data.S"

.section ".rodata"
.include "sparc_helper.rodata.S"


.text
    .global run_all_tests
    .global add_insns
    # .global sub_insns
    # .global store_insns
    # .global load_insns

    .type run_all_tests, @function
    .type add_insns, @function
    # .type sub_insns, @function
    # .type store_insns, @function
    # .type load_insns, @function

#
# Instructions which are PC/LR independed below
#

run_all_tests:

add_insns:
    add %l0, 0x1, %l0
    addcc %l0, -2, %l0
    addx %l0, 0x1, %l0

done:
    return %i7+8
