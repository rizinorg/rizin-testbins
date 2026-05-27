;
; 10_minmax.s -- TMS320C55x+ MAX/MIN coverage.
;
; assemble with:
;   asm55p.exe -v5505 10_minmax.s
;
; Exercises SWPU104 sec.6.2.11 (Maximum, Minimum).
;
	.global _minmax_demo

	.text

_minmax_demo:
	MAX AC0, AC1
	MAX AC2, AC3
	MIN AC0, AC1
	MIN AC2, AC3
	RET

	.end
