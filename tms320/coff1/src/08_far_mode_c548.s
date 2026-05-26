;
; 08_far_mode_c548.s — C548-specific extended (23-bit) addressing.
;
; assemble with:
;   tic54x-coff-as -mcpu=548 -mfar-mode -o 08_far_mode_c548.o 08_far_mode_c548.s
; The C548 device is the only C54x variant with extended (23-bit)
; program memory addressing. binutils exposes this via:
;
;   - The `.version 548` directive (or -mcpu=548 on the command line)
;   - The `.far_mode` directive (or -mfar-mode)
;   - "FAR" instruction variants: FB, FBD, FCALL, FCALLD,
;     FBACC, FCALA, FRET, FRETD, FRETE, FRETED
;   - The LDX pseudo-op for loading the high 7 bits of an
;     extended-mode address into an accumulator
;
; A disassembler should detect these and display them with `f` prefix
; so the reader knows it's a 23-bit-address operation. They emit
; 2-word instructions (the high 7 bits of the address are encoded in
; the opcode word, the low 16 in a follow-on word).
;
	.mmregs
	.version 548			; tell gas this is a c548
	.far_mode			; enable extended addressing

	.bss	xpc_save,  1
	.bss	page_reg,  1

	.global _far_entry
	.global _far_dispatch
	.global _far_loop
	.global _far_compute_addr
	.global _far_isr

	.sect	".text"

;----------------------------------------------------------------------
; far_entry — the reset/cold-start vector. Uses FB to jump into the
; main program, which can be anywhere in 23-bit program space.
;----------------------------------------------------------------------
_far_entry:
	fb	_far_dispatch		; far branch (extended-addressing)
	; fb is a 2-word instruction; the next code address is _far_entry+2

;----------------------------------------------------------------------
; far_dispatch — selects between handlers via FCALL (extended-addr
; call). FCALL pushes the high 7 bits onto the stack as well as the
; usual low 16, so FRET pops both halves on return.
;----------------------------------------------------------------------
_far_dispatch:
	pshm	AR1
	mvmm	SP, AR1
	; Dispatch on a single flag value from data memory
	ld	@xpc_save, a
	bc	disp_alt, AGT
	fcall	_far_loop		; far call (delayed = fcalld, not used here)
	b	disp_done
disp_alt:
	fcall	_far_compute_addr
disp_done:
	popm	AR1
	fret				; far return (pops 23-bit PC)

;----------------------------------------------------------------------
; far_loop — main work loop. Demonstrates FBD (delayed far branch)
; so the disassembler can show delay slots between the branch word and
; its actual transfer of control.
;----------------------------------------------------------------------
_far_loop:
	pshm	AR1
	mvmm	SP, AR1
	frame	#-2
	stl	a, *AR1(1)		; save arg
	; ... body
	ld	*AR1(1), a
	add	#1, a
	stl	a, *AR1(1)
	; branch back via delayed far branch — the next 2 instr words
	; execute before the branch actually takes effect.
	fbd	_far_loop+0x10		; delayed far branch (target = self+0x10)
	nop				; delay slot 1
	nop				; delay slot 2
	frame	#2
	popm	AR1
	fret

;----------------------------------------------------------------------
; far_compute_addr — uses LDX (pseudo-op) to load a 23-bit code
; address into an accumulator, then FCALA (call accumulator, far)
; to jump to it. This is a common pattern for vtables / dispatch
; tables that live above the 64K boundary.
;
; LDX #addr, 16, A     -> A.hi = high 7 bits of extended address
; OR  #addr, A, A      -> A   |= low 16 bits of address
; FCALA A              -> far call via 23-bit accumulator target
;----------------------------------------------------------------------
_far_compute_addr:
	pshm	AR1
	mvmm	SP, AR1
	ldx	#_far_loop, 16, a	; load high 7 bits of address
	or	#_far_loop, a, a	; or in the low 16 bits
	fcala	a			; far call via accumulator
	popm	AR1
	fret

;----------------------------------------------------------------------
; far_isr — interrupt service routine.
; Uses FRETE (far return enabling interrupts).
;----------------------------------------------------------------------
_far_isr:
	pshm	AR1
	mvmm	SP, AR1
	; do something with the global state
	ld	@xpc_save, a
	add	#1, a
	stl	a, @xpc_save
	popm	AR1
	frete				; far return + re-enable interrupts

;----------------------------------------------------------------------
; A second .text-class section for an out-of-line handler.
; The disassembler should see this as a separately-loaded section.
;----------------------------------------------------------------------
	.sect	".far_code"

	.global _far_helper
_far_helper:
	; This routine could be loaded anywhere in 23-bit prog space.
	ld	#0x1234, a
	stl	a, @page_reg
	fcall	_far_loop		; cross-section far call
	fret

	.end
