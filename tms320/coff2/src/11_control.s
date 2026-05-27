;
; 11_control.s -- TMS320C55x+ extended control-flow coverage.
;
; assemble with:
;   asm55p.exe -v5505 11_control.s
;
; Exercises (SWPU104 sec.6.5.10, sec.6.5.11, sec.6.5.17, sec.6.5.18, sec.6.5.20):
;   - NOP   (1-byte; the classic single-byte no-op)
;   - IDLE  (enter low-power state)
;   - RETI  (Return from interrupt)
;   - INTR  (Software interrupt with vector)
;   - TRAP  (Software trap with vector)
;
	.global _idle_demo
	.global _reti_demo
	.global _intr_demo
	.global _trap_demo

	.text

; ---------------------------------------------------------------------
; idle_demo: enter idle, then NOP-fill so the disassembler sees the
; sequence in a normal text-section context.
; ---------------------------------------------------------------------
_idle_demo:
	IDLE
	NOP
	RET

; ---------------------------------------------------------------------
; reti_demo: classic ISR-epilogue return-from-interrupt
; ---------------------------------------------------------------------
_reti_demo:
	NOP
	RETI

; ---------------------------------------------------------------------
; intr_demo: software interrupt with vector immediate
; ---------------------------------------------------------------------
_intr_demo:
	INTR #5
	RET

; ---------------------------------------------------------------------
; trap_demo: software trap, different vector
; ---------------------------------------------------------------------
_trap_demo:
	TRAP #4
	RET

	.end
