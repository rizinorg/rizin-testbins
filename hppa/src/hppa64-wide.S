; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
	.level 2.0w
	.text
	.globl _start
_start:
	std %rp,-16(%sp)
	ldo 0x7000(%r1),%r2
	b,l f,%rp
	nop
	bve,n (%rp)
f:	bve (%rp)
	nop
