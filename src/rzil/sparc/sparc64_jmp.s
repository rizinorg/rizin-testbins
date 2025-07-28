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
 * i0-i4: 32bit math oprands
 * o0-o4: 64bit math oprands
 */

.include "data64_const.s"

.align 16
.section ".text"
    .global test_branches

check_branch:
        # The udiv will throw an exception if l6 is 0
        # The whole test should run without exception
        udivx %l7, %l6, %l5
        jmpl %l0, %g0
        nop

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

# Offset to next test
set 0x18, %l1
# Dividend. Divisor is in l6.
set 1, %l7

# Set divisor which triggers exception
set 0, %l6
# Set address to next valid test
rd %pc, %l0
add %l0, %l1, %l0
# Do comparison/Set icc bits
wr %g0, 0, %ccr
ba %icc, check_branch
set 1, %l6
# Is only reached if branch was (incorrectly) not taken.
set 0, %l6
udiv %l7, %l6, %l5

# Branch Never
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
wr %g0, 0, %ccr
bn %icc, check_branch
set 1, %l6
nop
udiv %l7, %l6, %l5

# Branch not equal (not Z)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
orcc %g0, %l1, %l1
bne %icc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch equal (Z)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
andcc %g0, %l1, %g0
be %icc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch greater (not (Z or (N xor V)))
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
cmp %i0, %g0
bg %icc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch less equal (Z or (N xor V))
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
cmp %g0, %g0
ble %icc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch greater equal (not (N xor V))
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
cmp %g0, %g0
bge %icc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch less (N xor V)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
cmp %i1, %g0
bl %icc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch greater unsigned (not (C or Z))
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
cmp %i0, %g0
bgu %icc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch less equal unsigned (C or Z)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
cmp %g0, %i0
bleu %icc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch carry clear (not C)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
addcc %i0, %i0, %i4
bcc %icc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch on carry (C)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
addcc %i1, %i1, %i4
bcs %icc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch on positive (not N)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
addcc %i0, %i0, %i4
bpos %icc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch on negative (N)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
addcc %i1, %i1, %i4
bneg %icc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch overflow clear (not V)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
addcc %i0, %i0, %i4
bvc %icc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch one overflow (V)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
addcc %i3, %i0, %i4
bvs %icc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

#
# Annul bits
#

set 1, %l6
# Offset to next test
set 0x14, %l1

# Branch Never
rd %pc, %l0
add %l0, %l1, %l0
nop
bn,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch not equal (not Z)
rd %pc, %l0
add %l0, %l1, %l0
andcc %g0, %l1, %g0
bne,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch equal (Z)
rd %pc, %l0
add %l0, %l1, %l0
andcc %l1, %l1, %l1
be,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch greater (not (Z or (N xor V)))
rd %pc, %l0
add %l0, %l1, %l0
cmp %g0, %i0
bg,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch less equal (Z or (N xor V))
rd %pc, %l0
add %l0, %l1, %l0
cmp %i0, %g0
ble,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch greater equal (not (N xor V))
rd %pc, %l0
add %l0, %l1, %l0
cmp %g0, %i0
bge,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch less (N xor V)
rd %pc, %l0
add %l0, %l1, %l0
cmp %i0, %g0
bl,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch greater unsigned (not (C or Z))
rd %pc, %l0
add %l0, %l1, %l0
cmp %g0, %g0
bgu,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch less equal unsigned (C or Z)
rd %pc, %l0
add %l0, %l1, %l0
cmp %i1, %g0
bleu,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch carry clear (not C)
rd %pc, %l0
add %l0, %l1, %l0
addcc %i1, %i0, %i4
bcc,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch on carry (C)
rd %pc, %l0
add %l0, %l1, %l0
addcc %i0, %i0, %i4
bcs,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch on positive (not N)
rd %pc, %l0
add %l0, %l1, %l0
addcc %i1, %i1, %i4
bpos,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch on negative (N)
rd %pc, %l0
add %l0, %l1, %l0
addcc %i0, %i0, %i4
bneg,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch overflow clear (not V)
rd %pc, %l0
add %l0, %l1, %l0
addcc %i3, %i0, %i4
bvc,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch one overflow (V)
rd %pc, %l0
add %l0, %l1, %l0
addcc %i0, %i0, %i4
bvs,a %icc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

#
# 64bit branches
#

# Offset to next test
set 0x18, %l1
# Dividend. Divisor is in l6.
set 1, %l7

# Set divisor which triggers exception
set 0, %l6
# Set address to next valid test
rd %pc, %l0
add %l0, %l1, %l0
# Do comparison/Set icc bits
wr %g0, 0, %ccr
ba %xcc, check_branch
set 1, %l6
# Is only reached if branch was (incorrectly) not taken.
set 0, %l6
udiv %l7, %l6, %l5

# Branch Never
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
wr %g0, 0, %ccr
bn %xcc, check_branch
set 1, %l6
nop
udiv %l7, %l6, %l5

