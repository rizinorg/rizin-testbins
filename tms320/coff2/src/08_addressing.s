;
; 08_addressing.s -- TMS320C55x+ addressing-mode coverage.
;
; assemble with:
;   asm55p.exe -v5505 08_addressing.s
;
; The address-unit (AU) modify instructions are heavily used by compiler
; output for pointer arithmetic. Exercises:
;
;   AMAR  -- pure address-register modify (no data movement)
;   AMOV  -- address-register-to-address-register move
;   AADD  -- address-register += k24
;   ASUB  -- address-register -= k24
;
; SWPU104 sec.6.3 covers all of these (A-Unit Register Modifications).
; The original th0rpe regression file captures the encodings:
;   d "amar *ar+2, *ar+4, *ar15"       ea928014c03f
;   d "amar *(ar2+t0b)"                621200
;   d "asub #0xb, xar1"                ae21000b
;
	.global _amar_simple
	.global _aadd_asub
	.global _xar_load

	.text

; ---------------------------------------------------------------------
; amar_simple: AMAR with bracket-index addressing
; ---------------------------------------------------------------------
_amar_simple:
	AMAR *(AR2 + T0B)
	RET

; ---------------------------------------------------------------------
; aadd_asub: 24-bit add/subtract on an extended AR
; ASUB #0xb, XAR1 captures the th0rpe regression encoding ae21000b
; ---------------------------------------------------------------------
_aadd_asub:
	ASUB #0xb, XAR1
	RET

; ---------------------------------------------------------------------
; xar_load: load XAR0 and XAR1 with 24-bit addresses, then NOP
; ---------------------------------------------------------------------
_xar_load:
	AMOV #0x12, XAR0
	AMOV #0x34, XAR1
	NOP
	RET

	.end
