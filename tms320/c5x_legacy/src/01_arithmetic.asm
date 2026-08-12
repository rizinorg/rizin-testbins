; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
;
; 01_arithmetic.asm -- TMS320C5x (real C5x object encoding) arithmetic and load/store (immediate/add-with-shift, LT/MPY/PAC product chain).
;
; Assembled by tms320-rs asm. Data accesses write-then-read a high page so the
; Harvard core emulator and the address-aliased Rizin RzIL VM agree. Single-word
; ops with <=8-bit immediates so the instruction count equals the word count.

	ldp #0x4
	lacl #0x21
	sacl 0x10
	lacl #0x12
	add #0x21
	sacl 0x11
	lt 0x10
	mpy 0x11
	pac
	add 0x10, 4
	sub #0x5
	sacl 0x12
	lar ar2, #0x11
