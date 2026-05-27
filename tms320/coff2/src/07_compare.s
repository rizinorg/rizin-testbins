;
; 07_compare.s -- TMS320C55x+ compare-instruction coverage.
;
; assemble with:
;   asm55p.exe -v5505 07_compare.s
;
; Exercises:
;   - CMP register == register, with TC1/TC2 destination
;   - CMP register relational forms (< / > / <= / >= / != )
;   - SWPU104 sec.6.2.4 (Compare Accumulator, Auxiliary, or Temporary)
;
; Th0rpe regression captures:
;   d "cmp t2 == t3, tc1"      a4323300
;
	.global _cmp_demo
	.global _cmp_relops

	.text

; ---------------------------------------------------------------------
; cmp_demo: equality and TC destination
; ---------------------------------------------------------------------
_cmp_demo:
	CMP T2 == T3, TC1
	CMP T0 == T1, TC2
	RET

; ---------------------------------------------------------------------
; cmp_relops: walk the relational operators (<, >=, !=) to exercise
; the cond-field decode in the disassembler.
; ---------------------------------------------------------------------
_cmp_relops:
	CMP AR0 < AR1, TC1
	CMP AR2 >= AR3, TC2
	CMP AC0 != AC1, TC1
	RET

	.end
