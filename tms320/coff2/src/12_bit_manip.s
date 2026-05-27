;
; 12_bit_manip.s -- TMS320C55x+ status-register bit manipulation.
;
; assemble with:
;   asm55p.exe -v5505 12_bit_manip.s
;
; Exercises SWPU104 sec.6.4.5 (Set/Reset Status Register Bits).
; Th0rpe regression captures: d "bclr st0_acov0, st0_55" 0a0a
;
	.global _bit_demo

	.text

_bit_demo:
	BSET ST0_ACOV0, ST0_55
	BCLR ST0_ACOV0, ST0_55
	BSET ST0_ACOV1, ST0_55
	BCLR ST0_ACOV2, ST0_55
	BSET ST0_ACOV3, ST0_55
	RET

	.end
