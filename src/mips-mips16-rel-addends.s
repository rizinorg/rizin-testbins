# SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
# SPDX-License-Identifier: LGPL-3.0-only
#
# Implicit addends of MIPS16 REL relocations, assembled for both byte orders.
# The EXTEND prefix of an instruction holds the upper bits of its immediate.
#
#   mips-linux-gnu-as -mabi=32 -non_shared \
#     -o ../elf/mips-mips16-rel-addends.o mips-mips16-rel-addends.s
#   mipsel-linux-gnu-as -mabi=32 -non_shared \
#     -o ../elf/mipsel-mips16-rel-addends.o mips-mips16-rel-addends.s

	.set	noreorder
	.set	mips16

	.text
	.globl	_start
	.ent	_start
_start:
	jal	ext_func
	nop
	jal	ext_func + 0x40
	nop
	li	$4, %hi(ext_data + 0x12345)
	sll	$4, 16
	addiu	$4, %lo(ext_data + 0x12345)
	li	$5, %hi(ext_data - 0x8000)
	sll	$5, 16
	lw	$5, %lo(ext_data - 0x8000)($5)
	b	ext_func + 0x10
	beqz	$4, ext_func - 0x10
	jr	$31
	nop
	.end	_start

	.data
	.word	ext_data + 0x20
