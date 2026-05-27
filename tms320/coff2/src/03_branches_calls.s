;
; 03_branches_calls.s -- TMS320C55x+ control-flow coverage.
;
; assemble with:
;   asm55p.exe -v5505 03_branches_calls.s
;
; This is the critical file for the analysis-side plugin: the c55x_plus
; analysis code in c55plus_analysis.c switches on the leading byte of
; each instruction to identify branch/call/return/jump types. Each
; encoding here exercises one of those paths:
;
;   0x21        -> RET (short, 1-byte)        ; SWPU104 sec.6.5.16
;   0x68 ll hh  -> B   (short rel, 3-byte)    ; sec.6.5.2
;   0x69 ll hh  -> CALL (short rel, 3-byte)   ; sec.6.5.6
;   0x6a ss     -> BCC (short rel, 2-byte)    ; sec.6.5.1
;   0x9a ll hh cc -> BCC (long rel, 4-byte)
;   0x9b ll hh cc -> CALLCC (long rel, 4-byte) ; sec.6.5.5
;   0x9c addr.. -> B (long abs, 4-byte)
;   0x9d addr.. -> CALL (long abs, 4-byte)
;   0xd8 .. ..  -> BCC (abs, 4-byte)
;   0xd9 .. ..  -> CALLCC (abs, 4-byte)
;
; All offsets are intra-function so the linker resolves them at
; assemble time; this keeps the test file self-contained.
;
	.global _short_ret
	.global _short_branch
	.global _short_call
	.global _short_bcc
	.global _long_bcc
	.global _bcondu
	.global _flow_demo
	.global _flow_target

	.text

; ---------------------------------------------------------------------
; short_ret: simplest path -- just RET (single-byte 0x21)
; ---------------------------------------------------------------------
_short_ret:
	RET

; ---------------------------------------------------------------------
; short_branch: unconditional relative branch (B label) -- 0x68 opcode
; The original th0rpe XVilka screenshot from 2013 showed bytes
; "68 ff a1" decoded to "b #0x00ffa1". Here we'll branch to a label.
; ---------------------------------------------------------------------
_short_branch:
	NOP
	B _flow_target
	NOP             ; unreachable, just spacing for the disassembler

; ---------------------------------------------------------------------
; short_call: unconditional relative call -- 0x69 opcode
; ---------------------------------------------------------------------
_short_call:
	NOP
	CALL _flow_target
	RET

; ---------------------------------------------------------------------
; short_bcc: 2-byte conditional branch (0x6a + signed 8-bit offset)
; SWPU104 sec.6.5.1
; ---------------------------------------------------------------------
_short_bcc:
	NOP
	BCC _flow_target, AC0 != #0
	RET

; ---------------------------------------------------------------------
; long_bcc: 4-byte conditional branch -- when the offset can't fit in 8 bits
; or when the condition needs a wider qualifier (0x9a opcode)
; ---------------------------------------------------------------------
_long_bcc:
	BCC _flow_target, AC0 == #0
	BCC _flow_target, AC1 != #0
	BCC _flow_target, T0 < #0
	BCC _flow_target, AR0 > #0
	RET

; ---------------------------------------------------------------------
; bcondu: unsigned BCC variants (BCCU keyword), exercising the cond field
; The th0rpe XVilka screenshot also showed BCCU encodings.
; ---------------------------------------------------------------------
_bcondu:
	BCCU _flow_target, AR0 < AR1
	BCCU _flow_target, AR2 < AR3
	RET

; ---------------------------------------------------------------------
; flow_demo: mixed control flow so the analysis plugin sees the full
; basic-block graph: nop -> bcc -> fallthrough nop -> call -> ret.
; ---------------------------------------------------------------------
_flow_demo:
	NOP
	BCC fd_skip, AC0 == #0
	NOP
	CALL _short_ret
	NOP
fd_skip:
	RET

; ---------------------------------------------------------------------
; flow_target: the label every branch above points at.
; ---------------------------------------------------------------------
_flow_target:
	NOP
	RET

	.end
