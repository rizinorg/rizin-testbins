;
; 05_repeat_block.s — Block-repeat, repeat, and conditional execution.
;
; assemble with:
;   tic54x-coff-as -o 05_repeat_block.o 05_repeat_block.s
; Exercises:
;   - RPT k         repeat next instruction k+1 times
;   - RPT Smem      repeat using count from memory
;   - RPTZ A, #k    clear accumulator then repeat
;   - RPTB pmad     block repeat (next block until label, BRC times)
;   - RPTBD pmad    delayed block repeat (2 delay slot words)
;   - XC k, cond    execute next k=1|2 instructions conditionally
;   - LOCALREPEAT pattern (nested via STM #...,BRC stack save)
;
; These constructs are *very* characteristic of C54x DSP code and a
; disassembler that recognizes them should be able to identify the
; repeated-loop body as a separate basic block.
;
	.mmregs
	.bss	buf_in,    64
	.bss	buf_out,   64
	.bss	tmp,       32
	.bss	cnt,       1
	.bss	stage,     1

	.global _memcpy_words
	.global _memset_words
	.global _vector_scale
	.global _saxpy
	.global _conditional_apply
	.global _nested_repeat
	.global _rpt_indirect

	.text

; ---------------------------------------------------------------------
; memcpy_words(*dst, *src, n) — copy n words; AR2=dst, AR3=src, BRC=n-1
;   Uses RPTB for a single-instruction block.
; ---------------------------------------------------------------------
_memcpy_words:
	stm	#31, BRC		; copy 32 words
	rptb	mcw_end-1
	mvdd	*AR3+, *AR2+		; move data memory to data memory
mcw_end:
	ret

; ---------------------------------------------------------------------
; memset_words(*dst, val) — fill 32 words with val
;   Demonstrates RPT (single-instruction repeat) and STL.
; ---------------------------------------------------------------------
_memset_words:
	ld	#0xCAFE, a		; constant to store
	rpt	#31			; repeat next instr 32 times
	stl	a, *AR2+		; *AR2++ = A.lo
	ret

; ---------------------------------------------------------------------
; vector_scale(*x, scale_in_T) — multiply each word by T, store back
; ---------------------------------------------------------------------
_vector_scale:
	stm	#31, BRC
	rptb	vs_end-1
	ld	*AR2, t			; load sample to T
	mpy	*AR3+, a		; A = T * *AR3++  (coeff)
	sth	a, *AR2+		; store high half
vs_end:
	ret

; ---------------------------------------------------------------------
; saxpy(*y, *x, alpha) — y[i] += alpha * x[i], i = 0..N-1
;   alpha preloaded in T. Classic BLAS-1 kernel.
; ---------------------------------------------------------------------
_saxpy:
	stm	#31, BRC
	rptbd	sax_end-1
	stm	#0, AR0			; (delay slot 1)
	stm	#0, AR1			; (delay slot 2)
sax_top:
	ld	*AR2, a			; A = y[i]
	mac	*AR3+, t, a		; A += T * x[i++]
	stl	a, *AR2+		; y[i++] = A.lo
sax_end:
	ret

; ---------------------------------------------------------------------
; conditional_apply(*x, n) — apply different ops based on sign of x[i]
;   Heavy use of XC (execute conditional) which makes the disassembler
;   show "next 1/2 insns are conditional".
; ---------------------------------------------------------------------
_conditional_apply:
	stm	#15, BRC
	rptb	ca_end-1
	ld	*AR2, a			; A = x[i]
	cmpm	*AR2, #0
	xc	2, AGT			; next 2 instrs only if x[i] > 0
	or	#0x8000, a
	stl	a, *AR2
	xc	1, ALT			; next 1 instr only if x[i] < 0
	abs	a
	xc	1, AEQ
	ld	#1, a			; replace zero with 1
	stl	a, *AR2+
ca_end:
	ret

; ---------------------------------------------------------------------
; nested_repeat() — two nested loops via BRC stack save/restore
;   Outer: for i = 0..3
;     Inner: for j = 0..7: buf_out[i*8+j] = (i+j) << 4
; ---------------------------------------------------------------------
_nested_repeat:
	stm	#3, AR1			; outer counter
nr_outer:
	pshm	BRC			; save BRC across inner loop (TI idiom)
	pshm	RSA			; save block-start address
	pshm	REA			; save block-end address
	stm	#7, BRC
	rptb	nr_inner_end-1
	ld	*AR1, a			; A = i
	add	#1, a
	sftl	a, 4
	stl	a, *AR3+
nr_inner_end:
	popm	REA			; restore
	popm	RSA
	popm	BRC
	banz	nr_outer, *AR1-
	ret

; ---------------------------------------------------------------------
; rpt_indirect(*p, count_var) — RPT count taken from data memory
; ---------------------------------------------------------------------
_rpt_indirect:
	rpt	@cnt			; count from memory (RPT Smem variant)
	add	*AR2+, a
	stl	a, *AR3
	ret

; ---------------------------------------------------------------------
; Long block repeat — stress test for disassembler with many MACs
; ---------------------------------------------------------------------
	.global _dot_long
_dot_long:
	ld	#0, b
	stm	#63, BRC
	rptb	dl_end-1
	mac	*AR2+, *AR3+, b
dl_end:
	macr	*AR2+, *AR3+, b		; final tap with round
	sat	b
	ret

	.end
