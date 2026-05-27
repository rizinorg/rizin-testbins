;
; 16_compiler_style.s -- TMS320C55x+ compiler-emitted code shapes.
;
; assemble with:
;   asm55p.exe -v5505 16_compiler_style.s
;
; Mirrors rizin-testbins coff1/src/07_compiler_style.s in spirit: the
; sequences here are the standard prologue/epilogue shapes that
; cl55+ emits for ordinary leaf and non-leaf functions. The point is
; not to exercise individual opcodes (the rest of the corpus covers
; that) but to give the analyzer ordinary "function-shaped" code so
; that the basic-block / function-boundary heuristics get tested.
;
; Conventions exercised:
;   - SP-relative locals via *SP(#k)
;   - frame pointer through AR0 / XAR0
;   - psh / pop pairs for callee-saved AC0
;   - 3-arg call (T0 / T1 / T2 inputs) returning in T0
;
	.global _leaf_addmul
	.global _setup_locals
	.global _three_arg_caller
	.global _no_locals

	.text

; ---------------------------------------------------------------------
; leaf_addmul: trivial leaf, T0 = T0 + T1 * T2
; No prologue / epilogue beyond RET. The analyzer should pick this up
; as a tiny basic block ending in RET, with all three Tx registers as
; reads.
; ---------------------------------------------------------------------
_leaf_addmul:
	MOV   T1, AC0
	MPYK  #5, AC0
	ADD   T0, AC0
	MOV   AC0, T0
	RET

; ---------------------------------------------------------------------
; setup_locals: full prologue, two stack locals at *SP(#0) and *SP(#1),
; full epilogue.
; ---------------------------------------------------------------------
_setup_locals:
	AADD  #-2, SP
	MOV   T0, *SP(#0)
	MOV   T1, *SP(#1)
	MOV   *SP(#0), AC0
	ADD   *SP(#1), AC0
	MOV   AC0, T0
	AADD  #2, SP
	RET

; ---------------------------------------------------------------------
; three_arg_caller: caller-side argument shuffling before a CALL.
; The analyzer's call-target detection should pick up the absolute
; 24-bit target of the CALL.
; ---------------------------------------------------------------------
_three_arg_caller:
	PSH   T0
	PSH   T1
	MOV   #10, T0
	MOV   #20, T1
	MOV   #30, T2
	CALL  _leaf_addmul
	POP   T1
	POP   T0
	RET

; ---------------------------------------------------------------------
; no_locals: prologue without local allocation. RET only.
; ---------------------------------------------------------------------
_no_locals:
	MOV   #0, AC0
	RET

	.end
