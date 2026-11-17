# SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
# SPDX-License-Identifier: LGPL-3.0-only
#
# Implicit addends of microMIPS REL relocations, assembled for both byte
# orders. A 32-bit microMIPS instruction is two halfwords, the first one with
# the opcode, whatever the byte order.
#
#   mips-linux-gnu-as -mabi=32 -non_shared -mmicromips \
#     -o ../elf/mips-micromips-rel-addends.o mips-micromips-rel-addends.s
#   mipsel-linux-gnu-as -mabi=32 -non_shared -mmicromips \
#     -o ../elf/mipsel-micromips-rel-addends.o mips-micromips-rel-addends.s

	.set	noreorder

	.text
	.globl	_start
	.ent	_start
_start:
	jal	ext_func
	nop
	jal	ext_func + 0x40
	nop
	lui	$4, %hi(ext_data + 0x12345)
	addiu	$4, $4, %lo(ext_data + 0x12345)
	lui	$5, %hi(ext_data - 0x8000)
	lw	$5, %lo(ext_data - 0x8000)($5)
	b	ext_func + 0x10
	nop
	beqz	$4, ext_func - 0x10
	nop
	b16	near_func + 0x20
	nop
	beqz16	$4, near_func + 8
	nop
	# Code labels are odd, so place the relocation one byte before.
	.reloc	. - 1, R_MICROMIPS_PC23_S2, ext_data
	addiupc	$2, 0x10
	nop16
	.reloc	. - 1, R_MICROMIPS_PC23_S2, ext_data
	addiupc	$3, -0x20
	jr	$31
	nop
	.end	_start

	.globl	near_func
	.ent	near_func
near_func:
	jr	$31
	nop
	.end	near_func

	.data
	.word	ext_data + 0x20
