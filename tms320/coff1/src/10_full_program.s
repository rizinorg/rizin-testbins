;
; 10_full_program.s — A realistic complete TMS320C54x program.
;
; assemble with:
;   tic54x-coff-as -o 10_full_program.o 10_full_program.s
; This fixture is the largest of the set. It simulates a small
; signal-processing application:
;
;   - Reset vector at 0xFF80 (.sect ".vectors") with a jump to _c_int00
;   - C runtime init (_c_int00) — clears BSS, sets up DP, jumps to main
;   - main() — orchestrates a small DSP pipeline:
;       1) init_input() — fills input ring buffer with a synthetic
;          16-tone waveform built from a phase accumulator
;       2) crc16_compute() — runs a CRC-16 over the input
;       3) iir_lowpass() — first-order IIR filter over the input
;       4) fir_lowpass() — 32-tap FIR using circular buffer
;       5) energy() — accumulates squared output samples
;       6) compress() — log-companding via lookup table
;       7) output to a memory-mapped peripheral (simulated MMR)
;
; The result is a binary with:
;   - Multiple .text sections (`.vectors`, `.text`)
;   - .data with tables and twiddles
;   - .const with the FIR coefficient bank and CRC table
;   - .bss with ring buffers and state
;   - Cross-section relocations (.text -> .const, .text -> .bss)
;   - ~15 functions across the call graph
;
; This is the disassembler's "exam" — it should produce a clean,
; navigable disassembly with all symbols cross-referenced.
;

N_TAPS	.set	32			; FIR length
RING	.set	64			; ring buffer size
SAMPLES	.set	128			; samples to process

	.mmregs

;======================================================================
; Reset vectors — must live at a fixed program-memory address.
;======================================================================
	.sect	".vectors"

reset:
	b	_c_int00		; branch to C runtime entry
	nop
	nop

;======================================================================
; .const — coefficient tables and CRC lookup
;======================================================================
	.sect	".const"

; 32-tap low-pass FIR coefficients (symmetric, hand-tuned)
fir_coeffs:
	.word	0xFC00, 0xFD80, 0xFE00, 0xFF00
	.word	0x0080, 0x0200, 0x0500, 0x0900
	.word	0x0E00, 0x1400, 0x1B00, 0x2300
	.word	0x2B00, 0x3300, 0x3A00, 0x3F00
	.word	0x3F00, 0x3A00, 0x3300, 0x2B00
	.word	0x2300, 0x1B00, 0x1400, 0x0E00
	.word	0x0900, 0x0500, 0x0200, 0x0080
	.word	0xFF00, 0xFE00, 0xFD80, 0xFC00

; IIR filter coefficients (b0, b1, a1) — first-order LP
iir_coeffs:
	.word	0x4000, 0x4000, 0xC000		; b0, b1, -a1

; CRC-16-CCITT lookup table (256 entries — full table)
; Showing first 32 here for size; rest would be regenerated.
crc16_tbl:
	.word	0x0000, 0x1021, 0x2042, 0x3063
	.word	0x4084, 0x50A5, 0x60C6, 0x70E7
	.word	0x8108, 0x9129, 0xA14A, 0xB16B
	.word	0xC18C, 0xD1AD, 0xE1CE, 0xF1EF
	.word	0x1231, 0x0210, 0x3273, 0x2252
	.word	0x52B5, 0x4294, 0x72F7, 0x62D6
	.word	0x9339, 0x8318, 0xB37B, 0xA35A
	.word	0xD3BD, 0xC39C, 0xF3FF, 0xE3DE
	.word	0x2462, 0x3443, 0x0420, 0x1401
	.word	0x64E6, 0x74C7, 0x44A4, 0x5485
	.word	0xA56A, 0xB54B, 0x8528, 0x9509
	.word	0xE5EE, 0xF5CF, 0xC5AC, 0xD58D
	.word	0x3653, 0x2672, 0x1611, 0x0630
	.word	0x76D7, 0x66F6, 0x5695, 0x46B4
	.word	0xB75B, 0xA77A, 0x9719, 0x8738
	.word	0xF7DF, 0xE7FE, 0xD79D, 0xC7BC

; Phase increments for synthetic waveform generation
phase_steps:
	.word	0x0080, 0x0100, 0x0180, 0x0200
	.word	0x0300, 0x0400, 0x0600, 0x0800
	.word	0x0A00, 0x0C00, 0x0F00, 0x1200
	.word	0x1500, 0x1A00, 0x2000, 0x2800

