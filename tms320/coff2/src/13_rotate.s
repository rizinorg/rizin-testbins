;
; 13_rotate.s -- TMS320C55x+ rotate-instruction coverage.
;
; assemble with:
;   asm55p.exe -v5505 13_rotate.s
;
; Exercises SWPU104 sec.6.6.5 (Rotate to MSBs/LSBs).
;
	.global _rol_demo
	.global _ror_demo

	.text

_rol_demo:
	ROL CARRY, AC0, CARRY, AC1
	RET

_ror_demo:
	ROR CARRY, AC0, CARRY, AC1
	RET

	.end
