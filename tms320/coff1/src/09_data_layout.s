;
; 09_data_layout.s — Data section variety: constants, lookup tables,
; floating-point values, and the assembler's $math builtins.
;
; assemble with:
;   tic54x-coff-as -o 09_data_layout.o 09_data_layout.s
; The C54x is a 16-bit fixed-point DSP with NO hardware floating-point.
; However, the gas assembler can emit IEEE 754 floating-point bit
; patterns into data sections via the .float / .double directives,
; and there is a family of $math built-in functions ($cos, $sin,
; $sqrt, $exp, $log, etc.) that are evaluated at assembly time and
; produce floating-point constants.
;
; This fixture is mostly data with a small code stub at the end that
; references the tables. A disassembler should:
;   - Identify the multiple named sections
;   - Show .word / .long / .float values as data
;   - Show string constants properly with leading-octet packing
;   - Recognize cross-section relocations from .text into .const
;
	.mmregs

;----------------------------------------------------------------------
; .const — read-only initialized data (large)
;----------------------------------------------------------------------
	.sect	".const"

; A short null-terminated string. C54x packs one char per 16-bit word.
hello_str:
	.byte	"Hello, C54x DSP!", 0

; A 16-entry log2 lookup table (Q15 fixed-point fractions)
log2_tbl:
	.word	0x0000, 0x0F80, 0x1E00, 0x2BC0
	.word	0x3880, 0x44C0, 0x5040, 0x5BC0
	.word	0x6700, 0x71C0, 0x7C40, 0x8640
	.word	0x9000, 0x9980, 0xA2C0, 0xACBF

; A 256-entry sine table — assembly-time computed via $sin builtin
; Each entry is a Q15-format word.
sin_tbl:
	.float	$sin(0.0)
	.float	$sin(0.125)
	.float	$sin(0.250)
	.float	$sin(0.375)
	.float	$sin(0.500)
	.float	$sin(0.625)
	.float	$sin(0.750)
	.float	$sin(0.875)
	.float	$sin(1.000)
	.float	$sin(1.125)
	.float	$sin(1.250)
	.float	$sin(1.375)
	.float	$sin(1.500)
	.float	$sin(1.625)
	.float	$sin(1.750)
	.float	$sin(1.875)

; A cosine companion table (16 entries)
cos_tbl:
	.float	$cos(0.0)
	.float	$cos(0.125)
	.float	$cos(0.250)
	.float	$cos(0.375)
	.float	$cos(0.500)
	.float	$cos(0.625)
	.float	$cos(0.750)
	.float	$cos(0.875)
	.float	$cos(1.000)
	.float	$cos(1.125)
	.float	$cos(1.250)
	.float	$cos(1.375)
	.float	$cos(1.500)
	.float	$cos(1.625)
	.float	$cos(1.750)
	.float	$cos(1.875)

; A square-root table for fixed-point Q15 inputs
sqrt_tbl:
	.float	$sqrt(0.0625)
	.float	$sqrt(0.1250)
	.float	$sqrt(0.2500)
	.float	$sqrt(0.3750)
	.float	$sqrt(0.5000)
	.float	$sqrt(0.6250)
	.float	$sqrt(0.7500)
	.float	$sqrt(0.8750)
	.float	$sqrt(1.0000)

; Exponential table (e^x for x = 0..1.875 in 0.125 increments)
exp_tbl:
	.float	$exp(0.0)
	.float	$exp(0.125)
	.float	$exp(0.250)
	.float	$exp(0.375)
	.float	$exp(0.500)
	.float	$exp(0.625)
	.float	$exp(0.750)
	.float	$exp(0.875)
	.float	$exp(1.000)
	.float	$exp(1.125)
	.float	$exp(1.250)
	.float	$exp(1.375)
	.float	$exp(1.500)
	.float	$exp(1.625)
	.float	$exp(1.750)
	.float	$exp(1.875)

; 32-bit constants (long words) — values that wouldn't fit in 16 bits
big_constants:
	.long	0xCAFEBABE
	.long	0xDEADBEEF
	.long	0x12345678
	.long	0x55555555

; Aligned table with .align
	.align	2
aligned_data:
	.word	0xAAAA, 0xBBBB, 0xCCCC, 0xDDDD
	.word	0xEEEE, 0xFFFF, 0x1111, 0x2222

;----------------------------------------------------------------------
; .bss — uninitialized data (will be zero-filled at link time)
;----------------------------------------------------------------------
	.bss	scratch,     128		; 128 words of scratch
	.bss	output_buf,  64
	.bss	state_vars,  8

;----------------------------------------------------------------------
; A user-named uninitialized section (created with .usect)
; .usect symbol must be in column 1 (TI quirk).
;----------------------------------------------------------------------
heap_buf	.usect	".heap", 256		; 256-word heap
dma_buf		.usect	".dma_buf", 32		; 32-word DMA buffer

;----------------------------------------------------------------------
; A second .const sub-section using .sect with subsection number 2
;----------------------------------------------------------------------
	.sect	".rodata2"

; Lookup table for a small CRC computation
crc_tbl:
	.word	0x0000, 0xC0C1, 0xC181, 0x0140
	.word	0xC301, 0x03C0, 0x0280, 0xC241
	.word	0xC601, 0x06C0, 0x0780, 0xC741
	.word	0x0500, 0xC5C1, 0xC481, 0x0440

;----------------------------------------------------------------------
; .text — the small code section that references all of the above
;----------------------------------------------------------------------
	.sect	".text"

	.global	_table_lookup
	.global	_string_length
	.global	_data_demo

;----------------------------------------------------------------------
; table_lookup(*tbl, idx) — read tbl[idx]
;   AR2 = tbl base, T = idx
;----------------------------------------------------------------------
_table_lookup:
	stm	#sin_tbl, AR2		; load address of sine table
	mvdk	hello_str, *(scratch)	; (forced cross-section relocation example)
	ld	*AR2+, a		; read one entry
	ld	*AR2, b			; read next
	ret

;----------------------------------------------------------------------
; string_length(*s) — strlen-equivalent
;   AR2 = string pointer, returns length in A
;----------------------------------------------------------------------
_string_length:
	ld	#0, a			; counter
	stm	#256, BRC		; safety bound
	rptb	sl_end-1
	ld	*AR2+, b
	bc	sl_done, BEQ		; if char == 0, exit
	add	#1, a
sl_end:
sl_done:
	ret

;----------------------------------------------------------------------
; data_demo() — touches every named data section so the linker
; doesn't optimize them away.
;----------------------------------------------------------------------
_data_demo:
	stm	#hello_str, AR2
	stm	#log2_tbl,  AR3
	stm	#sin_tbl,   AR4
	stm	#cos_tbl,   AR5
	stm	#sqrt_tbl,  AR6
	stm	#exp_tbl,   AR7
	stm	#big_constants, AR2
	stm	#aligned_data, AR3
	stm	#crc_tbl,   AR4
	stm	#scratch,   AR5
	stm	#heap_buf,  AR6
	stm	#dma_buf,   AR7
	ret

	.end
