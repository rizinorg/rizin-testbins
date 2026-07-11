; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
;
; 03_branches_calls.asm -- TMS320C5x (real C5x object encoding) control flow (forward B skips the dead block).
;
; Assembled by tms320-rs asm. Data accesses write-then-read a high page so the
; Harvard core emulator and the address-aliased Rizin RzIL VM agree. Single-word
; ops with <=8-bit immediates so the instruction count equals the word count.

	ldp #0x4
	lacl #0x7
	sacl 0x10
	b 0x8
	lacl #0xff
	sacl 0x10
	lacl #0x3
	add 0x10
	sacl 0x11
	lar ar2, #0x40
