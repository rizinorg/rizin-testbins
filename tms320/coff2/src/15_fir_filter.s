;
; 15_fir_filter.s -- TMS320C55x+ FIR filter exercise.
;
; assemble with:
;   asm55p.exe -v5505 15_fir_filter.s
;
; Demonstrates the textbook FIR filter inner loop in C55x+ algebraic
; syntax: MACM-into-accumulator, dual-Smem addressing through CDP
; and AR3, and a fixed-iteration unrolled tap window.
;
; Parallels rizin-testbins coff1/src/04_fir_filter.s (c54x) so the
; same algorithmic pattern is exercised on the c55x+ analyzer:
;   - tight MAC sequence -> RZ_ANALYSIS_OP_TYPE_MUL inside a
;     single basic block that fcn-discovery should not split
;   - prologue / epilogue with PSH/POP T0/T1 for caller-saved
;     register handling
;
	.global _fir_init
	.global _fir_step
	.global _fir_taps4
	.global _fir_taps8

	.text

; ---------------------------------------------------------------------
; fir_init: prime both accumulators to zero.
; ---------------------------------------------------------------------
_fir_init:
	MOV  #0, AC0
	MOV  #0, AC1
	RET

; ---------------------------------------------------------------------
; fir_step: one MAC-accumulate over a single tap.
;   AC0 += x[*AR3++] * h[*CDP++]
; ---------------------------------------------------------------------
_fir_step:
	MACM  *AR3+, *CDP+, AC0
	RET

; ---------------------------------------------------------------------
; fir_taps4: 4-tap unrolled inner loop.
; ---------------------------------------------------------------------
_fir_taps4:
	MOV   #0, AC0
	MACM  *AR3+, *CDP+, AC0
	MACM  *AR3+, *CDP+, AC0
	MACM  *AR3+, *CDP+, AC0
	MACM  *AR3+, *CDP+, AC0
	RET

; ---------------------------------------------------------------------
; fir_taps8: 8-tap unrolled inner loop. Returns the high 16 bits of
; the accumulator in T0 so the caller can round / store.
; ---------------------------------------------------------------------
_fir_taps8:
	PSH   T0
	MOV   #0, AC0
	MACM  *AR3+, *CDP+, AC0
	MACM  *AR3+, *CDP+, AC0
	MACM  *AR3+, *CDP+, AC0
	MACM  *AR3+, *CDP+, AC0
	MACM  *AR3+, *CDP+, AC0
	MACM  *AR3+, *CDP+, AC0
	MACM  *AR3+, *CDP+, AC0
	MACM  *AR3+, *CDP+, AC0
	MOV   HI(AC0), T0
	POP   T0
	RET

	.end
