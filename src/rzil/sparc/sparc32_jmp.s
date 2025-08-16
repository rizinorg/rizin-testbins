# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

/**
 * \file Assembly tests for (conditional) branches.
 *
 * Each test has the same sturcture:
 * It jumps to check_branch where it devides l7/l6.
 * If the devision throws a division_by_zero exception the test failed.
 * If it doesn't throw an exception it jumps to the next test.
 *
 * All instructions should be emulated without floating point exception.
 *
 * Register usage:
 *
 * l0 => Return jump address
 * l1 => Offset to next test.
 * l5 => Result of division.
 * l6 => Divisor. Set to 0 if test failed. 1 otherwise.
 * l7 => Dividend. Always 1.
 *
 * f0 => 0.0
 * f1 => 1.0
 * f2 => -1.0
 * f3 => NaN
 * f32 => 0.0
 * f34 => 1.0
 * f36 => -1.0
 * f38 => NaN
 *
 * i0-i4: 32bit math oprands
 * o0-o4: 64bit math oprands
 */

.include "data64_const.s"

.align 16
.section ".text"
    .global test_branches

test_branches:

# For performing 32bit math
set load_neg_one32, %i0
ld [%i0], %i1
set load_max_neg32, %i0
ld [%i0], %i2
set load_max_pos32, %i0
ld [%i0], %i3
set load_one32, %i0
ld [%i0], %i0

set 0x18, %l1

# Dividend. Divisor is in l6.
set 1, %l7

# Set divisor which triggers exception
set 0, %l6
ba check_branch_0
set 1, %l6
check_branch_0:
udiv %l7, %l6, %l5

# Branch Never
set 1, %l6
bn check_branch_1
nop
check_branch_1:
udiv %l7, %l6, %l5

# Branch not equal (not Z)
set 0, %l6
orcc %g0, %l1, %l1
bne check_branch_2
set 1, %l6
check_branch_2:
udiv %l7, %l6, %l5

# Branch equal (Z)
set 0, %l6
andcc %g0, %l1, %g0
be check_branch_3
set 1, %l6
check_branch_3:
udiv %l7, %l6, %l5

# Branch greater (not (Z or (N xor V)))
set 0, %l6
cmp %i0, %g0
bg check_branch_4
set 1, %l6
check_branch_4:
udiv %l7, %l6, %l5

# Branch less equal (Z or (N xor V))
set 0, %l6
cmp %g0, %g0
ble check_branch_5
set 1, %l6
check_branch_5:
udiv %l7, %l6, %l5

# Branch greater equal (not (N xor V))
set 0, %l6
cmp %g0, %g0
bge check_branch_6
set 1, %l6
check_branch_6:
udiv %l7, %l6, %l5

# Branch less (N xor V)
set 0, %l6
cmp %i1, %g0
bl check_branch_7
set 1, %l6
check_branch_7:
udiv %l7, %l6, %l5

# Branch greater unsigned (not (C or Z))
set 0, %l6
cmp %i0, %g0
bgu check_branch_8
set 1, %l6
check_branch_8:
udiv %l7, %l6, %l5

# Branch less equal unsigned (C or Z)
set 0, %l6
cmp %g0, %i0
bleu check_branch_9
set 1, %l6
check_branch_9:
udiv %l7, %l6, %l5

# Branch carry clear (not C)
set 0, %l6
addcc %i0, %i0, %i4
bcc check_branch_10
set 1, %l6
check_branch_10:
udiv %l7, %l6, %l5

# Branch on carry (C)
set 0, %l6
addcc %i1, %i1, %i4
bcs check_branch_11
set 1, %l6
check_branch_11:
udiv %l7, %l6, %l5

# Branch on positive (not N)
set 0, %l6
addcc %i0, %i0, %i4
bpos check_branch_12
set 1, %l6
check_branch_12:
udiv %l7, %l6, %l5

# Branch on negative (N)
set 0, %l6
addcc %i1, %i1, %i4
bneg check_branch_13
set 1, %l6
check_branch_13:
udiv %l7, %l6, %l5

# Branch overflow clear (not V)
set 0, %l6
addcc %i0, %i0, %i4
bvc check_branch_14
set 1, %l6
check_branch_14:
udiv %l7, %l6, %l5

# Branch one overflow (V)
set 0, %l6
addcc %i3, %i0, %i4
bvs check_branch_15
set 1, %l6
check_branch_15:
udiv %l7, %l6, %l5

#
# Annul bits
#

set 1, %l6

# Branch Never
nop
bn,a check_branch_1_a
set 0, %l6
check_branch_1_a:
udiv %l7, %l6, %l5

# Branch not equal (not Z)
andcc %g0, %l1, %g0
bne,a check_branch_2_a
set 0, %l6
check_branch_2_a:
udiv %l7, %l6, %l5

