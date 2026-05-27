;
; 17_data_layout.s -- TMS320C55x+ data section / data-access exercise.
;
; assemble with:
;   asm55p.exe -v5505 17_data_layout.s
;
; Mirrors rizin-testbins coff1/src/09_data_layout.s. Defines three
; data symbols (one initialised, one zero-init, one read-only) and
; demonstrates the standard ways C55x+ code reaches them:
;   - load constant address into an ARx register (MOV #addr, ARn)
;   - direct *(#k16) absolute access
;   - load through an already-set-up ARn with *ARn / *ARn(#k)
;
; The analyzer should pick the absolute addresses up as data
; references so xrefs / reflines render correctly.
;
	.global _read_initial
	.global _write_state
	.global _hash_lookup
	.global _table_size

	.bss	_state,		8
	.bss	_scratch,	16

	.sect	".const"
_initial_value:
	.word	0x1234
_table:
	.word	0x0001, 0x0002, 0x0004, 0x0008
	.word	0x0010, 0x0020, 0x0040, 0x0080
_table_size_const:
	.word	8

	.text

; ---------------------------------------------------------------------
; read_initial: load the initial-value constant into T0.
; The instruction MOV #_initial_value, AR0 takes a 23-bit address
; literal which the analyzer should surface as a data xref.
; ---------------------------------------------------------------------
_read_initial:
	AMOV  #_initial_value, XAR0
	MOV   *AR0, T0
	RET

; ---------------------------------------------------------------------
; write_state: store T0 into _state[0].
; ---------------------------------------------------------------------
_write_state:
	AMOV  #_state, XAR1
	MOV   T0, *AR1
	RET

; ---------------------------------------------------------------------
; hash_lookup: T0 = _table[T0 & 7]
; Indexed access via AR2 + T0 modifier.
; ---------------------------------------------------------------------
_hash_lookup:
	AMOV  #_table, XAR2
	MOV   *AR2(T0), T0
	RET

; ---------------------------------------------------------------------
; table_size: return the table-size constant.
; ---------------------------------------------------------------------
_table_size:
	AMOV  #_table_size_const, XAR3
	MOV   *AR3, T0
	RET

	.end
