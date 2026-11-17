; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only

; .Lnext has no reference and follows a call to .Lfail, which only the
; propagation of noreturn from exit shows to never return.

	.text
	.globl _start
	.type _start,@function
_start:
	stw %rp,-20(%sp)
	b,l .Lfail,%rp
	ldo 64(%sp),%sp
	nop
.Lnext:
	stw %rp,-20(%sp)
	ldo 64(%sp),%sp
	bv %r0(%rp)
	ldo -64(%sp),%sp
.Lfail:
	stw %rp,-20(%sp)
	ldo 64(%sp),%sp
	b,l exit,%rp
	ldi 1,%r26
