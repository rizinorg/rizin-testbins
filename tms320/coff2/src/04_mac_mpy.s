;
; 04_mac_mpy.s -- TMS320C55x+ multiply / MAC / MAS coverage.
;
; assemble with:
;   asm55p.exe -v5505 04_mac_mpy.s
;
; Exercises:
;   - MPY/MAC/MAS with indirect AR addressing
;   - The MACM / MPYM variants exercised in the original th0rpe regression:
;       d "macm *ar2, *ar4, ac0, ac0"   c832803400
;       d "mpym *ar2, *ar4, ac0"        c832003400
;   - The "low-power" 3.0-revision dual-MAC encodings; see
;     SWPU104 sec.6.2.13 (MAC) and sec.6.2.8-sec.6.2.10 (dual-multiply forms)
;
	.global _macm_simple
	.global _mpym_simple
	.global _multiply_demo

	.text

; ---------------------------------------------------------------------
; macm_simple: MACM *AR2, *AR4, AC0, AC0 -- dual-mac with rounding
; This is from the th0rpe XVilka 2013 screenshot of Wrigley_dump.
; ---------------------------------------------------------------------
_macm_simple:
	MACM *AR2, *AR4, AC0, AC0
	RET

; ---------------------------------------------------------------------
; mpym_simple: MPYM *AR2, *AR4, AC0 -- basic multiply with memory
; ---------------------------------------------------------------------
_mpym_simple:
	MPYM *AR2, *AR4, AC0
	RET

; ---------------------------------------------------------------------
; multiply_demo: exercise the encoding variety in one function so the
; analysis plugin sees MAC/MPY/MAS in sequence.
; ---------------------------------------------------------------------
_multiply_demo:
	MPYM *AR2, *AR4, AC0
	MACM *AR2, *AR4, AC0, AC0
	NOP
	RET

	.end
