; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
;
; 10_full_program.asm -- TMS320C5x (real C5x object encoding) mixed program (arithmetic + multiply + logic + shift).
;
; Assembled by tms320-rs asm. Data accesses write-then-read a high page so the
; Harvard core emulator and the address-aliased Rizin RzIL VM agree. Single-word
; ops with <=8-bit immediates so the instruction count equals the word count.

	ldp #0x4
	lacl #0x10
	sacl 0x10
	lacl #0x2
	add #0x3
	sacl 0x11
	lt 0x10
	mpy 0x11
	pac
	sfl
	and 0x10
	or 0x11
	sacl 0x12
	lacl #0xf
	xor 0x10
	sub #0x1
	lar ar2, #0x25
