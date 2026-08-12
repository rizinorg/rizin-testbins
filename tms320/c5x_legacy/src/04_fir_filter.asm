; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
;
; 04_fir_filter.asm -- TMS320C5x (real C5x object encoding) FIR dot-product (MAC chain via LT/MPY/PAC/APAC).
;
; Assembled by tms320-rs asm. Data accesses write-then-read a high page so the
; Harvard core emulator and the address-aliased Rizin RzIL VM agree. Single-word
; ops with <=8-bit immediates so the instruction count equals the word count.

	ldp #0x4
	lacl #0x3
	sacl 0x10
	lacl #0x5
	sacl 0x11
	lacl #0x7
	sacl 0x12
	lt 0x10
	mpy 0x10
	pac
	lt 0x11
	mpy 0x11
	apac
	lt 0x12
	mpy 0x12
	apac
	lar ar2, #0x53
