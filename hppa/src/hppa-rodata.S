; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only

; .rodata shares the executable segment with .text and holds a word
; decoding as a call to the middle of _start.

	.text
	.globl _start
	.type _start,@function
_start:
	stw %rp,-20(%sp)
	ldi 1,%r26
	ldi 2,%r25
	ldi 3,%r24
	bv %r0(%rp)
	nop

	.section .rodata
	.word 0xe85f1fd5
