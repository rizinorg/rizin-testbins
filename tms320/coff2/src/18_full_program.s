;
; 18_full_program.s -- TMS320C55x+ end-to-end program shape.
;
; assemble with:
;   asm55p.exe -v5505 18_full_program.s
;
; Mirrors rizin-testbins coff1/src/10_full_program.s in spirit: a
; small program that wires multiple helper functions through call
; / ret / conditional-branch so the analyzer has to follow real
; function-call chains.
;
; Layout (call graph):
;
;     _main
;       |--> _maybe_zero
;       |       \--> _zero_out
;       |--> _accum_loop
;       |       \--> _step (inside the loop)
;       \--> _finalize
;
; The analyzer should discover all six functions, render call
; reflines, and *not* merge _step / _accum_loop / _finalize into a
; single oversized basic block.
;
	.global _main
	.global _maybe_zero
	.global _zero_out
	.global _accum_loop
	.global _step
	.global _finalize

	.bss	_acc,		4
	.bss	_count,		2

	.text

; ---------------------------------------------------------------------
; zero_out: clear AC0.
; ---------------------------------------------------------------------
_zero_out:
	MOV   #0, AC0
	RET

; ---------------------------------------------------------------------
; maybe_zero: if T0 == 0 then zero out, else leave AC0 alone.
; Exercises a conditional call (CALLCC).
; ---------------------------------------------------------------------
_maybe_zero:
	BCC   _maybe_zero_skip, T0 != #0
	CALL  _zero_out
_maybe_zero_skip:
	RET

; ---------------------------------------------------------------------
; step: AC0 += T0; T0 -= 1
; ---------------------------------------------------------------------
_step:
	ADD   T0, AC0
	SUB   #1, T0
	RET

; ---------------------------------------------------------------------
; accum_loop: sum T0..1 in AC0. Exercises a back-edge via BCC.
; ---------------------------------------------------------------------
_accum_loop:
	MOV   #0, AC0
_accum_top:
	CALL  _step
	BCC   _accum_top, T0 > #0
	RET

; ---------------------------------------------------------------------
; finalize: copy AC0.l into the .bss slot _acc.
; ---------------------------------------------------------------------
_finalize:
	AMOV  #_acc, XAR0
	MOV   AC0, *AR0
	RET

; ---------------------------------------------------------------------
; main: prime T0, run the loop, finalize.
; ---------------------------------------------------------------------
_main:
	MOV   #5, T0
	CALL  _maybe_zero
	CALL  _accum_loop
	CALL  _finalize
	MOV   #0, T0
	RET

	.end
