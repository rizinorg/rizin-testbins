;
; 06_parallel_dual.s — Parallel and dual-operand instructions.
;
; assemble with:
;   tic54x-coff-as -o 06_parallel_dual.o 06_parallel_dual.s
; The C54x has several pseudo-parallel instructions that execute two
; operations in one cycle by using the Xmem and Ymem data buses
; simultaneously. These are syntactically written with `||` between
; the two operations. A disassembler should display them as a single
; word with two semicolon-separated mnemonics.
;
; Pairs supported by binutils gas (from tic54x_paroptab):
;   LD Xmem, DST || MAC  Ymem, DST   (MACR / MAS / MASR variants)
;   ST SRC, Ymem || ADD  Xmem, DST
;   ST SRC, Ymem || LD   Xmem, DST   (or T)
;   ST SRC, Ymem || MAC  Xmem, DST   (MACR / MAS / MASR / MPY / SUB)
;
; Also exercises dual-Xmem/Ymem instructions like ADD Xmem,Ymem,DST.
;
	.mmregs
	.bss	delay_a,  32		; delay-line buffer A
	.bss	delay_b,  32		; delay-line buffer B
	.bss	xy_out,   16

	.data
filter_h:
	.word	0x0100, 0x0200, 0x0400, 0x0800
	.word	0x1000, 0x2000, 0x4000, 0x2000
	.word	0x1000, 0x0800, 0x0400, 0x0200

	.global _parallel_mac
	.global _parallel_store_add
	.global _parallel_store_mpy
	.global _dual_xy
	.global _butterfly
	.global _mac_with_store

	.text

; ---------------------------------------------------------------------
; parallel_mac(*x, *h, *y) — FIR with LD||MAC parallel form
;   AR2 = x, AR3 = h, AR4 = y
;   Each cycle: load *AR2 into B  AND  multiply-accumulate *AR3 into A
; ---------------------------------------------------------------------
_parallel_mac:
	ld	*AR2+, b		; prime: load first x sample
	ld	#0, a			; clear accumulator
	rpt	#7
	ld	*AR2+, b || mac	*AR3+, a	; parallel: load next, MAC prev
	nop				; non-repeated trailer
	sth	a, *AR4
	ret

; ---------------------------------------------------------------------
; parallel_store_add(*x, *y, *out) — interleaved store + add
;   ST A, *AR4 || ADD *AR2, A  (writes prev result while adding next)
; ---------------------------------------------------------------------
_parallel_store_add:
	ld	*AR2+, a		; A = x[0]
	ld	#0, b
	rpt	#7
	st	a, *AR4+ || add	*AR2+, a	; store A then add new sample
	nop
	ret

; ---------------------------------------------------------------------
; parallel_store_mpy(*x, *y, *coef) — store accumulator + multiply
;   ST A, *AR4 || MPY *AR2, A
; ---------------------------------------------------------------------
_parallel_store_mpy:
	ld	*AR3, t			; T = coefficient
	rpt	#15
	st	a, *AR4+ || mpy	*AR2+, a	; store old, multiply new
	nop
	ret

; ---------------------------------------------------------------------
; dual_xy(*x, *y, *out) — pure dual-operand MAC (no parallel)
;   MAC *AR2, *AR3, A  — uses Xmem AND Ymem simultaneously
; ---------------------------------------------------------------------
_dual_xy:
	ld	#0, a
	stm	#15, BRC
	rptb	dxy_end-1
	mac	*AR2+, *AR3+, a		; dual: both buses, both increment
dxy_end:
	stl	a, *AR4
	ret

; ---------------------------------------------------------------------
; butterfly — DFT-like radix-2 butterfly
;   (out0, out1) = (a + b*w, a - b*w) for complex a, b, twiddle w
;   We do real part only for simplicity.
; ---------------------------------------------------------------------
_butterfly:
	; load b into B, w into T, a into A
	ld	*AR3, b
	ld	*AR5, t
	ld	*AR2, a
	mpy	*AR5+, b		; B = b * w  (T * Xmem, into B)
	; We can't easily do A+B and A-B both at once. Spill A first.
	sth	a, *AR6			; save A.hi via scratch
	add	b, a			; A = A + B  (acc-to-acc add)
	sth	a, *AR4+		; out[0] = A + B*w
	ld	*AR6, a			; restore A
	sub	b, a			; A = A - B  (acc-to-acc sub)
	sth	a, *AR4+		; out[1] = A - B*w
	ret

; ---------------------------------------------------------------------
; mac_with_store — LD||MAC running tap loop with delayed store at end
; ---------------------------------------------------------------------
_mac_with_store:
	stm	#delay_a, AR2
	stm	#delay_b, AR3
	stm	#xy_out,  AR4
	ld	#0, a
	stm	#11, BRC
	rptb	mws_end-1
	ld	*AR2+, b || mac	*AR3+, a	; parallel LD and MAC
mws_end:
	; final tap with rounding-saturating MACR
	macr	*AR2, *AR3, a
	sat	a
	sth	a, *AR4+
	stl	a, *AR4
	ret

; ---------------------------------------------------------------------
; Pure dual-Xmem/Ymem variety — ADD and SUB and MPY all in one block
; ---------------------------------------------------------------------
	.global _vec_arith3
_vec_arith3:
	stm	#7, BRC
	rptb	v3_end-1
	add	*AR2+, *AR3+, a		; A = *AR2++ + *AR3++
	sub	*AR2+, *AR3+, b		; B = *AR2++ - *AR3++
	mpy	*AR2+, *AR3+, a		; A = *AR2++ * *AR3++
v3_end:
	ret

	.end