# Branch equal (Z)
andcc %l1, %l1, %l1
be,a check_branch_3_a
set 0, %l6
check_branch_3_a:
udiv %l7, %l6, %l5

# Branch greater (not (Z or (N xor V)))
cmp %g0, %i0
bg,a check_branch_4_a
set 0, %l6
check_branch_4_a:
udiv %l7, %l6, %l5

# Branch less equal (Z or (N xor V))
cmp %i0, %g0
ble,a check_branch_5_a
set 0, %l6
check_branch_5_a:
udiv %l7, %l6, %l5

# Branch greater equal (not (N xor V))
cmp %g0, %i0
bge,a check_branch_6_a
set 0, %l6
check_branch_6_a:
udiv %l7, %l6, %l5

# Branch less (N xor V)
cmp %i0, %g0
bl,a check_branch_7_a
set 0, %l6
check_branch_7_a:
udiv %l7, %l6, %l5

# Branch greater unsigned (not (C or Z))
cmp %g0, %g0
bgu,a check_branch_8_a
set 0, %l6
check_branch_8_a:
udiv %l7, %l6, %l5

# Branch less equal unsigned (C or Z)
cmp %i1, %g0
bleu,a check_branch_9_a
set 0, %l6
check_branch_9_a:
udiv %l7, %l6, %l5

# Branch carry clear (not C)
addcc %i1, %i0, %i4
bcc,a check_branch_10_a
set 0, %l6
check_branch_10_a:
udiv %l7, %l6, %l5

# Branch on carry (C)
addcc %i0, %i0, %i4
bcs,a check_branch_11_a
set 0, %l6
check_branch_11_a:
udiv %l7, %l6, %l5

# Branch on positive (not N)
addcc %i1, %i1, %i4
bpos,a check_branch_12_a
set 0, %l6
check_branch_12_a:
udiv %l7, %l6, %l5

# Branch on negative (N)
addcc %i0, %i0, %i4
bneg,a check_branch_13_a
set 0, %l6
check_branch_13_a:
udiv %l7, %l6, %l5

# Branch overflow clear (not V)
addcc %i3, %i0, %i4
bvc,a check_branch_14_a
set 0, %l6
check_branch_14_a:
udiv %l7, %l6, %l5

# Branch one overflow (V)
addcc %i0, %i0, %i4
bvs,a check_branch_15_a
set 0, %l6
check_branch_15_a:
udiv %l7, %l6, %l5

#
# Floats
#

set load_zero64, %o0
ld [%o0], %f0

set load_one32, %o0
ld [%o0], %f1
fitos %f1, %f1

set load_neg_one32, %o0
ld [%o0], %f2
fitos %f2, %f2

# NaN
fdivs %f0, %f0, %f3

#
# Float branch test
#

# Branch always
fcmps %f0, %f0
fba check_branch_0_f
nop
check_branch_0_f:
udiv %l7, %l6, %l5

# Branch never
fcmps %f0, %f0
fbn check_branch_1_f
nop
check_branch_1_f:
udiv %l7, %l6, %l5

# Branch unordered
set 0, %l6
fcmps %f3, %f3
fbu check_branch_2_f
set 1, %l6
check_branch_2_f:
udiv %l7, %l6, %l5

# Branch greater
set 0, %l6
fcmps %f1, %f0
fbg check_branch_3_f
set 1, %l6
check_branch_3_f:
udiv %l7, %l6, %l5

# Branch unordered or greater
set 0, %l6
fcmps %f1, %f0
fbug check_branch_4_f
set 1, %l6
check_branch_4_f:
udiv %l7, %l6, %l5

# Branch unordered or greater
set 0, %l6
fcmps %f3, %f3
fbug check_branch_5_f
set 1, %l6
check_branch_5_f:
udiv %l7, %l6, %l5

# Branch less
set 0, %l6
fcmps %f0, %f1
fbl check_branch_6_f
set 1, %l6
check_branch_6_f:
udiv %l7, %l6, %l5

# Branch unordered and less
set 0, %l6
fcmps %f0, %f1
fbul check_branch_7_f
set 1, %l6
check_branch_7_f:
udiv %l7, %l6, %l5

# Branch unordered and less
set 0, %l6
fcmps %f3, %f3
fbul check_branch_8_f
set 1, %l6
check_branch_8_f:
udiv %l7, %l6, %l5

# Branch less or greater
set 0, %l6
fcmps %f1, %f0
fblg check_branch_9_f
set 1, %l6
check_branch_9_f:
udiv %l7, %l6, %l5

# Branch less or greater
set 0, %l6
fcmps %f0, %f1
fblg check_branch_10_f
set 1, %l6
check_branch_10_f:
udiv %l7, %l6, %l5