# Branch not equal (not Z)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
orcc %g0, %l1, %l1
bne %xcc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch equal (Z)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
andcc %g0, %l1, %g0
be %xcc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch greater (not (Z or (N xor V)))
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
cmp %o0, %g0
bg %xcc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch less equal (Z or (N xor V))
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
cmp %g0, %g0
ble %xcc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch greater equal (not (N xor V))
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
cmp %g0, %g0
bge %xcc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch less (N xor V)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
cmp %o1, %g0
bl %xcc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch greater unsigned (not (C or Z))
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
cmp %o0, %g0
bgu %xcc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch less equal unsigned (C or Z)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
cmp %g0, %o0
bleu %xcc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch carry clear (not C)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
addcc %o0, %o0, %o4
bcc %xcc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch on carry (C)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
addcc %o1, %o1, %o4
bcs %xcc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch on positive (not N)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
addcc %o0, %o0, %o4
bpos %xcc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch on negative (N)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
addcc %o1, %o1, %o4
bneg %xcc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch overflow clear (not V)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
addcc %o0, %o0, %o4
bvc %xcc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Branch one overflow (V)
set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
addcc %o3, %o0, %o4
bvs %xcc, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

#
# 64bit Annul bits
#

set 1, %l6
# Offset to next test
set 0x14, %l1

# Branch Never
rd %pc, %l0
add %l0, %l1, %l0
nop
bn,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch not equal (not Z)
rd %pc, %l0
add %l0, %l1, %l0
andcc %g0, %l1, %g0
bne,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch equal (Z)
rd %pc, %l0
add %l0, %l1, %l0
andcc %l1, %l1, %l1
be,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch greater (not (Z or (N xor V)))
rd %pc, %l0
add %l0, %l1, %l0
cmp %g0, %o0
bg,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch less equal (Z or (N xor V))
rd %pc, %l0
add %l0, %l1, %l0
cmp %o0, %g0
ble,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch greater equal (not (N xor V))
rd %pc, %l0
add %l0, %l1, %l0
cmp %g0, %o0
bge,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch less (N xor V)
rd %pc, %l0
add %l0, %l1, %l0
cmp %o0, %g0
bl,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch greater unsigned (not (C or Z))
rd %pc, %l0
add %l0, %l1, %l0
cmp %g0, %g0
bgu,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch less equal unsigned (C or Z)
rd %pc, %l0
add %l0, %l1, %l0
cmp %o1, %g0
bleu,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch carry clear (not C)
rd %pc, %l0
add %l0, %l1, %l0
addcc %o1, %o0, %o4
bcc,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch on carry (C)
rd %pc, %l0
add %l0, %l1, %l0
addcc %o0, %o0, %o4
bcs,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch on positive (not N)
rd %pc, %l0
add %l0, %l1, %l0
addcc %o1, %o1, %o4
bpos,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch on negative (N)
rd %pc, %l0
add %l0, %l1, %l0
addcc %o0, %o0, %o4
bneg,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch overflow clear (not V)
rd %pc, %l0
add %l0, %l1, %l0
addcc %o3, %o0, %o4
bvc,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Branch one overflow (V)
rd %pc, %l0
add %l0, %l1, %l0
addcc %o0, %o0, %o4
bvs,a %xcc, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Register conditional branches

# Offset to next test
set 0x18, %l1

clr %i0

set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
nop
brz %i0, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
nop
brlez %i0, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
nop
brlez %o1, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
nop
brlz %o1, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
nop
brnz %o1, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
nop
brgz %o3, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
nop
brgez %o3, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

set 0, %l6
rd %pc, %l0
add %l0, %l1, %l0
nop
brgez %i0, check_branch
set 1, %l6
set 0, %l6
udiv %l7, %l6, %l5

# Annulled

# Offset to next test
set 0x14, %l1

set 1, %l6

rd %pc, %l0
add %l0, %l1, %l0
nop
brz,a %i1, check_branch
set 0, %l6
udiv %l7, %l6, %l5

rd %pc, %l0
add %l0, %l1, %l0
nop
brlez,a %i3, check_branch
set 0, %l6
udiv %l7, %l6, %l5

rd %pc, %l0
add %l0, %l1, %l0
nop
brlz,a %o3, check_branch
set 0, %l6
udiv %l7, %l6, %l5

rd %pc, %l0
add %l0, %l1, %l0
nop
brnz,a %i0, check_branch
set 0, %l6
udiv %l7, %l6, %l5

rd %pc, %l0
add %l0, %l1, %l0
nop
brgz,a %o1, check_branch
set 0, %l6
udiv %l7, %l6, %l5

rd %pc, %l0
add %l0, %l1, %l0
nop
brgez,a %o1, check_branch
set 0, %l6
udiv %l7, %l6, %l5

# Nop slide
nop
nop
nop
nop
nop
nop

done:
        ret
