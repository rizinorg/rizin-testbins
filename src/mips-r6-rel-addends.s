# SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
# SPDX-License-Identifier: LGPL-3.0-only
#
# Implicit addends of the PC-relative REL relocations of MIPS Release 6,
# each one distinct.
#
#   mipsisa32r6-linux-gnu-as -mabi=32 -march=mips64r6 -non_shared \
#     -o ../elf/mips-r6-rel-addends.o mips-r6-rel-addends.s

	.set	noreorder

	.text
	.globl	_start
_start:
	balc	ext_func
	balc	ext_func + 0x40
	bc	ext_func - 0x20
	beqzc	$4, ext_func + 0x10
	bnezc	$5, ext_func - 8
	beqc	$4, $5, ext_func + 8
	lwpc	$6, ext_data + 0x10
	.reloc	., R_MIPS_PC19_S2, ext_data
	addiupc	$7, -0x20
	# The halves pair like R_MIPS_HI16 and R_MIPS_LO16.
	auipc	$8, %pcrel_hi(ext_data + 0x12345)
	addiu	$8, $8, %pcrel_lo(ext_data + 0x12349)
	auipc	$9, %pcrel_hi(ext_data - 0x8000)
	addiu	$9, $9, %pcrel_lo(ext_data - 0x7ffc)
	auipc	$10, %pcrel_hi(ext_data + 0x7ffc)
	lw	$10, %pcrel_lo(ext_data + 0x8000)($10)
	# LDPC loads from the doubleword-aligned PC.
	ldpc	$11, dw_data + 0x10
	ldpc	$12, dw_data - 0x18
	jrc	$31

	.section .rodata
	.align	3
	.space	0x20
dw_data:
	.dword	0

	.data
	.word	0
	.word	ext_data - . + 0x10
	.word	ext_func - .
