;
; 14_xcc.s -- TMS320C55x+ conditional-execute coverage.
;
; assemble with:
;   asm55p.exe -v5505 14_xcc.s
;
; Exercises SWPU104 sec.6.5.9 (Conditional Execute). XCC predicates the
; *next* instruction on a condition; mnemonic-form syntax is "XCC label,
; cond" with the predicated instruction following the label.
;
; The disassembler renders the encoded sequence as either an XCC
; instruction with a parallel || prefix (e.g. "xccpart ac0 <= #0 ||
; mov #0x0, t0") or as a stand-alone "xccpart TC1" qualifier on the
; next op. Th0rpe regression captures three forms.
;
	.global _xcc_demo

	.text

_xcc_demo:
	XCC xcc_skip, TC1
	MOV #0, T0
xcc_skip:
	XCC xcc_skip2, AC0 == #0
	MOV #1, T1
xcc_skip2:
	RET

	.end
