; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
;
; 05_status_data.asm -- TMS320C5x (real C5x object encoding) ACCB accumulator-buffer save/restore (SACB/EXAR/LACB).
;
; Assembled by tms320-rs asm. Data accesses write-then-read a high page so the
; Harvard core emulator and the address-aliased Rizin RzIL VM agree. Single-word
; ops with <=8-bit immediates so the instruction count equals the word count.

	ldp #0x4
	lacl #0x55
	sacl 0x10
	lacl #0xaa
	sacb
	lacl #0x10
	exar
	sacl 0x11
	lacb
	sacl 0x12
	lar ar2, #0x12