; Log-compander table (Q15 -> companded value)
log_tbl:
	.word	0x0000, 0x0124, 0x0249, 0x036E
	.word	0x0494, 0x05BB, 0x06E2, 0x080A
	.word	0x0933, 0x0A5D, 0x0B88, 0x0CB4
	.word	0x0DE1, 0x0F0F, 0x103E, 0x116E
	.word	0x129F, 0x13D1, 0x1505, 0x163A
	.word	0x1771, 0x18A8, 0x19E1, 0x1B1B
	.word	0x1C57, 0x1D94, 0x1ED3, 0x2013
	.word	0x2155, 0x2298, 0x23DD, 0x2523

;======================================================================
; .data — initialized run-time mutable data
;======================================================================
	.data

dp_base:
	.word	0			; data-page base
phase:
	.word	0			; current phase accumulator
iir_z1:
	.word	0			; IIR delay element
energy_acc:
	.long	0			; 32-bit energy accumulator
output_count:
	.word	0			; output sample count

;======================================================================
; .bss — uninitialized: input ring, output buffer, state
;======================================================================
	.bss	input_ring,  RING
	.bss	output_buf,  SAMPLES
	.bss	fir_delay,   N_TAPS
	.bss	scratch_a,   16
	.bss	scratch_b,   16
	.bss	crc_state,   1

	.global _c_int00
	.global _main
	.global _init_input
	.global _crc16_compute
	.global _iir_lowpass
	.global _fir_lowpass
	.global _energy
	.global _compress
	.global _output_word

;======================================================================
; .text — code section
;======================================================================
	.sect	".text"

;----------------------------------------------------------------------
; _c_int00 — C runtime entry. Sets up SP, DP, clears .bss, calls main.
;----------------------------------------------------------------------
_c_int00:
	; Disable interrupts during init
	ssbx	intm
	; Set up status registers
	ssbx	sxm			; sign-extension mode on
	rsbx	ovm			; saturation off
	rsbx	cpl			; compiler mode off
	; Initialize stack pointer
	stm	#0x3F00, SP		; SP near top of data RAM
	; Initialize DP to point at .data
	ld	#dp_base, dp
	; Clear .bss (the C runtime would zero it; we just touch it)
	stm	#input_ring, AR2
	stm	#(RING + SAMPLES + N_TAPS + 32), BRC
	rptb	cinit_end-1
	st	#0, *AR2+
cinit_end:
	; Enable interrupts and call main
	rsbx	intm
	call	_main
	; If main returns, halt with IDLE
hlt_loop:
	idle	1
	b	hlt_loop

;----------------------------------------------------------------------
; main() — top-level pipeline
;----------------------------------------------------------------------
_main:
	pshm	AR1
	mvmm	SP, AR1
	frame	#-4
	; Step 1: init input buffer
	call	_init_input
	; Step 2: compute CRC over input
	call	_crc16_compute
	stl	a, @crc_state
	; Step 3: IIR low-pass
	call	_iir_lowpass
	; Step 4: FIR low-pass (replaces output)
	call	_fir_lowpass
	; Step 5: compute energy
	call	_energy
	; Step 6: log compander
	call	_compress
	; Step 7: write a few words out
	stm	#output_buf, AR2
	stm	#15, BRC
	rptb	main_out_end-1
	ld	*AR2+, a
	call	_output_word
main_out_end:
	; Return 0
	ld	#0, a
	frame	#4
	popm	AR1
	ret

;----------------------------------------------------------------------
; init_input() — synthesize input by stepping through phase_steps
;----------------------------------------------------------------------
_init_input:
	pshm	AR1
	mvmm	SP, AR1
	stm	#input_ring, AR2
	stm	#phase_steps, AR3
	stm	#(RING - 1), BRC
	; Read current phase into A
	ld	@phase, a
	rptb	ii_end-1
	add	*AR3+0%, a		; A += phase_step (with circular)
	stl	a, *AR2+
ii_end:
	stl	a, @phase
	popm	AR1
	ret

;----------------------------------------------------------------------
; crc16_compute() — CRC-16-CCITT over input_ring, result in A
;----------------------------------------------------------------------
_crc16_compute:
	pshm	AR1
	mvmm	SP, AR1
	stm	#input_ring, AR2
	stm	#crc16_tbl,  AR3
	ld	#0xFFFF, a		; initial CRC
	stm	#(RING - 1), BRC
	rptb	crc_end-1
	; tmp = ((crc >> 8) ^ *p++) & 0xFF
	stl	a, *AR1
	ld	*AR1, b
	sftl	b, -8			; B = crc >> 8
	xor	*AR2+, b		; B ^= *AR2++
	and	#0xFF, b		; B &= 0xFF
	stl	b, *AR1
	; crc = (crc << 8) ^ table[tmp]
	sftl	a, 8			; A = crc << 8
	ld	*AR1, b
	add	#crc16_tbl, b		; B = &table[tmp]
	xor	*AR2, a			; A ^= table[tmp]  (indirect via *AR3+tmp)
