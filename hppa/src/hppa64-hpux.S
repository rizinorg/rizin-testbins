; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
	.level 2.0w
	.text
	.import imported,code
	.type imported,@function
	.export hook,entry
	.type hook,@function
hook:
	std %rp,-16(%sp)
	b,l imported,%rp
	nop
	ldd -16(%sp),%rp
	bve (%rp)
	nop

	.section .init_array,"aw",@init_array
	.align 8
	.dword P%hook

	.data
	.align 8
	.dword P%hook
