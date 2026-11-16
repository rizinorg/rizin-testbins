# SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
# SPDX-License-Identifier: LGPL-3.0-only
#
# Implicit addends of i386 REL relocations, each one distinct.
#
#   as --32 -o ../elf/x86-rel-addends.o x86-rel-addends.s

	.text
	.globl	_start
_start:
	call	ext_func
	call	ext_func@PLT
	jmp	ext_func + 0x10
	movl	$ext_data + 0x1234, %eax
	movl	$local_data + 8, %eax
	movl	ext_data@GOT(%ebx), %eax
	movl	ext_data@GOT + 4(%ebx), %eax
	leal	local_data@GOTOFF + 4(%ebx), %eax
	addl	$_GLOBAL_OFFSET_TABLE_, %ebx
	movw	$ext_data + 2, %ax
	movb	$ext_data + 1, %al
	movl	%gs:tls_var@ntpoff + 4, %eax
	leal	tls_var@tlsgd(, %ebx, 1), %eax
	leal	tls_var@tlsldm(%ebx), %eax
	leal	tls_var@dtpoff + 8(%eax), %edx
	movl	tls_var@gotntpoff(%ebx), %eax
	movl	tls_var@indntpoff, %eax
	movl	tls_var@gottpoff(%ebx), %eax
	movl	$tls_var@tpoff + 12, %eax
	leal	tls_var@tlsdesc(%ebx), %eax
	# The relocation is on the opcode, which is no addend.
	call	*tls_var@tlscall(%eax)

	.data
local_data:
	.long	0
	.long	ext_data - 8
	.word	ext_data + 0x7ffe
	.byte	ext_data + 0x7f
	.long	ext_func - .
	.long	ext_func - . + 0x100
	.word	ext_func - .
	.byte	ext_func - .
	.long	local_data@GOTOFF + 0x20
	.long	ext_data@SIZE + 4
