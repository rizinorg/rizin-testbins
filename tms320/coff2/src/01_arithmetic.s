;
; 01_arithmetic.s -- TMS320C55x+ arithmetic instruction coverage.
;
; assemble with:
;   asm55p.exe -v5505 01_arithmetic.s
;
; Exercises:
;   - ADD/SUB with immediate, AR, T, and AC source operands
;   - MOV with both register and immediate operands
;   - ADD #k16, ACx, ACy (3-operand long-immediate form, 5-byte encoding)
;   - SUB ACx, ACy (single-byte parallel-friendly form)
;
; Multiple small functions are emitted so the disassembler sees distinct
; .text symbols, matching the layout used by rizinorg/rizin-testbins#289
; for the c55x family.
;
; Encoding ground truth from TI dis55.exe v4.3.6 (CCSv5 c55x_plus SDK,
; Feb 2010); cross-validated against rizin's c55x_plus decoder.
;
	.global _add_simple
	.global _add_imm
	.global _add_acc
	.global _add_long_imm
	.global _sub_simple
	.global _sub_acc
	.global _arith_demo

	.text

; ---------------------------------------------------------------------
; add_simple: ADD AR0, AC0
; Single-byte form: opcode 0x74 0x00 0x20
; ---------------------------------------------------------------------
_add_simple:
	ADD AR0, AC0
	RET

; ---------------------------------------------------------------------
; add_imm: ADD #1, AC0  /  ADD #50, AC1
; 3-byte short-immediate form: 0x7b 0x00 0x01
; ---------------------------------------------------------------------
_add_imm:
	ADD #1, AC0
	ADD #50, AC1
	RET

; ---------------------------------------------------------------------
; add_acc: ADD AC0, AC1  /  ADD T1, AC1
; The T1 form is in the original th0rpe regression: d "add t1, ac1" 740131
; ---------------------------------------------------------------------
_add_acc:
	ADD T0, AC0
	ADD T1, AC1
	RET

; ---------------------------------------------------------------------
; add_long_imm: ADD #k16, ACx, ACy -- 5-byte form
; Encoding: 0xc4 0x01 ROR DST -> e.g. ADD #100,AC0,AC1 = c401000064
; ---------------------------------------------------------------------
_add_long_imm:
	ADD #100, AC0, AC1
	ADD #50, AC1, AC1
	RET

; ---------------------------------------------------------------------
; sub_simple: SUB #1, AC0 / SUB AR0, AC0
; ---------------------------------------------------------------------
_sub_simple:
	SUB #1, AC0
	SUB AR0, AC0
	RET

; ---------------------------------------------------------------------
; sub_acc: SUB AC1, AC0 -- 0x74 0x00 0x81
; This is in the original th0rpe regression: d "sub ac1, ac0" 740081
; ---------------------------------------------------------------------
_sub_acc:
	SUB AC1, AC0
	RET

; ---------------------------------------------------------------------
; arith_demo: a long sequence touching most arithmetic encodings so
; the disassembler sees variety in a single function.
; ---------------------------------------------------------------------
_arith_demo:
	MOV #0x42, AC0
	MOV AR0, AR1
	MOV AR2, AR3
	ADD #1, AC0
	ADD #100, AC0, AC1
	ADD T1, AC1
	SUB #1, AC0
	SUB AC1, AC0
	NOP
	RET

	.end
