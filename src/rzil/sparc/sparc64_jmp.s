# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

/**
 * \file Assembly tests for (conditional) branches.
 *
 * Each test has the same stucture:
 * 1. It does the condition check and then devides 1 / %l6.
 * The branch tests will fail if the delayed instruction hasn't set %l6 = 1.
 * The branch annulled tests will fail if the annulled instruction was executed anyways
 * setting %l6 = 0.
 * If the devision throws a division_by_zero exception if the test failed.
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
ldsw [%i0], %i1
set load_max_neg32, %i0
ldsw [%i0], %i2
set load_max_pos32, %i0
ldsw [%i0], %i3
set load_one32, %i0
lduw [%i0], %i0

# For performing 64bit math
set load_neg_one64, %o0
ldx [%o0], %o1
set load_max_neg64, %o0
ldx [%o0], %o2
set load_max_pos64, %o0
ldx [%o0], %o3
set load_one64, %o0
ldx [%o0], %o0

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
# 64bit branches
#

set 0x18, %l1

# Dividend. Divisor is in l6.
set 1, %l7

# Set divisor which triggers exception
set 0, %l6
ba %xcc, check_branch_xcc_0
set 1, %l6
check_branch_xcc_0:
udiv %l7, %l6, %l5

# Branch Never
set 1, %l6
bn %xcc, check_branch_xcc_1
nop
check_branch_xcc_1:
udiv %l7, %l6, %l5

# Branch not equal (not Z)
set 0, %l6
orcc %g0, %l1, %l1
bne %xcc, check_branch_xcc_2
set 1, %l6
check_branch_xcc_2:
udiv %l7, %l6, %l5

# Branch equal (Z)
set 0, %l6
andcc %g0, %l1, %g0
be %xcc, check_branch_xcc_3
set 1, %l6
check_branch_xcc_3:
udiv %l7, %l6, %l5

# Branch greater (not (Z or (N xor V)))
set 0, %l6
cmp %o0, %g0
bg %xcc, check_branch_xcc_4
set 1, %l6
check_branch_xcc_4:
udiv %l7, %l6, %l5

# Branch less equal (Z or (N xor V))
set 0, %l6
cmp %g0, %g0
ble %xcc, check_branch_xcc_5
set 1, %l6
check_branch_xcc_5:
udiv %l7, %l6, %l5

# Branch greater equal (not (N xor V))
set 0, %l6
cmp %g0, %g0
bge %xcc, check_branch_xcc_6
set 1, %l6
check_branch_xcc_6:
udiv %l7, %l6, %l5

# Branch less (N xor V)
set 0, %l6
cmp %o1, %g0
bl %xcc, check_branch_xcc_7
set 1, %l6
check_branch_xcc_7:
udiv %l7, %l6, %l5

# Branch greater unsigned (not (C or Z))
set 0, %l6
cmp %o0, %g0
bgu %xcc, check_branch_xcc_8
set 1, %l6
check_branch_xcc_8:
udiv %l7, %l6, %l5

# Branch less equal unsigned (C or Z)
set 0, %l6
cmp %g0, %o0
bleu %xcc, check_branch_xcc_9
set 1, %l6
check_branch_xcc_9:
udiv %l7, %l6, %l5

# Branch carry clear (not C)
set 0, %l6
addcc %o0, %o0, %o4
bcc %xcc, check_branch_xcc_10
set 1, %l6
check_branch_xcc_10:
udiv %l7, %l6, %l5

# Branch on carry (C)
set 0, %l6
addcc %o1, %o1, %o4
bcs %xcc, check_branch_xcc_11
set 1, %l6
check_branch_xcc_11:
udiv %l7, %l6, %l5

# Branch on positive (not N)
set 0, %l6
addcc %o0, %o0, %o4
bpos %xcc, check_branch_xcc_12
set 1, %l6
check_branch_xcc_12:
udiv %l7, %l6, %l5

# Branch on negative (N)
set 0, %l6
addcc %o1, %o1, %o4
bneg %xcc, check_branch_xcc_13
set 1, %l6
check_branch_xcc_13:
udiv %l7, %l6, %l5

# Branch overflow clear (not V)
set 0, %l6
addcc %o0, %o0, %o4
bvc %xcc, check_branch_xcc_14
set 1, %l6
check_branch_xcc_14:
udiv %l7, %l6, %l5

# Branch one overflow (V)
set 0, %l6
addcc %o3, %o0, %o4
bvs %xcc, check_branch_xcc_15
set 1, %l6
check_branch_xcc_15:
udiv %l7, %l6, %l5

#
# Annul bits
#

set 1, %l6

# Branch Never
nop
bn,a %xcc, check_branch_xcc_1_a
set 0, %l6
check_branch_xcc_1_a:
udiv %l7, %l6, %l5

# Branch not equal (not Z)
andcc %g0, %l1, %g0
bne,a %xcc, check_branch_xcc_2_a
set 0, %l6
check_branch_xcc_2_a:
udiv %l7, %l6, %l5

# Branch equal (Z)
andcc %l1, %l1, %l1
be,a %xcc, check_branch_xcc_3_a
set 0, %l6
check_branch_xcc_3_a:
udiv %l7, %l6, %l5

# Branch greater (not (Z or (N xor V)))
cmp %g0, %o0
bg,a %xcc, check_branch_xcc_4_a
set 0, %l6
check_branch_xcc_4_a:
udiv %l7, %l6, %l5

# Branch less equal (Z or (N xor V))
cmp %o0, %g0
ble,a %xcc, check_branch_xcc_5_a
set 0, %l6
check_branch_xcc_5_a:
udiv %l7, %l6, %l5

# Branch greater equal (not (N xor V))
cmp %g0, %o0
bge,a %xcc, check_branch_xcc_6_a
set 0, %l6
check_branch_xcc_6_a:
udiv %l7, %l6, %l5

# Branch less (N xor V)
cmp %o0, %g0
bl,a %xcc, check_branch_xcc_7_a
set 0, %l6
check_branch_xcc_7_a:
udiv %l7, %l6, %l5

# Branch greater unsigned (not (C or Z))
cmp %g0, %g0
bgu,a %xcc, check_branch_xcc_8_a
set 0, %l6
check_branch_xcc_8_a:
udiv %l7, %l6, %l5

# Branch less equal unsigned (C or Z)
cmp %o1, %g0
bleu,a %xcc, check_branch_xcc_9_a
set 0, %l6
check_branch_xcc_9_a:
udiv %l7, %l6, %l5

# Branch carry clear (not C)
addcc %o1, %o0, %o4
bcc,a %xcc, check_branch_xcc_10_a
set 0, %l6
check_branch_xcc_10_a:
udiv %l7, %l6, %l5

# Branch on carry (C)
addcc %o0, %o0, %o4
bcs,a %xcc, check_branch_xcc_11_a
set 0, %l6
check_branch_xcc_11_a:
udiv %l7, %l6, %l5

# Branch on positive (not N)
addcc %o1, %o1, %o4
bpos,a %xcc, check_branch_xcc_12_a
set 0, %l6
check_branch_xcc_12_a:
udiv %l7, %l6, %l5

# Branch on negative (N)
addcc %o0, %o0, %o4
bneg,a %xcc, check_branch_xcc_13_a
set 0, %l6
check_branch_xcc_13_a:
udiv %l7, %l6, %l5

# Branch overflow clear (not V)
addcc %o3, %o0, %o4
bvc,a %xcc, check_branch_xcc_14_a
set 0, %l6
check_branch_xcc_14_a:
udiv %l7, %l6, %l5

# Branch one overflow (V)
addcc %o0, %o0, %o4
bvs,a %xcc, check_branch_xcc_15_a
set 0, %l6
check_branch_xcc_15_a:
udiv %l7, %l6, %l5

#
# Register based jumps
#

set 0, %l6
brz %l6, check_branch_reg_0
set 1, %l6
check_branch_reg_0:
udiv %l7, %l6, %l5

set 0, %l6
brlez %o1, check_branch_reg_1
set 1, %l6
check_branch_reg_1:
udiv %l7, %l6, %l5

set 0, %l6
brlez %l6, check_branch_reg_2
set 1, %l6
check_branch_reg_2:
udiv %l7, %l6, %l5

set 0, %l6
brlz %o1, check_branch_reg_3
set 1, %l6
check_branch_reg_3:
udiv %l7, %l6, %l5

set 0, %l6
brgz %o0, check_branch_reg_4
set 1, %l6
check_branch_reg_4:
udiv %l7, %l6, %l5

set 0, %l6
brgez %o0, check_branch_reg_5
set 1, %l6
check_branch_reg_5:
udiv %l7, %l6, %l5

set 0, %l6
brgez %l6, check_branch_reg_6
set 1, %l6
check_branch_reg_6:
udiv %l7, %l6, %l5

#
# Register based jumps annulled
#

set 1, %l6

brz,a %o0, check_branch_reg_a_0
set 0, %l6
check_branch_reg_a_0:
udiv %l7, %l6, %l5

brlez,a %o0, check_branch_reg_a_1
set 0, %l6
check_branch_reg_a_1:
udiv %l7, %l6, %l5

brlz,a %o0, check_branch_reg_a_3
set 0, %l6
check_branch_reg_a_3:
udiv %l7, %l6, %l5

brgz,a %o1, check_branch_reg_a_4
set 0, %l6
check_branch_reg_a_4:
udiv %l7, %l6, %l5

brgez,a %o1, check_branch_reg_a_5
set 0, %l6
check_branch_reg_a_5:
udiv %l7, %l6, %l5

# Floats

set load_zero64, %o0
ld [%o0], %f0
ldd [%o0], %f32

set load_one32, %o0
ld [%o0], %f1
fitod %f1, %f34
fitos %f1, %f1

set load_neg_one32, %o0
ld [%o0], %f2
fitod %f2, %f36
fitos %f2, %f2

# NaN
fdivs %f0, %f0, %f3
fdivd %f32, %f32, %f38

# Float branch test

set 0x18, %l1

# Branch always
set 0, %l6
fcmps %f0, %f0
fba check_branch_fcc0_0
set 1, %l6
check_branch_fcc0_0:
udiv %l7, %l6, %l5

# Branch never
set 0, %l6
fcmps %f0, %f0
fbn check_branch_fcc0_1
set 1, %l6
check_branch_fcc0_1:
udiv %l7, %l6, %l5

# Branch unordered
set 0, %l6
fcmps %f3, %f3
fbu check_branch_fcc0_2
set 1, %l6
check_branch_fcc0_2:
udiv %l7, %l6, %l5

# Branch greater
set 0, %l6
fcmps %f1, %f0
fbg check_branch_fcc0_3
set 1, %l6
check_branch_fcc0_3:
udiv %l7, %l6, %l5

# Branch unordered or greater
set 0, %l6
fcmps %f1, %f0
fbug check_branch_fcc0_4
set 1, %l6
check_branch_fcc0_4:
udiv %l7, %l6, %l5

# Branch unordered or greater
set 0, %l6
fcmps %f3, %f3
fbug check_branch_fcc0_5
set 1, %l6
check_branch_fcc0_5:
udiv %l7, %l6, %l5

# Branch less
set 0, %l6
fcmps %f0, %f1
fbl check_branch_fcc0_6
set 1, %l6
check_branch_fcc0_6:
udiv %l7, %l6, %l5

# Branch unordered and less
set 0, %l6
fcmps %f0, %f1
fbul check_branch_fcc0_7
set 1, %l6
check_branch_fcc0_7:
udiv %l7, %l6, %l5

# Branch unordered and less
set 0, %l6
fcmps %f3, %f3
fbul check_branch_fcc0_8
set 1, %l6
check_branch_fcc0_8:
udiv %l7, %l6, %l5

# Branch less or greater
set 0, %l6
fcmps %f1, %f0
fblg check_branch_fcc0_9
set 1, %l6
check_branch_fcc0_9:
udiv %l7, %l6, %l5

# Branch less or greater
set 0, %l6
fcmps %f0, %f1
fblg check_branch_fcc0_10
set 1, %l6
check_branch_fcc0_10:
udiv %l7, %l6, %l5

# Branch not equal
set 0, %l6
fcmps %f2, %f0
fbne check_branch_fcc0_11
set 1, %l6
check_branch_fcc0_11:
udiv %l7, %l6, %l5

# Branch equal
set 0, %l6
fcmps %f0, %f0
fbe check_branch_fcc0_12
set 1, %l6
check_branch_fcc0_12:
udiv %l7, %l6, %l5

# Branch unordered or equal
set 0, %l6
fcmps %f3, %f0
fbue check_branch_fcc0_13
set 1, %l6
check_branch_fcc0_13:
udiv %l7, %l6, %l5

# Branch unordered or equal
set 0, %l6
fcmps %f0, %f0
fbue check_branch_fcc0_14
set 1, %l6
check_branch_fcc0_14:
udiv %l7, %l6, %l5

# Branch greater or equal
set 0, %l6
fcmps %f0, %f0
fbge check_branch_fcc0_15
set 1, %l6
check_branch_fcc0_15:
udiv %l7, %l6, %l5

# Branch greater or equal
set 0, %l6
fcmps %f0, %f2
fbge check_branch_fcc0_16
set 1, %l6
check_branch_fcc0_16:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %f0, %f0
fbuge check_branch_fcc0_17
set 1, %l6
check_branch_fcc0_17:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %f1, %f0
fbuge check_branch_fcc0_18
set 1, %l6
check_branch_fcc0_18:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %f1, %f3
fbuge check_branch_fcc0_19
set 1, %l6
check_branch_fcc0_19:
udiv %l7, %l6, %l5

# Branch less or equal
set 0, %l6
fcmps %f0, %f0
fble check_branch_fcc0_20
set 1, %l6
check_branch_fcc0_20:
udiv %l7, %l6, %l5

# Branch less or equal
set 0, %l6
fcmps %f0, %f1
fble check_branch_fcc0_21
set 1, %l6
check_branch_fcc0_21:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %f0, %f0
fbule check_branch_fcc0_22
set 1, %l6
check_branch_fcc0_22:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %f0, %f1
fbule check_branch_fcc0_23
set 1, %l6
check_branch_fcc0_23:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %f0, %f3
fbule check_branch_fcc0_24
set 1, %l6
check_branch_fcc0_24:
udiv %l7, %l6, %l5

# Branch ordered
set 0, %l6
fcmps %f0, %f0
fbo check_branch_fcc0_25
set 1, %l6
check_branch_fcc0_25:
udiv %l7, %l6, %l5

# Annulled tests

set 1, %l6
set 0x14, %l1

# Branch never
nop
fbn,a check_branch_fcc0_a_0
set 0, %l6
check_branch_fcc0_a_0:
udiv %l7, %l6, %l5

# Branch unordered
fcmps %f1, %f1
fbu,a check_branch_fcc0_a_1
set 0, %l6
check_branch_fcc0_a_1:
udiv %l7, %l6, %l5

# Branch greater
fcmps %f0, %f0
fbg,a check_branch_fcc0_a_2
set 0, %l6
check_branch_fcc0_a_2:
udiv %l7, %l6, %l5

# Branch unordered or greater
fcmps %f0, %f0
fbug,a check_branch_fcc0_a_3
set 0, %l6
check_branch_fcc0_a_3:
udiv %l7, %l6, %l5

# Branch less
fcmps %f0, %f0
fbl,a check_branch_fcc0_a_4
set 0, %l6
check_branch_fcc0_a_4:
udiv %l7, %l6, %l5

# Branch unordered and less
fcmps %f0, %f0
fbul,a check_branch_fcc0_a_5
set 0, %l6
check_branch_fcc0_a_5:
udiv %l7, %l6, %l5

# Branch less or greater
fcmps %f0, %f0
fblg,a check_branch_fcc0_a_6
set 0, %l6
check_branch_fcc0_a_6:
udiv %l7, %l6, %l5

# Branch not equal
fcmps %f0, %f0
fbne,a check_branch_fcc0_a_7
set 0, %l6
check_branch_fcc0_a_7:
udiv %l7, %l6, %l5

# Branch equal
fcmps %f1, %f0
fbe,a check_branch_fcc0_a_8
set 0, %l6
check_branch_fcc0_a_8:
udiv %l7, %l6, %l5

# Branch unordered or equal
fcmps %f2, %f0
fbue,a check_branch_fcc0_a_9
set 0, %l6
check_branch_fcc0_a_9:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
fcmps %f0, %f1
fbuge,a check_branch_fcc0_a_10
set 0, %l6
check_branch_fcc0_a_10:
udiv %l7, %l6, %l5

# Branch less or equal
fcmps %f1, %f0
fble,a check_branch_fcc0_a_11
set 0, %l6
check_branch_fcc0_a_11:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
fcmps %f1, %f0
fbule,a check_branch_fcc0_a_12
set 0, %l6
check_branch_fcc0_a_12:
udiv %l7, %l6, %l5

# Branch ordered
fcmps %f3, %f3
fbo,a check_branch_fcc0_a_13
set 0, %l6
check_branch_fcc0_a_13:
udiv %l7, %l6, %l5

# Float branch test - fcc1

set 0x18, %l1

# Branch always
set 0, %l6
fcmps %fcc1, %f0, %f0
fba %fcc1, check_branch_fcc1_0
set 1, %l6
check_branch_fcc1_0:
udiv %l7, %l6, %l5

# Branch never
set 0, %l6
fcmps %fcc1, %f0, %f0
fbn %fcc1, check_branch_fcc1_1
set 1, %l6
check_branch_fcc1_1:
udiv %l7, %l6, %l5

# Branch unordered
set 0, %l6
fcmps %fcc1, %f3, %f3
fbu %fcc1, check_branch_fcc1_2
set 1, %l6
check_branch_fcc1_2:
udiv %l7, %l6, %l5

# Branch greater
set 0, %l6
fcmps %fcc1, %f1, %f0
fbg %fcc1, check_branch_fcc1_3
set 1, %l6
check_branch_fcc1_3:
udiv %l7, %l6, %l5

# Branch unordered or greater
set 0, %l6
fcmps %fcc1, %f1, %f0
fbug %fcc1, check_branch_fcc1_4
set 1, %l6
check_branch_fcc1_4:
udiv %l7, %l6, %l5

# Branch unordered or greater
set 0, %l6
fcmps %fcc1, %f3, %f3
fbug %fcc1, check_branch_fcc1_5
set 1, %l6
check_branch_fcc1_5:
udiv %l7, %l6, %l5

# Branch less
set 0, %l6
fcmps %fcc1, %f0, %f1
fbl %fcc1, check_branch_fcc1_6
set 1, %l6
check_branch_fcc1_6:
udiv %l7, %l6, %l5

# Branch unordered and less
set 0, %l6
fcmps %fcc1, %f0, %f1
fbul %fcc1, check_branch_fcc1_7
set 1, %l6
check_branch_fcc1_7:
udiv %l7, %l6, %l5

# Branch unordered and less
set 0, %l6
fcmps %fcc1, %f3, %f3
fbul %fcc1, check_branch_fcc1_8
set 1, %l6
check_branch_fcc1_8:
udiv %l7, %l6, %l5

# Branch less or greater
set 0, %l6
fcmps %fcc1, %f1, %f0
fblg %fcc1, check_branch_fcc1_9
set 1, %l6
check_branch_fcc1_9:
udiv %l7, %l6, %l5

# Branch less or greater
set 0, %l6
fcmps %fcc1, %f0, %f1
fblg %fcc1, check_branch_fcc1_10
set 1, %l6
check_branch_fcc1_10:
udiv %l7, %l6, %l5

# Branch not equal
set 0, %l6
fcmps %fcc1, %f2, %f0
fbne %fcc1, check_branch_fcc1_11
set 1, %l6
check_branch_fcc1_11:
udiv %l7, %l6, %l5

# Branch equal
set 0, %l6
fcmps %fcc1, %f0, %f0
fbe %fcc1, check_branch_fcc1_12
set 1, %l6
check_branch_fcc1_12:
udiv %l7, %l6, %l5

# Branch unordered or equal
set 0, %l6
fcmps %fcc1, %f3, %f0
fbue %fcc1, check_branch_fcc1_13
set 1, %l6
check_branch_fcc1_13:
udiv %l7, %l6, %l5

# Branch unordered or equal
set 0, %l6
fcmps %fcc1, %f0, %f0
fbue %fcc1, check_branch_fcc1_14
set 1, %l6
check_branch_fcc1_14:
udiv %l7, %l6, %l5

# Branch greater or equal
set 0, %l6
fcmps %fcc1, %f0, %f0
fbge %fcc1, check_branch_fcc1_15
set 1, %l6
check_branch_fcc1_15:
udiv %l7, %l6, %l5

# Branch greater or equal
set 0, %l6
fcmps %fcc1, %f0, %f2
fbge %fcc1, check_branch_fcc1_16
set 1, %l6
check_branch_fcc1_16:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %fcc1, %f0, %f0
fbuge %fcc1, check_branch_fcc1_17
set 1, %l6
check_branch_fcc1_17:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %fcc1, %f1, %f0
fbuge %fcc1, check_branch_fcc1_18
set 1, %l6
check_branch_fcc1_18:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %fcc1, %f1, %f3
fbuge %fcc1, check_branch_fcc1_19
set 1, %l6
check_branch_fcc1_19:
udiv %l7, %l6, %l5

# Branch less or equal
set 0, %l6
fcmps %fcc1, %f0, %f0
fble %fcc1, check_branch_fcc1_20
set 1, %l6
check_branch_fcc1_20:
udiv %l7, %l6, %l5

# Branch less or equal
set 0, %l6
fcmps %fcc1, %f0, %f1
fble %fcc1, check_branch_fcc1_21
set 1, %l6
check_branch_fcc1_21:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %fcc1, %f0, %f0
fbule %fcc1, check_branch_fcc1_22
set 1, %l6
check_branch_fcc1_22:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %fcc1, %f0, %f1
fbule %fcc1, check_branch_fcc1_23
set 1, %l6
check_branch_fcc1_23:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %fcc1, %f0, %f3
fbule %fcc1, check_branch_fcc1_24
set 1, %l6
check_branch_fcc1_24:
udiv %l7, %l6, %l5

# Branch ordered
set 0, %l6
fcmps %fcc1, %f0, %f0
fbo %fcc1, check_branch_fcc1_25
set 1, %l6
check_branch_fcc1_25:
udiv %l7, %l6, %l5


# Float branch test - fcc2

set 0x18, %l1

set 0x18, %l1

# Branch always
set 0, %l6
fcmps %fcc2, %f0, %f0
fba %fcc2, check_branch_fcc2_0
set 1, %l6
check_branch_fcc2_0:
udiv %l7, %l6, %l5

# Branch never
set 0, %l6
fcmps %fcc2, %f0, %f0
fbn %fcc2, check_branch_fcc2_1
set 1, %l6
check_branch_fcc2_1:
udiv %l7, %l6, %l5

# Branch unordered
set 0, %l6
fcmps %fcc2, %f3, %f3
fbu %fcc2, check_branch_fcc2_2
set 1, %l6
check_branch_fcc2_2:
udiv %l7, %l6, %l5

# Branch greater
set 0, %l6
fcmps %fcc2, %f1, %f0
fbg %fcc2, check_branch_fcc2_3
set 1, %l6
check_branch_fcc2_3:
udiv %l7, %l6, %l5

# Branch unordered or greater
set 0, %l6
fcmps %fcc2, %f1, %f0
fbug %fcc2, check_branch_fcc2_4
set 1, %l6
check_branch_fcc2_4:
udiv %l7, %l6, %l5

# Branch unordered or greater
set 0, %l6
fcmps %fcc2, %f3, %f3
fbug %fcc2, check_branch_fcc2_5
set 1, %l6
check_branch_fcc2_5:
udiv %l7, %l6, %l5

# Branch less
set 0, %l6
fcmps %fcc2, %f0, %f1
fbl %fcc2, check_branch_fcc2_6
set 1, %l6
check_branch_fcc2_6:
udiv %l7, %l6, %l5

# Branch unordered and less
set 0, %l6
fcmps %fcc2, %f0, %f1
fbul %fcc2, check_branch_fcc2_7
set 1, %l6
check_branch_fcc2_7:
udiv %l7, %l6, %l5

# Branch unordered and less
set 0, %l6
fcmps %fcc2, %f3, %f3
fbul %fcc2, check_branch_fcc2_8
set 1, %l6
check_branch_fcc2_8:
udiv %l7, %l6, %l5

# Branch less or greater
set 0, %l6
fcmps %fcc2, %f1, %f0
fblg %fcc2, check_branch_fcc2_9
set 1, %l6
check_branch_fcc2_9:
udiv %l7, %l6, %l5

# Branch less or greater
set 0, %l6
fcmps %fcc2, %f0, %f1
fblg %fcc2, check_branch_fcc2_10
set 1, %l6
check_branch_fcc2_10:
udiv %l7, %l6, %l5

# Branch not equal
set 0, %l6
fcmps %fcc2, %f2, %f0
fbne %fcc2, check_branch_fcc2_11
set 1, %l6
check_branch_fcc2_11:
udiv %l7, %l6, %l5

# Branch equal
set 0, %l6
fcmps %fcc2, %f0, %f0
fbe %fcc2, check_branch_fcc2_12
set 1, %l6
check_branch_fcc2_12:
udiv %l7, %l6, %l5

# Branch unordered or equal
set 0, %l6
fcmps %fcc2, %f3, %f0
fbue %fcc2, check_branch_fcc2_13
set 1, %l6
check_branch_fcc2_13:
udiv %l7, %l6, %l5

# Branch unordered or equal
set 0, %l6
fcmps %fcc2, %f0, %f0
fbue %fcc2, check_branch_fcc2_14
set 1, %l6
check_branch_fcc2_14:
udiv %l7, %l6, %l5

# Branch greater or equal
set 0, %l6
fcmps %fcc2, %f0, %f0
fbge %fcc2, check_branch_fcc2_15
set 1, %l6
check_branch_fcc2_15:
udiv %l7, %l6, %l5

# Branch greater or equal
set 0, %l6
fcmps %fcc2, %f0, %f2
fbge %fcc2, check_branch_fcc2_16
set 1, %l6
check_branch_fcc2_16:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %fcc2, %f0, %f0
fbuge %fcc2, check_branch_fcc2_17
set 1, %l6
check_branch_fcc2_17:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %fcc2, %f1, %f0
fbuge %fcc2, check_branch_fcc2_18
set 1, %l6
check_branch_fcc2_18:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %fcc2, %f1, %f3
fbuge %fcc2, check_branch_fcc2_19
set 1, %l6
check_branch_fcc2_19:
udiv %l7, %l6, %l5

# Branch less or equal
set 0, %l6
fcmps %fcc2, %f0, %f0
fble %fcc2, check_branch_fcc2_20
set 1, %l6
check_branch_fcc2_20:
udiv %l7, %l6, %l5

# Branch less or equal
set 0, %l6
fcmps %fcc2, %f0, %f1
fble %fcc2, check_branch_fcc2_21
set 1, %l6
check_branch_fcc2_21:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %fcc2, %f0, %f0
fbule %fcc2, check_branch_fcc2_22
set 1, %l6
check_branch_fcc2_22:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %fcc2, %f0, %f1
fbule %fcc2, check_branch_fcc2_23
set 1, %l6
check_branch_fcc2_23:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %fcc2, %f0, %f3
fbule %fcc2, check_branch_fcc2_24
set 1, %l6
check_branch_fcc2_24:
udiv %l7, %l6, %l5

# Branch ordered
set 0, %l6
fcmps %fcc2, %f0, %f0
fbo %fcc2, check_branch_fcc2_25
set 1, %l6
check_branch_fcc2_25:
udiv %l7, %l6, %l5


# Float branch test - fcc3

set 0x18, %l1

# Branch always
set 0, %l6
fcmps %fcc3, %f0, %f0
fba %fcc3, check_branch_fcc3_0
set 1, %l6
check_branch_fcc3_0:
udiv %l7, %l6, %l5

# Branch never
set 0, %l6
fcmps %fcc3, %f0, %f0
fbn %fcc3, check_branch_fcc3_1
set 1, %l6
check_branch_fcc3_1:
udiv %l7, %l6, %l5

# Branch unordered
set 0, %l6
fcmps %fcc3, %f3, %f3
fbu %fcc3, check_branch_fcc3_2
set 1, %l6
check_branch_fcc3_2:
udiv %l7, %l6, %l5

# Branch greater
set 0, %l6
fcmps %fcc3, %f1, %f0
fbg %fcc3, check_branch_fcc3_3
set 1, %l6
check_branch_fcc3_3:
udiv %l7, %l6, %l5

# Branch unordered or greater
set 0, %l6
fcmps %fcc3, %f1, %f0
fbug %fcc3, check_branch_fcc3_4
set 1, %l6
check_branch_fcc3_4:
udiv %l7, %l6, %l5

# Branch unordered or greater
set 0, %l6
fcmps %fcc3, %f3, %f3
fbug %fcc3, check_branch_fcc3_5
set 1, %l6
check_branch_fcc3_5:
udiv %l7, %l6, %l5

# Branch less
set 0, %l6
fcmps %fcc3, %f0, %f1
fbl %fcc3, check_branch_fcc3_6
set 1, %l6
check_branch_fcc3_6:
udiv %l7, %l6, %l5

# Branch unordered and less
set 0, %l6
fcmps %fcc3, %f0, %f1
fbul %fcc3, check_branch_fcc3_7
set 1, %l6
check_branch_fcc3_7:
udiv %l7, %l6, %l5

# Branch unordered and less
set 0, %l6
fcmps %fcc3, %f3, %f3
fbul %fcc3, check_branch_fcc3_8
set 1, %l6
check_branch_fcc3_8:
udiv %l7, %l6, %l5

# Branch less or greater
set 0, %l6
fcmps %fcc3, %f1, %f0
fblg %fcc3, check_branch_fcc3_9
set 1, %l6
check_branch_fcc3_9:
udiv %l7, %l6, %l5

# Branch less or greater
set 0, %l6
fcmps %fcc3, %f0, %f1
fblg %fcc3, check_branch_fcc3_10
set 1, %l6
check_branch_fcc3_10:
udiv %l7, %l6, %l5

# Branch not equal
set 0, %l6
fcmps %fcc3, %f2, %f0
fbne %fcc3, check_branch_fcc3_11
set 1, %l6
check_branch_fcc3_11:
udiv %l7, %l6, %l5

# Branch equal
set 0, %l6
fcmps %fcc3, %f0, %f0
fbe %fcc3, check_branch_fcc3_12
set 1, %l6
check_branch_fcc3_12:
udiv %l7, %l6, %l5

# Branch unordered or equal
set 0, %l6
fcmps %fcc3, %f3, %f0
fbue %fcc3, check_branch_fcc3_13
set 1, %l6
check_branch_fcc3_13:
udiv %l7, %l6, %l5

# Branch unordered or equal
set 0, %l6
fcmps %fcc3, %f0, %f0
fbue %fcc3, check_branch_fcc3_14
set 1, %l6
check_branch_fcc3_14:
udiv %l7, %l6, %l5

# Branch greater or equal
set 0, %l6
fcmps %fcc3, %f0, %f0
fbge %fcc3, check_branch_fcc3_15
set 1, %l6
check_branch_fcc3_15:
udiv %l7, %l6, %l5

# Branch greater or equal
set 0, %l6
fcmps %fcc3, %f0, %f2
fbge %fcc3, check_branch_fcc3_16
set 1, %l6
check_branch_fcc3_16:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %fcc3, %f0, %f0
fbuge %fcc3, check_branch_fcc3_17
set 1, %l6
check_branch_fcc3_17:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %fcc3, %f1, %f0
fbuge %fcc3, check_branch_fcc3_18
set 1, %l6
check_branch_fcc3_18:
udiv %l7, %l6, %l5

# Branch unordered or greater or equal
set 0, %l6
fcmps %fcc3, %f1, %f3
fbuge %fcc3, check_branch_fcc3_19
set 1, %l6
check_branch_fcc3_19:
udiv %l7, %l6, %l5

# Branch less or equal
set 0, %l6
fcmps %fcc3, %f0, %f0
fble %fcc3, check_branch_fcc3_20
set 1, %l6
check_branch_fcc3_20:
udiv %l7, %l6, %l5

# Branch less or equal
set 0, %l6
fcmps %fcc3, %f0, %f1
fble %fcc3, check_branch_fcc3_21
set 1, %l6
check_branch_fcc3_21:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %fcc3, %f0, %f0
fbule %fcc3, check_branch_fcc3_22
set 1, %l6
check_branch_fcc3_22:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %fcc3, %f0, %f1
fbule %fcc3, check_branch_fcc3_23
set 1, %l6
check_branch_fcc3_23:
udiv %l7, %l6, %l5

# Branch unordered or less or equal
set 0, %l6
fcmps %fcc3, %f0, %f3
fbule %fcc3, check_branch_fcc3_24
set 1, %l6
check_branch_fcc3_24:
udiv %l7, %l6, %l5

# Branch ordered
set 0, %l6
fcmps %fcc3, %f0, %f0
fbo %fcc3, check_branch_fcc3_25
set 1, %l6
check_branch_fcc3_25:
udiv %l7, %l6, %l5

# Nop slide
nop
nop
nop
nop
nop

# Some compare instructions for tracing.
fcmped %fcc1, %f32, %f32
fcmped %fcc1, %f32, %f34
fcmped %fcc1, %f34, %f32

# There seems to be a QEMU bug if the
# fcmpe instructions are not separated by nop.
# QEMU seems to deadlock (or the trace plugin).
# Might be related to tiny blocks, fcmpe or other reasons.
nop
nop
nop

fcmpes %fcc2, %f5, %f5
fcmpes %fcc2, %f5, %f5
fcmpes %fcc2, %f5, %f5

nop
nop
nop

done:
        ret
        restore
