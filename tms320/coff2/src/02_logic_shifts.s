;
; 02_logic_shifts.s -- TMS320C55x+ logical, bit-manipulation, and shift coverage.
;
; assemble with:
;   asm55p.exe -v5505 02_logic_shifts.s
;
; Exercises:
;   - AND/OR/XOR with immediate and AC source operands
;   - SFTS (arithmetic shift), SFTL (logical shift)
;   - BSET/BCLR on status-register bits
;   - SWPU104 sec.6.6 (Logical Instructions), sec.6.4 (Bit Manipulation)
;
	.global _logic_imm
	.global _logic_acc
	.global _shifts
	.global _status_bits
	.global _logic_demo

	.text

; ---------------------------------------------------------------------
; logic_imm: AND/OR/XOR with k16 immediates
; SWPU104 sec.6.6.1-sec.6.6.3
; ---------------------------------------------------------------------
_logic_imm:
	AND #0xff, AC0
	OR  #0x0f, AC1
	XOR #0xaa, AC2
	RET

; ---------------------------------------------------------------------
; logic_acc: AND/OR/XOR with register source
; ---------------------------------------------------------------------
_logic_acc:
	AND AC0, AC1
	OR  AC0, AC2
	XOR AC0, AC3
	RET

; ---------------------------------------------------------------------
; shifts: arithmetic and logical shift forms
; SWPU104 sec.6.2.3 (SFTS), sec.6.6.6 (SFTL)
; Th0rpe regression includes: d "sfts ac1, t3, ac1" a6818133
;                             d "sftl ac1, #0x31, ac1" a7810131
; ---------------------------------------------------------------------
_shifts:
	SFTS AC1, T3, AC1
	SFTL AC1, #15, AC1
	RET

; ---------------------------------------------------------------------
; status_bits: BCLR/BSET on status registers
; SWPU104 sec.6.4.5
; Th0rpe regression includes: d "bclr st0_acov0, st0_55" 0a0a
; ---------------------------------------------------------------------
_status_bits:
	BCLR ST0_ACOV0, ST0_55
	RET

; ---------------------------------------------------------------------
; logic_demo: flex the full logical/shift instruction set in one function
; ---------------------------------------------------------------------
_logic_demo:
	XOR #0x1, AR3, AR3
	AND AC1, AC0
	OR  AC2, AC0
	XOR AC3, AC0
	SFTS AC0, T0, AC0
	SFTL AC0, #4, AC0
	BCLR ST0_ACOV0, ST0_55
	NOP
	RET

	.end
