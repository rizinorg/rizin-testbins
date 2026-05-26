;
; 04_fir_filter.s — Classic DSP: FIR filter implementations.
;
; assemble with:
;   tic54x-coff-as -o 04_fir_filter.o 04_fir_filter.s
; This is the canonical TMS320C54x DSP example: a real-world FIR
; filter exercising the multiply-accumulate unit, dual-data-memory
; (Xmem/Ymem) operands, circular addressing (*ARn+0%), the BK
; (block-size) register, and RPT/RPTZ for hardware loops.
;
; Multiple FIR variants:
;   _fir_simple   — straightforward N-tap FIR using a tap loop
;   _fir_circular — circular-buffer FIR (DSP idiom; uses *ARn+0%)
;   _fir_symmetric — symmetric FIR using FIRS (FIR Symmetric) instruction
;   _fir_block    — RPTBD-based outer loop for sample-block processing
;
; Coefficient table sits in .data; sample buffer in .bss.
;
N	.set	16			; FIR length
FRAME	.set	64			; samples per output block

	.mmregs

	; uninitialized I/O buffers
	.bss	x_buf,    16		; input ring buffer (N samples)
	.bss	x_buf2,   16		; second input ring (for symmetric)
	.bss	y_out,    64		; output sample buffer
	.bss	x_state,  1		; one-sample state for streaming

	; coefficient table — initialized .data
	.data
coeffs:
	.word	0x0123, 0x0456, 0x0789, 0x0ABC
	.word	0x0FED, 0x0CBA, 0x0987, 0x0654
	.word	0x0321, 0x0654, 0x0987, 0x0CBA
	.word	0x0FED, 0x0ABC, 0x0789, 0x0456

coeffs_sym:				; symmetric half (first 8 of 16)
	.word	0x0100, 0x0200, 0x0400, 0x0800
	.word	0x1000, 0x2000, 0x0400, 0x0100

	.global _fir_simple
	.global _fir_circular
	.global _fir_symmetric
	.global _fir_block
	.global _fir_init

	.text

; ---------------------------------------------------------------------
; fir_init() — set up AR registers and BK for circular-buffer mode
;   AR4 -> x_buf, AR5 -> coeffs, BK = N (circular buffer size)
; ---------------------------------------------------------------------
_fir_init:
	stm	#x_buf,   AR4		; AR4 = data buffer base
	stm	#coeffs,  AR5		; AR5 = coefficient base
	stm	#N,       BK		; circular buffer length
	stm	#0,       AR0		; AR0 = post-modify increment 0 (no skip)
	stm	#FRAME-1, BRC		; outer-loop count = 63
	ret

; ---------------------------------------------------------------------
; fir_simple(*x, *h, n) — straight FIR, no circular buffer
;   AR2 = data pointer, AR3 = coeff pointer, BRC preset to N-1
;   result in A
; ---------------------------------------------------------------------
_fir_simple:
	rptz	a, #(N-1)		; clear A, then repeat next instr N times
	mac	*AR2+, *AR3+, a		; A += (*AR2++) * (*AR3++)
	ret

; ---------------------------------------------------------------------
; fir_circular(*x_in) — sample-at-a-time circular-buffer FIR
;   AR4 set up by fir_init to point into a circular buffer of size N
;   New sample at *AR6, output stored at *AR7.
; ---------------------------------------------------------------------
_fir_circular:
	ld	*AR6+, a		; load new input sample to A.lo
	stl	a, *AR4+%		; write to current circular slot, advance
	rptz	a, #(N-1)
	mac	*AR4+0%, *AR5+0%, a	; circular-mac, both pointers wrap
	sth	a, *AR7+		; store output sample
	ret

; ---------------------------------------------------------------------
; fir_symmetric(*x_a, *x_b, *h) — exploit symmetric coefficients
;   For y[n] = sum h[k] * (x[n-k] + x[N-1-n+k])
;   Uses FIRS instruction: FIRS Xmem, Ymem, pmad
;   Coefficients live in *program* memory at label `coeffs_sym`.
; ---------------------------------------------------------------------
_fir_symmetric:
	stm	#x_buf,  AR2		; AR2 = first half buffer (forward)
	stm	#x_buf2, AR3		; AR3 = second half buffer (reverse)
	stm	#(N/2)-1, BRC
	rptz	a, #(N/2)-1
	firs	*AR2+, *AR3-, coeffs_sym  ; A += h[k] * (*AR2 + *AR3)
	sth	a, *AR7
	ret

; ---------------------------------------------------------------------
; fir_block(*x_in, *y_out, n) — process FRAME samples in one call
;   Uses RPTBD for outer block-repeat, with the inner MAC repeating
;   via RPTZ (zero-clear + repeat). Classic pattern from TI App Notes.
; ---------------------------------------------------------------------
_fir_block:
	call	_fir_init
	stm	#x_buf,   AR4		; circular buffer
	stm	#coeffs,  AR5
	stm	#N,       BK
	stm	#0,       AR0
	stm	#FRAME-1, BRC		; outer loop = FRAME outputs
	rptbd	fblk_end-1		; delayed block-repeat
	stm	#x_buf,  AR6		; (delay slot)
	stm	#y_out,  AR7		; (delay slot 2)
fblk_top:
	ld	*AR6+, a		; new input sample
	stl	a, *AR4+%		; store into circular
	rptz	a, #(N-1)
	mac	*AR4+0%, *AR5+0%, a
	sth	a, *AR7+
fblk_end:
	ret

; ---------------------------------------------------------------------
; Pure tap unroll — what an aggressive compiler might emit
; ---------------------------------------------------------------------
	.global _fir_unrolled4
_fir_unrolled4:
	ld	#0, a			; clear accumulator
	mac	*AR2+, *AR3+, a		; tap 0
	mac	*AR2+, *AR3+, a		; tap 1
	mac	*AR2+, *AR3+, a		; tap 2
	mac	*AR2+, *AR3+, a		; tap 3
	macr	*AR2+, *AR3+, a		; tap 4 with round
	macr	*AR2+, *AR3+, a		; tap 5 with round
	; ... and saturate result
	sat	a
	sth	a, *AR7
	ret

	.end