# Branch not equal
set 0, %l6
fcmps %f2, %f0
fbne check_branch_11_f
set 1, %l6
check_branch_11_f:
udiv %l7, %l6, %l5

# Branch equal
set 0, %l6
fcmps %f0, %f0
fbe check_branch_12_f
set 1, %l6
check_branch_12_f:
udiv %l7, %l6, %l5

# Branch unordered or equal
set 0, %l6
fcmps %f3, %f0
fbue check_branch_13_f
set 1, %l6
check_branch_13_f:
udiv %l7, %l6, %l5

# Branch unordered or equal
set 0, %l6
fcmps %f0, %f0
fbue check_branch_14_f
set 1, %l6
check_branch_14_f:
udiv %l7, %l6, %l5

# Branch greater or equal
set 0, %l6
fcmps %f0, %f0
fbge check_branch_15_f
set 1, %l6
check_branch_15_f:
udiv %l7, %l6, %l5

# Branch greater or equal
set 0, %l6
fcmps %f0, %f2
fbge check_branch_16_f
set 1, %l6
check_branch_16_f:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %f0, %f0
fbuge check_branch_17_f
set 1, %l6
check_branch_17_f:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %f1, %f0
fbuge check_branch_18_f
set 1, %l6
check_branch_18_f:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %f1, %f3
fbuge check_branch_19_f
set 1, %l6
check_branch_19_f:
udiv %l7, %l6, %l5

# Branch less or equal
set 0, %l6
fcmps %f0, %f0
fble check_branch_20_f
set 1, %l6
check_branch_20_f:
udiv %l7, %l6, %l5

# Branch less or equal
set 0, %l6
fcmps %f0, %f1
fble check_branch_21_f
set 1, %l6
check_branch_21_f:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %f0, %f0
fbule check_branch_22_f
set 1, %l6
check_branch_22_f:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %f0, %f1
fbule check_branch_23_f
set 1, %l6
check_branch_23_f:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %f0, %f3
fbule check_branch_24_f
set 1, %l6
check_branch_24_f:
udiv %l7, %l6, %l5

# Branch ordered
set 0, %l6
fcmps %f0, %f0
fbo check_branch_25_f
set 1, %l6
check_branch_25_f:
udiv %l7, %l6, %l5

#
# Annulled tests
#

# Branch never
nop
fbn,a check_branch_1_f_a
set 0, %l6
check_branch_1_f_a:
udiv %l7, %l6, %l5

# Branch unordered
fcmps %f1, %f1
fbu,a check_branch_2_f_a
set 0, %l6
check_branch_2_f_a:
udiv %l7, %l6, %l5

# Branch greater
fcmps %f0, %f0
fbg,a check_branch_3_f_a
set 0, %l6
check_branch_3_f_a:
udiv %l7, %l6, %l5

# Branch unordered or greater
fcmps %f0, %f0
fbug,a check_branch_4_f_a
set 0, %l6
check_branch_4_f_a:
udiv %l7, %l6, %l5

# Branch less
fcmps %f0, %f0
fbl,a check_branch_5_f_a
set 0, %l6
check_branch_5_f_a:
udiv %l7, %l6, %l5

# Branch unordered and less
fcmps %f0, %f0
fbul,a check_branch_6_f_a
set 0, %l6
check_branch_6_f_a:
udiv %l7, %l6, %l5

# Branch less or greater
fcmps %f0, %f0
fblg,a check_branch_7_f_a
set 0, %l6
check_branch_7_f_a:
udiv %l7, %l6, %l5

# Branch not equal
fcmps %f0, %f0
fbne,a check_branch_8_f_a
set 0, %l6
check_branch_8_f_a:
udiv %l7, %l6, %l5

# Branch equal
fcmps %f1, %f0
fbe,a check_branch_9_f_a
set 0, %l6
check_branch_9_f_a:
udiv %l7, %l6, %l5

# Branch unordered or equal
fcmps %f2, %f0
fbue,a check_branch_10_f_a
set 0, %l6
check_branch_10_f_a:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
fcmps %f0, %f1
fbuge,a check_branch_11_f_a
set 0, %l6
check_branch_11_f_a:
udiv %l7, %l6, %l5

# Branch less or equal
fcmps %f1, %f0
fble,a check_branch_12_f_a
set 0, %l6
check_branch_12_f_a:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
fcmps %f1, %f0
fbule,a check_branch_13_f_a
set 0, %l6
check_branch_13_f_a:
udiv %l7, %l6, %l5

# Branch ordered
fcmps %f3, %f3
fbo,a check_branch_14_f_a
set 0, %l6
check_branch_14_f_a:
udiv %l7, %l6, %l5

nop
nop
nop

done:
        ret
        restore