crc_end:
	popm	AR1
	ret

;----------------------------------------------------------------------
; iir_lowpass() — first-order IIR over input_ring, in-place
;   y[n] = b0*x[n] + b1*x[n-1] - a1*y[n-1]
;
; Uses MAC Smem, SRC form: multiplies T by Smem, adds to accumulator.
; We preload T with the appropriate operand each step.
;----------------------------------------------------------------------
_iir_lowpass:
	pshm	AR1
	mvmm	SP, AR1
	stm	#input_ring, AR2	; sample pointer
	stm	#iir_coeffs, AR3	; coefficient pointer
	stm	#(RING - 1), BRC
	rptb	iir_end-1
	; T = x[n]
	ld	*AR2, t
	; A = T * b0 = x[n] * b0
	mpy	*AR3+, a
	; T = z1 (delay)
	ld	@iir_z1, t
	; A += T * b1 = z1 * b1
	mac	*AR3+, a
	; T = old output sample
	ld	@iir_z1, t
	; A += T * (-a1)
	mac	*AR3+, a
	; saturate and store
	sat	a
	sth	a, *AR2+
	; update delay state (use the just-loaded sample)
	stl	a, @iir_z1
	; reset coefficient pointer for next iteration
	stm	#iir_coeffs, AR3
iir_end:
	popm	AR1
	ret

;----------------------------------------------------------------------
; fir_lowpass() — 32-tap FIR with circular buffer in fir_delay
;   Reads from input_ring, writes to output_buf
;----------------------------------------------------------------------
_fir_lowpass:
	pshm	AR1
	mvmm	SP, AR1
	stm	#input_ring, AR4	; input source
	stm	#fir_delay,  AR2	; circular buffer
	stm	#fir_coeffs, AR3	; coefficient ROM
	stm	#output_buf, AR5	; output destination
	stm	#N_TAPS, BK		; circular size
	stm	#0, AR0
	stm	#(SAMPLES - 1), BRC
	rptbd	fir_end-1
	nop
	nop
fir_top:
	ld	*AR4+, a		; load new input sample
	stl	a, *AR2+%		; insert into circular buffer
	rptz	a, #(N_TAPS - 1)
	mac	*AR2+0%, *AR3+0%, a	; tap MAC with both ptrs circular
	sth	a, *AR5+		; output sample
fir_end:
	popm	AR1
	ret

;----------------------------------------------------------------------
; energy() — sum of squared output samples, into 32-bit energy_acc
;----------------------------------------------------------------------
_energy:
	pshm	AR1
	mvmm	SP, AR1
	stm	#output_buf, AR2
	ld	#0, b			; B = energy accumulator (32-bit)
	stm	#(SAMPLES - 1), BRC
	rptb	en_end-1
	squr	*AR2+, a		; A = x[i]^2
	add	a, b			; B += A
en_end:
	dst	b, @energy_acc		; store 32-bit result
	popm	AR1
	ret

;----------------------------------------------------------------------
; compress() — log-companding via log_tbl over the upper half of
; output_buf. Tests cross-section lookup.
;----------------------------------------------------------------------
_compress:
	pshm	AR1
	mvmm	SP, AR1
	stm	#output_buf+(SAMPLES/2), AR2
	stm	#log_tbl,   AR3
	stm	#((SAMPLES/2) - 1), BRC
	rptb	cmp_end-1
	; Use upper 5 bits of sample as table index
	ld	*AR2, a
	sftl	a, -11			; A = sample >> 11
	and	#0x1F, a		; A &= 0x1F  (5-bit index)
	; load log_tbl[index]  (gather, simplified)
	stl	a, *AR1
	ld	*AR1, t
	add	*AR3+, a		; A = log_tbl[idx]  (approximate)
	stl	a, *AR2+
cmp_end:
	popm	AR1
	ret

;----------------------------------------------------------------------
; output_word(value) — write to a memory-mapped peripheral (AXR0)
;   Argument in A.
;----------------------------------------------------------------------
_output_word:
	; In real code this would write to an MMR; we just touch
	; the counter and a scratch.
	stl	a, @scratch_a
	ld	@output_count, b
	add	#1, b
	stl	b, @output_count
	ret

;----------------------------------------------------------------------
; A small interrupt handler — would be installed in .vectors
;----------------------------------------------------------------------
	.global _timer_isr
_timer_isr:
	pshm	AR1
	pshm	ST0			; save flags
	ld	@output_count, a
	add	#1, a
	stl	a, @output_count
	popm	ST0
	popm	AR1
	rete

	.end
