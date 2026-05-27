;
; 06_push_pop.s -- TMS320C55x+ stack manipulation coverage.
;
; assemble with:
;   asm55p.exe -v5505 06_push_pop.s
;
; Exercises:
;   - PSH / POP with single registers (T-pair, accumulators)
;   - PSH / POP with memory-mapped status registers via mmap()
;   - PSHBOTH for paired push of extended AR
;   - SWPU086 sec.4 (Stack Operation), SWPU104 sec.6.7 (Move Operations)
;
; Th0rpe regression captures these:
;   d "pop t2, t3"             713233
;   d "pop mmap(@st1_55)"      2461e508
;   d "psh mmap(@st0_55)"      2461e400
;   d "pshboth xar5"           0d25
;
	.global _stack_demo
	.global _mmap_save_status

	.text

; ---------------------------------------------------------------------
; stack_demo: simple push/pop pairs touching T and AC registers
; ---------------------------------------------------------------------
_stack_demo:
	POP T2, T3
	PSHBOTH XAR5
	RET

; ---------------------------------------------------------------------
; mmap_save_status: typical interrupt-service prologue/epilogue --
; save then restore the status registers through the mmap() qualifier
; ---------------------------------------------------------------------
_mmap_save_status:
	PSH mmap(@ST0_55)
	POP mmap(@ST1_55)
	RET

	.end
