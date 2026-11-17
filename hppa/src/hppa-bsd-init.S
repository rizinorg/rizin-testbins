; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
	.level 1.1
	.text
	.export init_hook,entry
	.type init_hook,@function
init_hook:
	bv %r0(%rp)
	nop

	.section .init_array,"aw",@init_array
	.word P%init_hook

	.section .note.openbsd.ident,"a",@note
	.align 4
	.word 8,4,1
	.string "OpenBSD"
	.word 0
