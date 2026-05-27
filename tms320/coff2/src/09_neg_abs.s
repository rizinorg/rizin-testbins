;
; 09_neg_abs.s -- TMS320C55x+ unary arithmetic coverage.
;
; assemble with:
;   asm55p.exe -v5505 09_neg_abs.s
;
; Exercises (SWPU104 sec.6.2.1, sec.6.2.15):
;   - ABS  Accumulator absolute value
;   - NEG  Two's-complement negation
;
	.global _abs_demo
	.global _neg_demo

	.text

_abs_demo:
	ABS AC0, AC0
	ABS AC1, AC2
	RET

_neg_demo:
	NEG AC0, AC0
	NEG AC1, AC2
	NEG T0, T1
	NEG AR0, AR1
	RET

	.end
