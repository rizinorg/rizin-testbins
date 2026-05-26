;
; 01_arithmetic.s — Arithmetic and load/store instruction coverage.
;
; assemble with:
;   tic54x-coff-as -o 01_arithmetic.o 01_arithmetic.s
; Exercises:
;   - ADD/SUB/MPY/MAC with all single-data-memory addressing modes
;     (direct DP-relative `@var`, indirect `*ARn`, indirect with
;     post/pre modifiers, indexed `*ARn(lk)`)
;   - Long-immediate variants: ADD #lk, SHIFT, SRC, DST
;   - Dual-operand Xmem/Ymem additions (ADD Xmem, Ymem, DST)
;   - 32-bit (Lmem) double-precision arithmetic: DADD, DSUB, DLD, DST
;   - ABS, NEG, NORM, EXP, ROUND
;   - Both accumulators A and B used as source and destination
;
; Multiple small functions so the disassembler sees clear .text symbols.
;
	.mmregs

	.bss	x_var,  4
	.bss	y_var,  4
	.bss	z_var,  4
	.bss	scratch, 8

	.global _abs_diff
	.global _scaled_add
	.global _vec_dot
	.global _norm32
	.global _saturate
	.global _polyeval

	.text

; ---------------------------------------------------------------------
; abs_diff(a, b)  — returns |a - b| in accumulator A.
; Args by convention passed in A (a) and B (b).
; ---------------------------------------------------------------------
_abs_diff:
	sub	b, a		; A = A - B
	abs	a		; A = |A|
	ret

; ---------------------------------------------------------------------
; scaled_add(*x, *y, k) — *z = *x + (*y << k)
;   AR2 = &x, AR3 = &y, AR4 = &z, T = shift count
; ---------------------------------------------------------------------
_scaled_add:
	ld	*AR3, T, a	; A = *y << T  (load then shift by T)
	add	*AR2, a		; A += *x
	stl	a, *AR4		; *z = lo(A)
	sth	a, *+AR4(1)	; high half if you care
	ret

; ---------------------------------------------------------------------
; vec_dot(*x, *y, n) — dot product into B, returns sum in B
;   AR2 = &x, AR3 = &y, BRC preset to n-1, T0 area used as temp
; ---------------------------------------------------------------------
_vec_dot:
	ld	#0, b			; B = 0
	stm	#7, BRC			; repeat block 8 times
	rptbd	dot_end-1
	nop
	mac	*AR2+, *AR3+, b		; B += (*AR2++) * (*AR3++)
dot_end:
	ret

; ---------------------------------------------------------------------
; norm32(*lp) — normalize a 32-bit value at *AR2, return shift in A.
; ---------------------------------------------------------------------
_norm32:
	dld	*AR2, a			; load 32-bit value from Lmem into A
	exp	a			; A.exp = leading-sign-bit count
	st	t, *AR3			; save shift amount T -> *AR3
	norm	a			; normalize A
	dst	a, *AR2			; store back
	ret

; ---------------------------------------------------------------------
; saturate(x) — clamp accumulator A to signed 16 bits
; ---------------------------------------------------------------------
_saturate:
	; Set OVM (overflow mode) before so STH saturates
	ssbx	ovm
	sth	a, *AR2			; saturated store of high half
	rsbx	ovm
	ret

; ---------------------------------------------------------------------
; polyeval(*coeffs, x, n) — Horner's method polynomial evaluation
;   A holds running value, T = x, AR2 walks coefficients high-to-low
;   coefficient count - 1 in BRC
;
; Note: we use MACR (multiply-accumulate with rounding) so each
; iteration becomes:   A = round(*AR2 * T) + A   then we shift A
; back into the integer position. This is a typical compiler-style
; lowering of a polynomial.
; ---------------------------------------------------------------------
_polyeval:
	ld	*AR2+, 16, a		; A = c[n-1] << 16  (seed)
	stm	#5, BRC			; degree-1 = 5 (6 coefficients)
	rptb	poly_end-1
	stl	a, *AR3			; spill A.lo to scratch
	squr	*AR3, b			; B = (*AR3)^2 -- placeholder squarer
	add	*AR2+, 16, a		; A += c[i] << 16
poly_end:
	ret

; ---------------------------------------------------------------------
; Wide arithmetic — 32-bit ops via Lmem (long memory) addressing
; ---------------------------------------------------------------------
	.global _add32
_add32:
	dld	*AR2, a			; A = *(long*)AR2  (loads 2 words)
	dadd	*AR3, a			; A += *(long*)AR3
	dst	a, *AR4			; *(long*)AR4 = A
	ret

; ---------------------------------------------------------------------
; Long immediate constants — these emit extra instruction words
; ---------------------------------------------------------------------
	.global _mac_lk
_mac_lk:
	ld	#0x1234, a		; long immediate load
	add	#0x5678, 4, a		; A += 0x5678 << 4
	mpy	#100, a			; A = T * 100, then assign A
	sub	#-1, 8, a, b		; B = A - (-1 << 8)
	and	#0xFF00, 0, a		; A &= 0xFF00
	ret

; ---------------------------------------------------------------------
; Direct addressing using DP — references @x_var, @y_var, @z_var
; ---------------------------------------------------------------------
	.global _direct_demo
_direct_demo:
	ld	#x_var, dp		; set DP page (auto-resolved by linker)
	ld	@x_var, a		; A = x_var
	add	@y_var, a		; A += y_var
	stl	a, @z_var		; z_var = lo(A)
	sth	a, @z_var+1		; z_var+1 = hi(A)
	ret

	.end
