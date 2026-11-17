# SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
# SPDX-License-Identifier: LGPL-3.0-only
#
# Implicit addends of o32 REL relocations, assembled for both byte orders.
# Each relocation has a distinct addend, so that a field read from the wrong
# bytes, an addend applied twice or a lost high half shows in the result.
#
#   mips-linux-gnu-as -mabi=32 -march=mips32 -non_shared -G 8 \
#     -o ../elf/mips-rel-addends.o mips-rel-addends.s
#   mipsel-linux-gnu-as -mabi=32 -march=mips32 -non_shared -G 8 \
#     -o ../elf/mipsel-rel-addends.o mips-rel-addends.s

	.set	noreorder
	.set	nomacro

	.text
	.globl	_start
	.ent	_start
_start:
	# The low half of the addend is negative, so the high half rounds up.
	lui	$4, %hi(ext_data + 0x18000)
	addiu	$4, $4, %lo(ext_data + 0x18000)
	# One HI16 shared by two LO16, each with its own offset.
	lui	$5, %hi(local_data + 0x10)
	lw	$6, %lo(local_data + 0x10)($5)
	lw	$7, %lo(local_data + 0x14)($5)
	lui	$8, %hi(ext_data - 4)
	addiu	$8, $8, %lo(ext_data - 4)
	# gas moves each HI16 right before its LO16.
	lui	$10, %hi(ext_data + 0x7fff)
	lui	$11, %hi(ext_data + 0x8000)
	addiu	$10, $10, %lo(ext_data + 0x7fff)
	addiu	$11, $11, %lo(ext_data + 0x8000)
	jal	ext_func
	nop
	jal	ext_func + 0x40
	nop
	jal	local_func
	nop
	b	ext_func
	nop
	bal	ext_func + 8
	nop
	# GP, GOT and TLS relative fields depend on a layout an object does not have.
	lw	$9, %gp_rel(small_data + 4)($28)
	lw	$2, %got(local_data + 0x12340)($28)
	addiu	$2, $2, %lo(local_data + 0x12340)
	lw	$3, %got(ext_data + 4)($28)
	lw	$25, %call16(ext_func)($28)
	.reloc	1f, R_MIPS_JALR, ext_func
1:	jalr	$25
	nop
	lw	$12, %got_disp(ext_data + 8)($28)
	lui	$13, %tprel_hi(tls_var + 0x10)
	addiu	$13, $13, %tprel_lo(tls_var + 0x10)
	lui	$14, %dtprel_hi(tls_var + 0x20)
	addiu	$14, $14, %dtprel_lo(tls_var + 0x20)
	lw	$15, %gottprel(tls_var + 4)($28)
	addiu	$4, $28, %tlsgd(tls_var)
	addiu	$4, $28, %tlsldm(tls_var)
	jr	$31
	nop
	.end	_start

	.ent	local_func
local_func:
	jr	$31
	nop
	.end	local_func

	# Fields and relocations set by hand, as gas pairs the ones it makes.
	.section .text.ahl, "ax"
	# Two HI16 sharing one LO16: AHL 0x8000 for all three.
a1:	.word	0x3c040001
	.reloc	a1, R_MIPS_HI16, sym_a
a2:	.word	0x3c050001
	.reloc	a2, R_MIPS_HI16, sym_a
a3:	.word	0x24848000
	.reloc	a3, R_MIPS_LO16, sym_a
	# The 32-bit sum wraps: 0x7fff8000.
c1:	.word	0x3c098000
	.reloc	c1, R_MIPS_HI16, sym_c
c2:	.word	0x25298000
	.reloc	c2, R_MIPS_LO16, sym_c
	# A HI16 without LO16: 0x20000.
d1:	.word	0x3c0a0002
	.reloc	d1, R_MIPS_HI16, sym_d
	# A LO16 without HI16: -0x7ffc.
e1:	.word	0x254a8004
	.reloc	e1, R_MIPS_LO16, sym_e
	# The HI16 of sym_f is in .text.other, so this LO16 is alone: 0x10.
f2:	.word	0x256b0010
	.reloc	f2, R_MIPS_LO16, sym_f
	# -0x12345
g1:	.word	0x3c0cffff
	.reloc	g1, R_MIPS_HI16, sym_g
g2:	.word	0x258cdcbb
	.reloc	g2, R_MIPS_LO16, sym_g
	# A local jump target past 128MB is not sign-extended: 0x9000000.
h1:	.word	0x0e400000
	.reloc	h1, R_MIPS_26, .text
	# An external one is: -8.
i1:	.word	0x0ffffffe
	.reloc	i1, R_MIPS_26, ext_func

	.section .text.other, "ax"
f1:	.word	0x3c0b0005
	.reloc	f1, R_MIPS_HI16, sym_f

	.data
local_data:
	.word	0, 1, 2, 3, 4, 5, 6, 7
	.word	ext_data + 0x100
	.word	local_data + 8
	.word	ext_data - 0x10
	.word	local_func + 4
	.word	ext_data - . + 0x10
	# A halfword of data, followed by a guard.
r16:	.half	0x7ff0, 0x1234
	.reloc	r16, R_MIPS_16, ext_data
gp32:	.word	0x30
	.reloc	gp32, R_MIPS_GPREL32, .text

	.sdata
small_data:
	.word	1, 2, 3

	.section .tbss, "awT", @nobits
tls_var:
	.space	0x40
