; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
;
; 02_logic_shifts.asm -- TMS320C5x (real C5x object encoding) logical ops and shifts (AND/OR/XOR, SFL/SFR).
;
; Assembled by tms320-rs asm. Data accesses write-then-read a high page so the
; Harvard core emulator and the address-aliased Rizin RzIL VM agree. Single-word
; ops with <=8-bit immediates so the instruction count equals the word count.

	ldp #0x4
	lacl #0x33
	sacl 0x10
	lacl #0x0f
	and 0x10
	sacl 0x11
	lacl #0xf0
	or 0x10
	sacl 0x12
	xor 0x11
	sfl
	sfl
	sfr
	lar ar2, #0x66
