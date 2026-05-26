;
; 02_logic_shifts.s — Logical operations, bit manipulation, and shifts.
;
; assemble with:
;   tic54x-coff-as -o 02_logic_shifts.o 02_logic_shifts.s
; Exercises:
;   - AND/OR/XOR with immediate, memory, and accumulator operands
;   - SFTA (arithmetic), SFTL (logical), SFTC (cascade)
;   - ROL/ROR rotate-with-carry
;   - BIT (bit test fixed index), BITF (bit field test), BITT (T-driven)
;   - CMPL complement, CMPM compare-with-immediate-memory
;   - Status bit setting/clearing: SSBX, RSBX
;
	.mmregs
	.bss	work_a,  16
	.bss	work_b,  16
	.bss	scratch, 4

	.global _popcount
	.global _bitreverse
	.global _bitfield_extract
	.global _ror_chain
	.global _xor_fold
	.global _logical_demo

	.text

; ---------------------------------------------------------------------
; popcount(*p) — count set bits in *AR2, returns count in B.lo
;   Uses BIT instruction with fixed bit indices 0..15 (the unrolled
;   form a compiler might emit).
; ---------------------------------------------------------------------
_popcount:
	ld	#0, b
	bit	*AR2, 0			; TC = bit 0 of *AR2
	xc	1, tc
	add	#1, b
	bit	*AR2, 1
	xc	1, tc
	add	#1, b
	bit	*AR2, 2
	xc	1, tc
	add	#1, b
	bit	*AR2, 3
	xc	1, tc
	add	#1, b
	bit	*AR2, 4
	xc	1, tc
	add	#1, b
	bit	*AR2, 5
	xc	1, tc
	add	#1, b
	bit	*AR2, 6
	xc	1, tc
	add	#1, b
	bit	*AR2, 7
	xc	1, tc
	add	#1, b
	bit	*AR2, 8
	xc	1, tc
	add	#1, b
	bit	*AR2, 9
	xc	1, tc
	add	#1, b
	bit	*AR2, 10
	xc	1, tc
	add	#1, b
	bit	*AR2, 11
	xc	1, tc
	add	#1, b
	bit	*AR2, 12
	xc	1, tc
	add	#1, b
	bit	*AR2, 13
	xc	1, tc
	add	#1, b
	bit	*AR2, 14
	xc	1, tc
	add	#1, b
	bit	*AR2, 15
	xc	1, tc
	add	#1, b
	ret

; ---------------------------------------------------------------------
; bitreverse(*src, *dst) — reverse the 16 bits of *AR2 into *AR3
; ---------------------------------------------------------------------
_bitreverse:
	ld	*AR2, a			; A = input
	ld	#0, b			; B = result
	stm	#15, BRC
	rptb	br_end-1
	sftl	b, 1			; B <<= 1
	sftc	a			; flag-based; not ideal but exercises SFTC
	rol	a			; rotate A; LSB goes to C
	xc	1, c			; if carry, add 1 to B
	or	#1, b
br_end:
	stl	b, *AR3
	ret

; ---------------------------------------------------------------------
; bitfield_extract(*p) — extract bits [11:4] of *AR2 into A.lo
; ---------------------------------------------------------------------
_bitfield_extract:
	ld	*AR2, a			; load word
	and	#0x0FF0, a		; mask bits [11:4]
	sftl	a, -4			; shift right 4
	stl	a, *AR3
	ret

; ---------------------------------------------------------------------
; ror_chain(*p, n in BRC) — rotate-right each word of buffer by 1
; ---------------------------------------------------------------------
_ror_chain:
	rsbx	c			; clear carry
	rptb	rc_end-1
	ld	*AR2, a
	ror	a			; rotate A right through carry
	stl	a, *AR2+
rc_end:
	ret

; ---------------------------------------------------------------------
; xor_fold(*p, n in BRC) — XOR all words at *AR2 into a single result
; ---------------------------------------------------------------------
_xor_fold:
	ld	#0, a
	rptb	xf_end-1
	xor	*AR2+, a
xf_end:
	stl	a, *AR3
	ret

; ---------------------------------------------------------------------
; logical_demo — flexes the full logical/shift instruction set
;   Designed so each instruction is distinct, to give the disassembler
;   maximum opcode variety in one function.
; ---------------------------------------------------------------------
_logical_demo:
	ld	#0xAA55, a		; load immediate
	or	#0x0F0F, a		; OR immediate
	and	#0xFFF0, a		; AND immediate
	xor	#0xCCCC, a		; XOR immediate
	cmpl	a			; A = ~A
	or	#0x0001, 4, a, b	; B = A | (1 << 4)
	andm	#0x00FF, *AR2		; *AR2 &= 0x00FF
	orm	#0xFF00, *AR3		; *AR3 |= 0xFF00
	xorm	#0xAAAA, *AR4		; *AR4 ^= 0xAAAA
	ld	#0x1234, a
	rol	a			; rotate left through C
	rol	a
	rol	a
	ror	a
	sftc	a			; conditional left shift
	sfta	a, 4			; arithmetic left 4
	sfta	a, -8			; arithmetic right 8 (sign extends)
	sftl	a, 4			; logical left 4
	sftl	a, -4			; logical right 4
	bit	*AR2, 12		; TC = bit 12 of *AR2
	bitf	*AR3, #0xF000		; TC = (*AR3 & 0xF000) != 0
	cmpm	*AR4, #0x1000		; TC = (*AR4 == 0x1000)
	cmps	a, *AR2			; min/max-store of A halves
	ssbx	sxm			; set sign-extension mode
	rsbx	sxm			; clear it
	ssbx	ovm			; set overflow mode (saturation)
	rsbx	ovm
	ssbx	c			; set carry
	rsbx	c			; clear carry
	ret

	.end
