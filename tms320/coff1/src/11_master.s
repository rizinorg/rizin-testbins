;
; 11_master.s — Master TMS320C54x disassembler test fixture.
;
; assemble with:
;   tic54x-coff-as -o 11_master.o 11_master.s
;
; This file is the comprehensive test for a C54x disassembler. It is
; intentionally large (~100 KB source) and exercises every mnemonic
; in the binutils tic54x opcode table at least once, with as many
; operand-form variants as practical. Organized into one section per
; instruction family, with cross-references between sections to also
; test global symbol resolution and inter-section relocations.
;
; This fixture is deliberately *not* C-compiler-style — it's a hand-
; written assembly test. For compiler-mimic patterns see fixture 07.
;
; Coverage:
;   - All single-data-memory addressing modes
;   - All accumulator-source/destination variants
;   - All 32-bit (Lmem) instructions
;   - All long-immediate (#lk) forms with optional shifts
;   - All condition codes (AEQ/ANEQ/AGT/ALT/AGEQ/ALEQ/AOV/ANOV,
;     BEQ/BNEQ/BGT/BLT/BGEQ/BLEQ/BOV/BNOV, TC/NTC, C/NC, BIO/NBIO)
;   - Multi-condition branches (AND'ed predicates)
;   - All delay-slot variants (BD, BCD, CALLD, CCD, BANZD, RPTBD,
;     RETD, RETED, BACCD, CALAD, FBD, FCALLD, FCALAD, FRETD, FRETED)
;   - All parallel (||) instruction pairs
;   - All dual-data-memory (Xmem/Ymem) instructions
;   - All repeat constructs (RPT k, RPT Smem, RPTZ, RPTB, RPTBD)
;   - Conditional execute (XC 1 and XC 2 forms)
;   - All status-bit names with SSBX/RSBX
;   - Port I/O (PORTR/PORTW)
;   - Program/data memory moves (MVPD/MVDP/READA/WRITA)
;   - C548 extended-addressing instructions (FB, FCALL, FRET, etc.)
;   - The LDX pseudo-op
;   - The $math builtins ($sin, $cos, $sqrt, $exp, etc.) in data
;   - .float / .word / .long / .byte data directives
;   - .sect / .bss / .usect section variety
;

	.mmregs

	.bss	buf_a,    64		; 64-word scratch A
	.bss	buf_b,    64		; 64-word scratch B
	.bss	buf_c,    32
	.bss	buf_long, 16		; for 32-bit Lmem ops
	.bss	tmp_w,    1		; single word
	.bss	tmp_l,    2		; long
	.bss	ring_buf, 32		; circular buffer (BK = 32)
	.bss	debug_var,1

; Custom uninitialized sections via .usect
heap_a	.usect	".heap_a", 64
heap_b	.usect	".heap_b", 64

	.sect	".const"

coef_table_a:
	.word	0x0100, 0x0200, 0x0400, 0x0800, 0x1000, 0x2000, 0x4000, 0x2000
	.word	0x1000, 0x0800, 0x0400, 0x0200, 0x0100, 0x0080, 0x0040, 0x0020

coef_table_b:
	.word	0x7FFF, 0x7000, 0x6000, 0x5000, 0x4000, 0x3000, 0x2000, 0x1000
	.word	0xF000, 0xE000, 0xD000, 0xC000, 0xB000, 0xA000, 0x9000, 0x8000

string_table:
	.byte	"Test string 1", 0
	.byte	"Test string 2", 0
	.byte	"Test string 3", 0

long_constants:
	.long	0xCAFEBABE, 0xDEADBEEF, 0x12345678, 0x87654321
	.long	0xAAAA5555, 0x5555AAAA, 0xFFFFFFFF, 0x00000000

; Math-builtin constants — evaluated at assembly time
fp_table_sin:
	.float	$sin(0.0000)
	.float	$sin(0.0625)
	.float	$sin(0.1250)
	.float	$sin(0.1875)
	.float	$sin(0.2500)
	.float	$sin(0.3125)
	.float	$sin(0.3750)
	.float	$sin(0.4375)
	.float	$sin(0.5000)
	.float	$sin(0.5625)
	.float	$sin(0.6250)
	.float	$sin(0.6875)
	.float	$sin(0.7500)
	.float	$sin(0.8125)
	.float	$sin(0.8750)
	.float	$sin(0.9375)

fp_table_cos:
	.float	$cos(0.0000)
	.float	$cos(0.0625)
	.float	$cos(0.1250)
	.float	$cos(0.1875)
	.float	$cos(0.2500)
	.float	$cos(0.3125)
	.float	$cos(0.3750)
	.float	$cos(0.4375)
	.float	$cos(0.5000)
	.float	$cos(0.5625)
	.float	$cos(0.6250)
	.float	$cos(0.6875)
	.float	$cos(0.7500)
	.float	$cos(0.8125)
	.float	$cos(0.8750)
	.float	$cos(0.9375)

fp_table_sqrt:
	.float	$sqrt(0.0625)
	.float	$sqrt(0.1250)
	.float	$sqrt(0.1875)
	.float	$sqrt(0.2500)
	.float	$sqrt(0.3125)
	.float	$sqrt(0.3750)
	.float	$sqrt(0.4375)
	.float	$sqrt(0.5000)
	.float	$sqrt(0.5625)
	.float	$sqrt(0.6250)
	.float	$sqrt(0.6875)
	.float	$sqrt(0.7500)
	.float	$sqrt(0.8125)
	.float	$sqrt(0.8750)
	.float	$sqrt(0.9375)
	.float	$sqrt(1.0000)

fp_table_exp:
	.float	$exp(0.0000)
	.float	$exp(0.0625)
	.float	$exp(0.1250)
	.float	$exp(0.1875)
	.float	$exp(0.2500)
	.float	$exp(0.3125)
	.float	$exp(0.3750)
	.float	$exp(0.4375)
	.float	$exp(0.5000)
	.float	$exp(0.5625)
	.float	$exp(0.6250)
	.float	$exp(0.6875)
	.float	$exp(0.7500)
	.float	$exp(0.8125)
	.float	$exp(0.8750)
	.float	$exp(0.9375)

fp_table_log:
	.float	$log(0.0625)
	.float	$log(0.1250)
	.float	$log(0.1875)
	.float	$log(0.2500)
	.float	$log(0.3125)
	.float	$log(0.3750)
	.float	$log(0.4375)
	.float	$log(0.5000)
	.float	$log(0.5625)
	.float	$log(0.6250)
	.float	$log(0.6875)
	.float	$log(0.7500)
	.float	$log(0.8125)
	.float	$log(0.8750)
	.float	$log(0.9375)
	.float	$log(1.0000)

; Bulk data table — a varied set of constants for index/mask testing
large_data:
	.word	0x0000, 0x0007, 0x001A, 0x0039, 0x005C, 0x0091, 0x00BA, 0x0103
	.word	0x0008, 0x003F, 0x0082, 0x00D1, 0x0114, 0x0179, 0x01B2, 0x022B
	.word	0x0010, 0x0077, 0x00EA, 0x0169, 0x01CC, 0x0261, 0x02AA, 0x0353
	.word	0x0018, 0x00AF, 0x0152, 0x0201, 0x0284, 0x0349, 0x03A2, 0x047B
	.word	0x0020, 0x00E7, 0x01BA, 0x0299, 0x033C, 0x0431, 0x049A, 0x05A3
	.word	0x0028, 0x011F, 0x0222, 0x0331, 0x03F4, 0x0519, 0x0592, 0x06CB
	.word	0x0030, 0x0157, 0x028A, 0x03C9, 0x04AC, 0x0601, 0x068A, 0x07F3
	.word	0x0038, 0x018F, 0x02F2, 0x0461, 0x0564, 0x06E9, 0x0782, 0x091B
	.word	0x0040, 0x01C7, 0x035A, 0x04F9, 0x061C, 0x07D1, 0x087A, 0x0A43
	.word	0x0048, 0x01FF, 0x03C2, 0x0591, 0x06D4, 0x08B9, 0x0972, 0x0B6B
	.word	0x0050, 0x0237, 0x042A, 0x0629, 0x078C, 0x09A1, 0x0A6A, 0x0C93
	.word	0x0058, 0x026F, 0x0492, 0x06C1, 0x0844, 0x0A89, 0x0B62, 0x0DBB
	.word	0x0060, 0x02A7, 0x04FA, 0x0759, 0x08FC, 0x0B71, 0x0C5A, 0x0EE3
	.word	0x0068, 0x02DF, 0x0562, 0x07F1, 0x09B4, 0x0C59, 0x0D52, 0x100B
	.word	0x0070, 0x0317, 0x05CA, 0x0889, 0x0A6C, 0x0D41, 0x0E4A, 0x1133
	.word	0x0078, 0x034F, 0x0632, 0x0921, 0x0B24, 0x0E29, 0x0F42, 0x125B
	.word	0x0080, 0x0387, 0x069A, 0x09B9, 0x0BDC, 0x0F11, 0x103A, 0x1383
	.word	0x0088, 0x03BF, 0x0702, 0x0A51, 0x0C94, 0x0FF9, 0x1132, 0x14AB
	.word	0x0090, 0x03F7, 0x076A, 0x0AE9, 0x0D4C, 0x10E1, 0x122A, 0x15D3
	.word	0x0098, 0x042F, 0x07D2, 0x0B81, 0x0E04, 0x11C9, 0x1322, 0x16FB
	.word	0x00A0, 0x0467, 0x083A, 0x0C19, 0x0EBC, 0x12B1, 0x141A, 0x1823
	.word	0x00A8, 0x049F, 0x08A2, 0x0CB1, 0x0F74, 0x1399, 0x1512, 0x194B
	.word	0x00B0, 0x04D7, 0x090A, 0x0D49, 0x102C, 0x1481, 0x160A, 0x1A73
	.word	0x00B8, 0x050F, 0x0972, 0x0DE1, 0x10E4, 0x1569, 0x1702, 0x1B9B
	.word	0x00C0, 0x0547, 0x09DA, 0x0E79, 0x119C, 0x1651, 0x17FA, 0x1CC3
	.word	0x00C8, 0x057F, 0x0A42, 0x0F11, 0x1254, 0x1739, 0x18F2, 0x1DEB
	.word	0x00D0, 0x05B7, 0x0AAA, 0x0FA9, 0x130C, 0x1821, 0x19EA, 0x1F13
	.word	0x00D8, 0x05EF, 0x0B12, 0x1041, 0x13C4, 0x1909, 0x1AE2, 0x203B
	.word	0x00E0, 0x0627, 0x0B7A, 0x10D9, 0x147C, 0x19F1, 0x1BDA, 0x2163
	.word	0x00E8, 0x065F, 0x0BE2, 0x1171, 0x1534, 0x1AD9, 0x1CD2, 0x228B
	.word	0x00F0, 0x0697, 0x0C4A, 0x1209, 0x15EC, 0x1BC1, 0x1DCA, 0x23B3
	.word	0x00F8, 0x06CF, 0x0CB2, 0x12A1, 0x16A4, 0x1CA9, 0x1EC2, 0x24DB

	.sect	".text"


; ====================================================================
; SECTION 1: arithmetic — ADD/SUB/MPY/MAC/ABS/NEG/EXP/NORM family
; ====================================================================

; --- _add_forms -----------------------------------------------------
; Every variant of the ADD instruction.
_add_forms:
	add	b, a			; A += B
	add	b, 4, a			; A += B << 4
	add	b, -4, a		; A += B >> 4 (arith)
	add	@tmp_w, a		; A += tmp_w (DP-relative)
	add	*ar2, a			; A += *AR2 (indirect)
	add	*ar2+, a		; A += *AR2++
	add	*ar2-, a		; A += *AR2--
	add	*+ar2(1), a		; A += *(AR2+1)
	add	*ar2(5), a		; A += *(AR2 with offset 5)
	add	*+ar2(7), a		; A += *(AR2+7)
	add	*ar2+0, a		; A += *AR2; AR2 += AR0
	add	*ar2+0%, a		; A += *AR2; AR2 = circ(AR2+AR0)
	add	*ar2-0, a
	add	*ar2-0%, a
	add	*ar2, 16, a		; A += *AR2 << 16
	add	*ar2, 16, a, b		; B = A + *AR2 << 16  (with explicit DST)
	add	*ar2+, *ar3+, a		; A = *AR2++ + *AR3++
	add	*ar4+, *ar5+, b		; dual ADD with B as dst
	add	#0x1234, a		; A += 0x1234
	add	#0x5678, 8, a		; A += 0x5678 << 8
	add	#0xFFFF, 16, a, b	; B = A + 0xFFFF << 16
	ret

; --- _addc_addm_adds -----------------------------------------------------
_addc_addm_adds:
	addc	@tmp_w, a		; A += tmp_w + C (carry)
	addc	*ar2+, b
	addm	#0x100, @tmp_w		; tmp_w += 0x100  (mem add)
	addm	#0xFF00, *ar2
	adds	@tmp_w, a		; A += unsigned(tmp_w)
	adds	*ar3+, b
	ret

; --- _sub_forms -----------------------------------------------------
_sub_forms:
	sub	b, a			; A -= B
	sub	a, b			; B -= A
	sub	b, 4, a
	sub	@tmp_w, a
	sub	*ar2+, a
	sub	*ar2(3), a
	sub	*ar2-0%, b
	sub	*ar2, 16, a
	sub	*ar2, 16, a, b
	sub	*ar2+, *ar3+, a
	sub	#0x1234, a
	sub	#0x5678, 8, a
	sub	#0xCCCC, 16, a, b
	subb	@tmp_w, a		; A -= tmp_w + ~C (borrow)
	subb	*ar2+, b
	subc	@tmp_w, a		; SUBC: conditional subtract (for div)
	subs	@tmp_w, a		; A -= unsigned(tmp_w)
	subs	*ar3+, b
	ret

; --- _mpy_forms -----------------------------------------------------
; All multiply variants.
_mpy_forms:
	mpy	@tmp_w, a		; A = T * tmp_w
	mpy	*ar2+, b		; B = T * *AR2++
	mpy	*ar2, *ar3, a		; dual: A = *AR2 * *AR3
	mpy	*ar2+, *ar3+, b
	mpy	#0x100, a		; A = T * 0x100
	mpy	*ar2, #0x200, a		; A = *AR2 * 0x200
	mpyr	@tmp_w, a		; multiply with round
	mpyr	*ar3+, b
	mpyu	@tmp_w, a		; unsigned multiply
	mpyu	*ar2+, b
	mpya	a			; A = T * A (multiply-by-accumulator)
	mpya	@tmp_w			; mpya Smem variant
	ret

; --- _mac_forms -----------------------------------------------------
; Multiply-accumulate and related.
_mac_forms:
	mac	@tmp_w, a		; A += T * tmp_w
	mac	*ar2+, b
	mac	*ar2+, *ar3+, a
	mac	*ar4+, *ar5+, b
	mac	#0x100, a		; A += T * 0x100
	mac	*ar2, #0x200, a
	macr	@tmp_w, a		; MAC with round
	macr	*ar2+, *ar3+, a
	mas	@tmp_w, a		; multiply-and-subtract
	mas	*ar2+, *ar3+, a
	masr	*ar2+, *ar3+, a		; MAS with round
	maca	@tmp_w			; mac-with-T register (Smem,B form)
	macar	@tmp_w		; mac-with-T, round (Smem,B form)
	macsu	*ar2+, *ar3+, a		; signed-unsigned MAC
	macp	@tmp_w, mac_table, a	; multiply by program-memory operand
	macd	@tmp_w, mac_table, a	; same with delay
mac_table:
	.word	0x1234, 0x5678, 0xabcd, 0xef00
	ret

; --- _abs_neg_squr -----------------------------------------------------
; Single-operand arithmetic.
_abs_neg_squr:
	abs	a
	abs	a, b
	neg	a
	neg	a, b
	squr	a, b		; B = A * A  (accumulator square)
	squr	@tmp_w, a	; A = (tmp_w) * (tmp_w)
	squra	@tmp_w, a	; A += squr(tmp_w)
	squrs	@tmp_w, a	; A -= squr(tmp_w)
	ret

; --- _exp_norm_minmax_rnd -----------------------------------------------------
; Single-operand utilities.
_exp_norm_minmax_rnd:
	exp	a		; T = exponent of A (leading sign bits)
	norm	a		; normalize A using T
	norm	a, b
	max	a
	min	a
	; RND not used here — requires .version 545LP
	ret

; --- _lmem_arith -----------------------------------------------------
; 32-bit (long memory) arithmetic.
_lmem_arith:
	dld	*ar2, a		; load 32-bit value into A
	dld	@tmp_l, b
	dst	a, *ar3		; store 32-bit A
	dst	b, @tmp_l
	dadd	*ar2, a
	dadd	*ar2, a, b
	dsub	*ar2, a
	drsub	*ar2, a		; reverse subtract: A = mem - A
	dadst	*ar2, a		; double add/subtract
	dsadt	*ar2, a
	dsubt	*ar2, a
	ret

; ====================================================================
; SECTION 2: load/store — LD/LDM/LDU/LDR/STL/STH/ST/STM/STLM
; ====================================================================

; --- _ld_forms -----------------------------------------------------
; Every variant of LD.
_ld_forms:
	ld	#0, a
	ld	#0xFF, b
	ld	#5, asm		; ASM = signed shift mode reg (5-bit)
	ld	#3, arp
	ld	#0x100, dp
	ld	@tmp_w, t
	ld	*ar2+, t
	ld	@tmp_w, dp
	ld	@tmp_w, asm
	ld	@tmp_w, a
	ld	*ar2+, b
	ld	@tmp_w, 16, a		; load << 16
	ld	*ar2, 16, b
	ld	*ar2, 16, a
	ld	*ar2+, -8, a
	ld	*ar2, 4, a
	ld	*ar2, 4, b
	ld	#0x1234, 8, a
	ld	#0xFFFF, 4, b
	ld	#0x5678, 16, a
	ld	b, 4, a
	ld	a, -4, b
	ld	b, asm, a
	ret

; --- _ldr_ldu_ldm -----------------------------------------------------
_ldr_ldu_ldm:
	ldr	@tmp_w, a		; load with round
	ldr	*ar2+, b
	ldu	@tmp_w, a		; load unsigned
	ldu	*ar3+, b
	ldm	ar2, a			; load MMR into accumulator
	ldm	sp, b
	ldm	bk, a
	ret

; --- _st_forms -----------------------------------------------------
_st_forms:
	st	t, @tmp_w
	st	t, *ar3
	st	trn, @tmp_w
	st	#0x1234, @tmp_w
	st	#0x5678, *ar2+
	stl	a, @tmp_w
	stl	a, *ar2+
	stl	a, -8, @tmp_w		; with shift
	stl	a, 4, *ar3+
	stl	a, asm, @tmp_w
	sth	a, @tmp_w
	sth	a, *ar2+
	sth	a, 4, @tmp_w
	sth	a, asm, @tmp_w
	stm	#0x1234, ar2
	stm	#32, bk
	stm	#0, ar0
	stm	#10, brc
	stlm	a, ar3
	stlm	b, t
	ret

; ====================================================================
; SECTION 3: data movement — MVDD/MVDK/MVKD/MVDM/MVMD/MVMM/MVPD/MVDP
; ====================================================================

; --- _move_family -----------------------------------------------------
_move_family:
	mvdd	*ar2+, *ar3+		; data to data (indirect)
	mvdk	@tmp_w, dst_dmad	; data (Smem) -> direct addr
	mvkd	src_dmad, *ar3		; direct addr -> data (Smem)
	mvdm	src_dmad, ar4		; direct addr -> MMR
	mvmd	ar5, dst_dmad		; MMR -> direct addr
	mvmm	ar2, ar3		; MMR -> MMR
	mvmm	ar0, sp
	mvpd	#prog_data, @tmp_w	; program -> data
	mvdp	@tmp_w, #prog_data	; data -> program
	ret

src_dmad:	.word	0xAAAA
dst_dmad:	.word	0x5555
prog_data:	.word	0x1234, 0x5678

; --- _push_pop -----------------------------------------------------
_push_pop:
	pshm	ar0
	pshm	ar1
	pshm	brc
	pshm	rsa
	pshm	rea
	pshm	st0
	pshm	st1
	pshd	@tmp_w		; push data memory
	popd	@tmp_w		; pop into data memory
	popm	st1
	popm	st0
	popm	rea
	popm	rsa
	popm	brc
	popm	ar1
	popm	ar0
	ret

; ====================================================================
; SECTION 4: logical operations — AND/OR/XOR/CMPL
; ====================================================================

; --- _logic_forms -----------------------------------------------------
_logic_forms:
	and	b, a			; A &= B
	and	b, 4, a
	and	@tmp_w, a
	and	*ar2+, b
	and	#0xF000, a		; AND immediate
	and	#0xFF00, 8, a
	and	#0x5555, 16, a, b
	andm	#0x00FF, @tmp_w	; mem AND immediate
	andm	#0xFF00, *ar3
	or	b, a
	or	b, 4, a
	or	@tmp_w, a
	or	*ar2+, b
	or	#0x0F0F, a
	or	#0xAAAA, 8, a
	or	#0x5555, 16, a, b
	orm	#0x8000, @tmp_w
	orm	#0x0001, *ar3
	xor	b, a
	xor	b, 4, a
	xor	@tmp_w, a
	xor	*ar2+, b
	xor	#0xAAAA, a
	xor	#0x5555, 8, a
	xor	#0xCCCC, 16, a, b
	xorm	#0xFFFF, @tmp_w
	xorm	#0x1234, *ar3
	cmpl	a			; A = ~A (logical complement)
	cmpl	a, b
	ret

; ====================================================================
; SECTION 5: shifts and bit ops — SFTA/SFTL/SFTC/ROL/ROR/BIT
; ====================================================================

; --- _shift_forms -----------------------------------------------------
_shift_forms:
	sfta	a, 4		; arithmetic left shift
	sfta	a, -4		; arithmetic right (sign-ext)
	sfta	a, 8, b		; with separate dest
	sftl	a, 4		; logical left
	sftl	a, -4		; logical right (zero-fill)
	sftl	a, 12, b
	sftc	a		; conditional shift (norm aid)
	; sftc only takes one operand
	rol	a		; rotate left through carry
	ror	a		; rotate right
	roltc	a		; rotate-left-with-test-control
	ret

; --- _bit_ops -----------------------------------------------------
_bit_ops:
	bit	*ar2, 0		; TC = bit[0] of *AR2
	bit	*ar2, 15	; bit 15
	bit	*ar3+, 8
	bitf	@tmp_w, #0xF000	; TC = (tmp_w & 0xF000) != 0
	bitf	*ar2, #0x0001
	bitt	@tmp_w		; TC = bit T of tmp_w
	bitt	*ar2
	ret

; ====================================================================
; SECTION 6: compares — CMPM/CMPS/CMPR
; ====================================================================

; --- _compare_ops -----------------------------------------------------
_compare_ops:
	cmpm	@tmp_w, #0x1234	; TC = (tmp_w == 0x1234)
	cmpm	*ar2, #0xFFFF
	cmps	a, @tmp_w	; compare halves of A, store min
	cmps	b, *ar3
	cmpr	eq, ar0		; TC = (AR0 == AR0)
	cmpr	lt, ar1		; TC = (AR1 < AR0)
	cmpr	gt, ar2
	cmpr	neq, ar3
	cmpr	0, ar4		; numeric form of EQ
	cmpr	1, ar5		; LT
	cmpr	2, ar6		; GT
	cmpr	3, ar7		; NEQ
	ret

; ====================================================================
; SECTION 7: branches and calls — B/BC/BD/BCD/CALL/CC/etc
; ====================================================================

; --- _branch_forms -----------------------------------------------------
_branch_forms:
	b	bf1			; unconditional
	bd	bf2			; delayed
	nop				; (delay slot)
	nop
bf1:
	bc	bf3, AEQ
	bc	bf3, ANEQ
	bc	bf3, AGT
	bc	bf3, AGEQ
	bc	bf3, ALT
	bc	bf3, ALEQ
	bc	bf3, AOV
	bc	bf3, ANOV
	bc	bf3, BEQ
	bc	bf3, BNEQ
	bc	bf3, BGT
	bc	bf3, BGEQ
	bc	bf3, BLT
	bc	bf3, BLEQ
	bc	bf3, BOV
	bc	bf3, BNOV
	bc	bf3, TC
	bc	bf3, NTC
	bc	bf3, C
	bc	bf3, NC
	bc	bf3, BIO
	bc	bf3, NBIO
bf2:
	bcd	bf3, AEQ		; delayed conditional
	nop
	nop
bf3:
	; Multi-condition branches — predicates within same group
	bc	bf4, AEQ, AOV		; both accumulator conditions
	bc	bf4, BNEQ, BOV		; B-accumulator conditions
	bc	bf4, AGT, ANOV		; A-accumulator group
bf4:
	ret

; --- _call_forms -----------------------------------------------------
_call_forms:
	call	_add_forms
	calld	_sub_forms
	nop
	nop
	cc	_mpy_forms, AEQ
	cc	_logic_forms, BGEQ
	ccd	_st_forms, ALT
	nop
	nop
	ret

; --- _banz_demo -----------------------------------------------------
; BANZ — branch if AR not zero
_banz_demo:
	stm	#10, ar1		; loop count
banz_top:
	nop
	nop
	banz	banz_top, *ar1-		; AR1!=0 ? branch, then decrement
	banzd	banz_end, *ar2-		; delayed BANZ
	nop
	nop
banz_end:
	ret

; --- _acc_branch_demo -----------------------------------------------------
; BACC/CALA — branch/call via accumulator
_acc_branch_demo:
	ld	#bacc_tgt, a
	bacc	a
	baccd	b
	nop
	nop
	ld	#cala_tgt, a
	cala	a
	calad	b
	nop
	nop
bacc_tgt:
cala_tgt:
	ret

; --- _rc_demo -----------------------------------------------------
; Conditional return.
_rc_demo:
	rc	AEQ
	rc	BNEQ
	rc	AEQ, AOV		; multi-cond conditional return
	rcd	AEQ			; delayed conditional return
	nop
	nop
	ret

; --- _return_variants -----------------------------------------------------
_return_variants:
	ret
ret_v2:	retd			; delayed return
	nop
	nop
ret_v3:	rete			; return + enable interrupts
ret_v4:	reted			; delayed RETE
	nop
	nop
ret_v5:	retf			; fast return
ret_v6:	retfd
	nop
	nop

; ====================================================================
; SECTION 8: repeat constructs — RPT/RPTZ/RPTB/RPTBD/XC
; ====================================================================

; --- _repeat_forms -----------------------------------------------------
_repeat_forms:
	rpt	#15			; repeat next instr 16 times
	add	*ar2+, a
	rpt	@tmp_w			; repeat count from memory
	add	*ar2+, a
	rptz	a, #31			; clear A, repeat 32 times
	mac	*ar3+, *ar4+, a
	rptb	rpt_end-1		; block repeat
	add	*ar2+, a
	sub	*ar3+, a
	and	*ar4+, a
rpt_end:
	rptbd	rpt2_end-1		; delayed block repeat
	nop				; delay slot 1
	nop				; delay slot 2
	mac	*ar2+, *ar3+, a
	mac	*ar2+, *ar3+, a
rpt2_end:
	ret

; --- _xc_demo -----------------------------------------------------
; Conditional execute — next 1 or 2 instructions.
_xc_demo:
	cmpm	@tmp_w, #100
	xc	1, TC			; next 1 instruction conditional
	add	#1, a
	xc	2, AGT			; next 2 instructions conditional
	ld	#0xFFFF, a
	stl	a, *ar2+
	xc	1, AEQ
	neg	a
	xc	2, BLEQ
	or	#0x8000, a
	and	#0x7FFF, b
	ret

; ====================================================================
; SECTION 9: parallel (||) and dual Xmem/Ymem instructions
; ====================================================================

; --- _parallel_demo -----------------------------------------------------
_parallel_demo:
	ld	*ar2+, a || mac	*ar3+, b
	ld	*ar2+, a || macr	*ar3+, b
	ld	*ar2+, a || mas	*ar3+, b
	ld	*ar2+, a || masr	*ar3+, b
	st	a, *ar2+ || add	*ar3+, b
	st	a, *ar2+ || ld	*ar3+, b
	st	a, *ar2+ || ld	*ar3+, t
	st	a, *ar2+ || mac	*ar3+, b
	st	a, *ar2+ || macr	*ar3+, b
	st	a, *ar2+ || mas	*ar3+, b
	st	a, *ar2+ || masr	*ar3+, b
	st	a, *ar2+ || mpy	*ar3+, b
	st	a, *ar2+ || sub	*ar3+, b
	nop
	ret

; ====================================================================
; SECTION 10: special DSP — FIRS/LMS/POLY/ABDST/SQDST/SACCD/SRCCD/STRCD
; ====================================================================

; --- _dsp_special -----------------------------------------------------
_dsp_special:
	firs	*ar2+, *ar3+, fir_coef	; symmetric FIR
	lms	*ar2+, *ar3+		; least mean squared
	poly	@tmp_w			; polynomial eval helper
	abdst	*ar2+, *ar3+		; absolute distance
	sqdst	*ar2+, *ar3+		; squared distance
	ltd	@tmp_w			; load T and delay
	delay	@tmp_w			; copy *p to *(p+1)
	ret

fir_coef:
	.word	0x100, 0x200, 0x400, 0x800

; --- _sxxcd_demo -----------------------------------------------------
; Conditional store: SACCD/SRCCD/STRCD.
_sxxcd_demo:
	saccd	a, *ar2+, AEQ		; conditional accumulator store
	saccd	b, *ar3+, BGEQ
	srccd	*ar2+, AEQ		; conditional store of T
	srccd	*ar3+, ANEQ
	strcd	*ar2+, AGT		; conditional store of TRN
	strcd	*ar3+, ALT
	ret

; ====================================================================
; SECTION 11: I/O and program/data transfers
; ====================================================================

; --- _io_forms -----------------------------------------------------
_io_forms:
	portr	#0x10, @tmp_w		; read I/O port 0x10
	portr	#0x20, *ar2+
	portw	@tmp_w, #0x30		; write to I/O port 0x30
	portw	*ar2+, #0x40
	reada	@tmp_w			; read from prog mem via A
	reada	*ar2+
	writa	@tmp_w			; write to prog mem via A
	writa	*ar2+
	ret

; ====================================================================
; SECTION 12: status bits, MAR, NOP family, idle, interrupts
; ====================================================================

; --- _status_demo -----------------------------------------------------
_status_demo:
	; All status-bit names
	ssbx	sxm		; sign-extension mode
	rsbx	sxm
	ssbx	ovm		; overflow saturation
	rsbx	ovm
	ssbx	c		; carry
	rsbx	c
	ssbx	tc		; test/control bit
	rsbx	tc
	ssbx	hm		; hold mode
	rsbx	hm
	ssbx	cpl		; compiler mode
	rsbx	cpl
	ssbx	intm		; interrupt mask
	rsbx	intm
	ssbx	xf		; XF status bit
	rsbx	xf
	ssbx	braf		; block repeat active
	rsbx	braf
	ssbx	c16		; dual 16-bit mode
	rsbx	c16
	ssbx	frct		; fractional mode
	rsbx	frct
	ssbx	cmpt		; compatibility mode
	rsbx	cmpt
	ret

; --- _misc_demo -----------------------------------------------------
_misc_demo:
	mar	*ar2+			; modify AR2 (post-inc, no load)
	mar	*ar3-
	mar	*ar4+0
	mar	*ar5+0%
	mar	*ar2(5)
	nop				; nop instruction
	idle	1			; idle level 1 (until next interrupt)
	idle	2			; idle level 2
	idle	3			; idle level 3 (deepest)
	intr	0			; software interrupt 0
	intr	16			; software interrupt 16
	intr	31
	trap	0			; trap
	trap	15
	estop				; emulation stop
	ret

reset_vec:
	reset				; reset (jumps to vector)

; ====================================================================
; SECTION 13: stress test — many similar functions with shifts and addressing variation
; ====================================================================

_stress_00:
	pshm	ar1
	stm	#0x0000, ar1
	ld	#0x0000, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x0000, a
	or	#0x0000, a
	xor	#0x0000, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_01:
	pshm	ar1
	stm	#0x0010, ar1
	ld	#0x0111, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x00CC, a
	or	#0x0055, a
	xor	#0x0033, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_02:
	pshm	ar1
	stm	#0x0020, ar1
	ld	#0x0222, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x0198, a
	or	#0x00AA, a
	xor	#0x0066, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_03:
	pshm	ar1
	stm	#0x0030, ar1
	ld	#0x0333, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x0264, a
	or	#0x00FF, a
	xor	#0x0099, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_04:
	pshm	ar1
	stm	#0x0040, ar1
	ld	#0x0444, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x0330, a
	or	#0x0154, a
	xor	#0x00CC, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_05:
	pshm	ar1
	stm	#0x0050, ar1
	ld	#0x0555, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x03FC, a
	or	#0x01A9, a
	xor	#0x00FF, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_06:
	pshm	ar1
	stm	#0x0060, ar1
	ld	#0x0666, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x04C8, a
	or	#0x01FE, a
	xor	#0x0132, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_07:
	pshm	ar1
	stm	#0x0070, ar1
	ld	#0x0777, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x0594, a
	or	#0x0253, a
	xor	#0x0165, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_08:
	pshm	ar1
	stm	#0x0080, ar1
	ld	#0x0888, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x0660, a
	or	#0x02A8, a
	xor	#0x0198, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_09:
	pshm	ar1
	stm	#0x0090, ar1
	ld	#0x0999, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x072C, a
	or	#0x02FD, a
	xor	#0x01CB, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_10:
	pshm	ar1
	stm	#0x00A0, ar1
	ld	#0x0AAA, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x07F8, a
	or	#0x0352, a
	xor	#0x01FE, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_11:
	pshm	ar1
	stm	#0x00B0, ar1
	ld	#0x0BBB, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x08C4, a
	or	#0x03A7, a
	xor	#0x0231, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_12:
	pshm	ar1
	stm	#0x00C0, ar1
	ld	#0x0CCC, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x0990, a
	or	#0x03FC, a
	xor	#0x0264, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_13:
	pshm	ar1
	stm	#0x00D0, ar1
	ld	#0x0DDD, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x0A5C, a
	or	#0x0451, a
	xor	#0x0297, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_14:
	pshm	ar1
	stm	#0x00E0, ar1
	ld	#0x0EEE, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x0B28, a
	or	#0x04A6, a
	xor	#0x02CA, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_15:
	pshm	ar1
	stm	#0x00F0, ar1
	ld	#0x0FFF, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x0BF4, a
	or	#0x04FB, a
	xor	#0x02FD, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_16:
	pshm	ar1
	stm	#0x0100, ar1
	ld	#0x1110, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x0CC0, a
	or	#0x0550, a
	xor	#0x0330, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_17:
	pshm	ar1
	stm	#0x0110, ar1
	ld	#0x1221, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x0D8C, a
	or	#0x05A5, a
	xor	#0x0363, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_18:
	pshm	ar1
	stm	#0x0120, ar1
	ld	#0x1332, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x0E58, a
	or	#0x05FA, a
	xor	#0x0396, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

_stress_19:
	pshm	ar1
	stm	#0x0130, ar1
	ld	#0x1443, a
	add	*ar2+, 0, a, b
	sub	*ar3+, 0, b, a
	add	*ar2+, 4, a, b
	sub	*ar3+, 4, b, a
	add	*ar2+, 8, a, b
	sub	*ar3+, 8, b, a
	add	*ar2+, 12, a, b
	sub	*ar3+, 12, b, a
	add	*ar2+, -4, a, b
	sub	*ar3+, -4, b, a
	add	*ar2+, -8, a, b
	sub	*ar3+, -8, b, a
	and	#0x0F24, a
	or	#0x064F, a
	xor	#0x03C9, a
	mac	*ar4+, *ar5+, a
	macr	*ar4+, *ar5+, b
	mas	*ar4+, *ar5+, a
	stl	a, *ar6+
	sth	a, *ar7+
	popm	ar1
	ret

; ====================================================================
; SECTION 14: realistic DSP pipeline — FIR + IIR + companding
; ====================================================================

; --- _pipeline_init -----------------------------------------------------
_pipeline_init:
	stm	#buf_a, ar2
	stm	#buf_b, ar3
	stm	#coef_table_a, ar4
	stm	#32, bk			; circular size
	stm	#0, ar0
	ret

; --- _pipeline_fir_block -----------------------------------------------------
; 32 outputs of a 16-tap FIR
_pipeline_fir_block:
	call	_pipeline_init
	stm	#31, brc
	rptbd	fir_outer_end-1
	nop
	nop
fir_outer_top:
	ld	*ar2+, a
	stl	a, *ar3+%
	rptz	a, #15
	mac	*ar3+0%, *ar4+0%, a
	sth	a, *ar5+
fir_outer_end:
	ret

; --- _pipeline_iir_block -----------------------------------------------------
_pipeline_iir_block:
	stm	#buf_a, ar2
	stm	#coef_table_b, ar3
	stm	#31, brc
	rptb	iir_end-1
	ld	*ar2, t
	mpy	*ar3, a
	mac	*ar3, b
	sat	a
	sth	a, *ar2+
iir_end:
	ret

; --- _pipeline_compander -----------------------------------------------------
; Mu-law-like 8-bit log compander
_pipeline_compander:
	stm	#buf_a, ar2
	stm	#buf_b, ar3
	stm	#fp_table_log, ar4
	stm	#63, brc
	rptb	cmp_end-1
	ld	*ar2+, a
	exp	a			; T = exponent of A
	norm	a
	sftl	a, -8
	and	#0xFF, a
	stl	a, *ar3+
cmp_end:
	ret

; ====================================================================
; SECTION 15: jump tables and computed addressing
; ====================================================================

; --- _jump_table -----------------------------------------------------
_jump_table:
	; dispatch table at jt_table; index in A
	sftl	a, 1			; index *= 2 (each entry is 2 words)
	add	#jt_table, a
	bacc	a
jt_table:
	b	jt_h0
	b	jt_h1
	b	jt_h2
	b	jt_h3
jt_h0:	ld	#0, a
	ret
jt_h1:	ld	#1, a
	ret
jt_h2:	ld	#2, a
	ret
jt_h3:	ld	#3, a
	ret

; ====================================================================
; SECTION 16: micro-functions (global symbol stress)
; ====================================================================

_micro_00:
	ld	#0x0000, a
	add	#0, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_01:
	ld	#0x0001, a
	add	#1, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_02:
	ld	#0x0002, a
	add	#2, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_03:
	ld	#0x0003, a
	add	#3, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_04:
	ld	#0x0004, a
	add	#4, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_05:
	ld	#0x0005, a
	add	#5, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_06:
	ld	#0x0006, a
	add	#6, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_07:
	ld	#0x0007, a
	add	#7, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_08:
	ld	#0x0008, a
	add	#8, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_09:
	ld	#0x0009, a
	add	#9, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_10:
	ld	#0x000A, a
	add	#10, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_11:
	ld	#0x000B, a
	add	#11, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_12:
	ld	#0x000C, a
	add	#12, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_13:
	ld	#0x000D, a
	add	#13, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_14:
	ld	#0x000E, a
	add	#14, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_15:
	ld	#0x000F, a
	add	#15, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_16:
	ld	#0x0010, a
	add	#16, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_17:
	ld	#0x0011, a
	add	#17, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_18:
	ld	#0x0012, a
	add	#18, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_19:
	ld	#0x0013, a
	add	#19, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_20:
	ld	#0x0014, a
	add	#20, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_21:
	ld	#0x0015, a
	add	#21, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_22:
	ld	#0x0016, a
	add	#22, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_23:
	ld	#0x0017, a
	add	#23, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_24:
	ld	#0x0018, a
	add	#24, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_25:
	ld	#0x0019, a
	add	#25, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_26:
	ld	#0x001A, a
	add	#26, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_27:
	ld	#0x001B, a
	add	#27, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_28:
	ld	#0x001C, a
	add	#28, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_29:
	ld	#0x001D, a
	add	#29, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_30:
	ld	#0x001E, a
	add	#30, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_31:
	ld	#0x001F, a
	add	#31, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_32:
	ld	#0x0020, a
	add	#32, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_33:
	ld	#0x0021, a
	add	#33, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_34:
	ld	#0x0022, a
	add	#34, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_35:
	ld	#0x0023, a
	add	#35, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_36:
	ld	#0x0024, a
	add	#36, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_37:
	ld	#0x0025, a
	add	#37, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_38:
	ld	#0x0026, a
	add	#38, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_39:
	ld	#0x0027, a
	add	#39, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

; ====================================================================
; SECTION 17: dense instruction stream — for raw byte-stream testing
; ====================================================================

; --- _dense_stream -----------------------------------------------------
; A long flat function. Tests linear disassembly.
_dense_stream:
	abs	a
	sub	*ar3+, b
	ld	*ar2+, a
	delay	*ar2
	mas	*ar3+, a
	mac	*ar2+, a
	mac	*ar2+, a
	and	*ar2+, a
	delay	*ar2
	sub	*ar3+, b
	neg	a
	delay	*ar2
	sftl	a, -1
	add	*ar2+, a
	rol	a
	ldr	*ar3+, b
	ld	*ar3+, b
	ld	*ar2+, a
	add	*ar2+, a
	xor	*ar2+, b
	mac	*ar2+, a
	sfta	a, 1
	ror	a
	ld	*ar2+, a
	sftl	a, -1
	xor	*ar2+, b
	nop
	abs	a
	nop
	sftl	a, -1
	ldr	*ar3+, b
	mac	*ar2+, a
	stl	a, *ar4+
	rol	a
	mas	*ar3+, a
	mar	*ar2+
	ld	*ar2+, a
	ltd	*ar3
	mar	*ar2+
	or	*ar3+, a
	nop
	ldr	*ar3+, b
	mpyr	*ar3+, b
	mas	*ar3+, a
	and	*ar2+, a
	xor	*ar2+, b
	ltd	*ar3
	mpyr	*ar3+, b
	sub	*ar3+, b
	add	*ar2+, a
	ldu	*ar2+, a
	sub	*ar3+, b
	mpyu	*ar2+, a
	mpyu	*ar2+, a
	ror	a
	mas	*ar3+, a
	mar	*ar2+
	ld	*ar3+, b
	delay	*ar2
	stl	a, *ar4+
	sftl	a, -1
	sub	*ar3+, b
	ldu	*ar2+, a
	add	*ar2+, a
	sftl	a, -1
	mpy	*ar2+, a
	mar	*ar3-
	abs	a
	ror	a
	mpyu	*ar2+, a
	rol	a
	xor	*ar2+, b
	nop
	add	*ar2+, a
	ld	*ar3+, b
	neg	a
	mac	*ar2+, a
	ltd	*ar3
	mpy	*ar2+, a
	add	*ar2+, a
	mac	*ar2+, a
	sub	*ar3+, b
	ldu	*ar2+, a
	mas	*ar3+, a
	stl	a, *ar4+
	abs	a
	mar	*ar3-
	mpyu	*ar2+, a
	or	*ar3+, a
	mpyu	*ar2+, a
	mpyu	*ar2+, a
	xor	*ar2+, b
	neg	a
	mas	*ar3+, a
	nop
	neg	a
	abs	a
	add	*ar2+, a
	ror	a
	abs	a
	or	*ar3+, a
	sftl	a, -1
	delay	*ar2
	mac	*ar2+, a
	or	*ar3+, a
	stl	a, *ar4+
	ldu	*ar2+, a
	mas	*ar3+, a
	abs	a
	nop
	sftl	a, -1
	mac	*ar2+, a
	neg	a
	mpyr	*ar3+, b
	mar	*ar3-
	ltd	*ar3
	ltd	*ar3
	ld	*ar3+, b
	mac	*ar2+, a
	mar	*ar3-
	ld	*ar3+, b
	mar	*ar2+
	mpyr	*ar3+, b
	ldu	*ar2+, a
	mas	*ar3+, a
	add	*ar2+, a
	xor	*ar2+, b
	rol	a
	nop
	mpyr	*ar3+, b
	xor	*ar2+, b
	abs	a
	sth	a, *ar5+
	ldu	*ar2+, a
	abs	a
	stl	a, *ar4+
	and	*ar2+, a
	mas	*ar3+, a
	and	*ar2+, a
	mac	*ar2+, a
	delay	*ar2
	sftl	a, -1
	sftl	a, -1
	mas	*ar3+, a
	delay	*ar2
	rol	a
	ldr	*ar3+, b
	rol	a
	ldu	*ar2+, a
	mpyu	*ar2+, a
	mac	*ar2+, a
	and	*ar2+, a
	sfta	a, 1
	sth	a, *ar5+
	add	*ar2+, a
	ltd	*ar3
	ld	*ar3+, b
	sub	*ar3+, b
	and	*ar2+, a
	abs	a
	or	*ar3+, a
	mar	*ar2+
	neg	a
	ldr	*ar3+, b
	ror	a
	add	*ar2+, a
	ldu	*ar2+, a
	ldu	*ar2+, a
	ror	a
	stl	a, *ar4+
	sfta	a, 1
	mas	*ar3+, a
	sftl	a, -1
	ld	*ar2+, a
	neg	a
	delay	*ar2
	sub	*ar3+, b
	neg	a
	sftl	a, -1
	ltd	*ar3
	mas	*ar3+, a
	ltd	*ar3
	abs	a
	mpyr	*ar3+, b
	sub	*ar3+, b
	mpy	*ar2+, a
	ldr	*ar3+, b
	or	*ar3+, a
	stl	a, *ar4+
	ld	*ar2+, a
	delay	*ar2
	delay	*ar2
	mas	*ar3+, a
	sfta	a, 1
	ltd	*ar3
	or	*ar3+, a
	sfta	a, 1
	sub	*ar3+, b
	abs	a
	mpy	*ar2+, a
	mar	*ar3-
	abs	a
	sfta	a, 1
	ror	a
	xor	*ar2+, b
	and	*ar2+, a
	mpyu	*ar2+, a
	ltd	*ar3
	or	*ar3+, a
	sftl	a, -1
	ltd	*ar3
	sfta	a, 1
	ld	*ar2+, a
	ror	a
	mpyr	*ar3+, b
	sth	a, *ar5+
	ld	*ar2+, a
	sub	*ar3+, b
	mpyu	*ar2+, a
	mar	*ar3-
	mar	*ar2+
	mpy	*ar2+, a
	mac	*ar2+, a
	ld	*ar3+, b
	mac	*ar2+, a
	rol	a
	add	*ar2+, a
	add	*ar2+, a
	delay	*ar2
	sth	a, *ar5+
	mar	*ar3-
	add	*ar2+, a
	ltd	*ar3
	sftl	a, -1
	ltd	*ar3
	and	*ar2+, a
	and	*ar2+, a
	neg	a
	sth	a, *ar5+
	sftl	a, -1
	or	*ar3+, a
	mas	*ar3+, a
	sfta	a, 1
	ror	a
	ldr	*ar3+, b
	xor	*ar2+, b
	sftl	a, -1
	ltd	*ar3
	delay	*ar2
	nop
	xor	*ar2+, b
	nop
	mpy	*ar2+, a
	ldu	*ar2+, a
	neg	a
	abs	a
	mpyu	*ar2+, a
	stl	a, *ar4+
	sfta	a, 1
	stl	a, *ar4+
	sub	*ar3+, b
	mac	*ar2+, a
	mac	*ar2+, a
	add	*ar2+, a
	mpyr	*ar3+, b
	ld	*ar2+, a
	rol	a
	sftl	a, -1
	mac	*ar2+, a
	rol	a
	mac	*ar2+, a
	ld	*ar2+, a
	add	*ar2+, a
	nop
	abs	a
	ld	*ar3+, b
	mac	*ar2+, a
	add	*ar2+, a
	ld	*ar3+, b
	mpyr	*ar3+, b
	add	*ar2+, a
	sfta	a, 1
	mac	*ar2+, a
	mas	*ar3+, a
	neg	a
	sth	a, *ar5+
	xor	*ar2+, b
	sftl	a, -1
	and	*ar2+, a
	delay	*ar2
	rol	a
	rol	a
	sth	a, *ar5+
	mac	*ar2+, a
	mar	*ar2+
	sth	a, *ar5+
	mar	*ar2+
	ldr	*ar3+, b
	xor	*ar2+, b
	sub	*ar3+, b
	sub	*ar3+, b
	neg	a
	ldr	*ar3+, b
	mpyu	*ar2+, a
	ldr	*ar3+, b
	ldr	*ar3+, b
	stl	a, *ar4+
	delay	*ar2
	ld	*ar3+, b
	neg	a
	abs	a
	abs	a
	sub	*ar3+, b
	ld	*ar3+, b
	ldu	*ar2+, a
	delay	*ar2
	mpyr	*ar3+, b
	mar	*ar2+
	sub	*ar3+, b
	mac	*ar2+, a
	xor	*ar2+, b
	xor	*ar2+, b
	sftl	a, -1
	stl	a, *ar4+
	and	*ar2+, a
	ldr	*ar3+, b
	or	*ar3+, a
	mas	*ar3+, a
	stl	a, *ar4+
	mac	*ar2+, a
	add	*ar2+, a
	stl	a, *ar4+
	mar	*ar2+
	sftl	a, -1
	sub	*ar3+, b
	ld	*ar3+, b
	abs	a
	sftl	a, -1
	mar	*ar3-
	ld	*ar2+, a
	add	*ar2+, a
	ltd	*ar3
	mac	*ar2+, a
	or	*ar3+, a
	ldr	*ar3+, b
	sth	a, *ar5+
	sth	a, *ar5+
	xor	*ar2+, b
	ldu	*ar2+, a
	ld	*ar3+, b
	or	*ar3+, a
	ldu	*ar2+, a
	ld	*ar2+, a
	ldu	*ar2+, a
	mas	*ar3+, a
	mar	*ar2+
	mar	*ar2+
	stl	a, *ar4+
	mpy	*ar2+, a
	ldr	*ar3+, b
	nop
	delay	*ar2
	mar	*ar2+
	sftl	a, -1
	neg	a
	nop
	sth	a, *ar5+
	and	*ar2+, a
	xor	*ar2+, b
	mpy	*ar2+, a
	xor	*ar2+, b
	ld	*ar3+, b
	rol	a
	delay	*ar2
	sftl	a, -1
	ld	*ar3+, b
	delay	*ar2
	mpyr	*ar3+, b
	ld	*ar3+, b
	ld	*ar3+, b
	rol	a
	sth	a, *ar5+
	sfta	a, 1
	sfta	a, 1
	or	*ar3+, a
	ld	*ar3+, b
	sfta	a, 1
	add	*ar2+, a
	or	*ar3+, a
	add	*ar2+, a
	ror	a
	add	*ar2+, a
	neg	a
	mac	*ar2+, a
	ldu	*ar2+, a
	sub	*ar3+, b
	rol	a
	mac	*ar2+, a
	rol	a
	ror	a
	ret


; ====================================================================
; SECTION 18: more dense streams — various sub-streams
; ====================================================================

_cond_aeq:
	pshm	ar1
	ld	#0, a
	cmpm	@tmp_w, #0
	bc	cond_aeq_end, AEQ
	add	#1, a
	and	#0xFF, b
	or	#0x0000, a
	xor	#0x0000, b
cond_aeq_end:
	popm	ar1
	ret

_cond_aneq:
	pshm	ar1
	ld	#1, a
	cmpm	@tmp_w, #256
	bc	cond_aneq_end, ANEQ
	add	#1, a
	and	#0xFF, b
	or	#0x0011, a
	xor	#0x0033, b
cond_aneq_end:
	popm	ar1
	ret

_cond_agt:
	pshm	ar1
	ld	#2, a
	cmpm	@tmp_w, #512
	bc	cond_agt_end, AGT
	add	#1, a
	and	#0xFF, b
	or	#0x0022, a
	xor	#0x0066, b
cond_agt_end:
	popm	ar1
	ret

_cond_ageq:
	pshm	ar1
	ld	#3, a
	cmpm	@tmp_w, #768
	bc	cond_ageq_end, AGEQ
	add	#1, a
	and	#0xFF, b
	or	#0x0033, a
	xor	#0x0099, b
cond_ageq_end:
	popm	ar1
	ret

_cond_alt:
	pshm	ar1
	ld	#4, a
	cmpm	@tmp_w, #1024
	bc	cond_alt_end, ALT
	add	#1, a
	and	#0xFF, b
	or	#0x0044, a
	xor	#0x00CC, b
cond_alt_end:
	popm	ar1
	ret

_cond_aleq:
	pshm	ar1
	ld	#5, a
	cmpm	@tmp_w, #1280
	bc	cond_aleq_end, ALEQ
	add	#1, a
	and	#0xFF, b
	or	#0x0055, a
	xor	#0x00FF, b
cond_aleq_end:
	popm	ar1
	ret

_cond_aov:
	pshm	ar1
	ld	#6, a
	cmpm	@tmp_w, #1536
	bc	cond_aov_end, AOV
	add	#1, a
	and	#0xFF, b
	or	#0x0066, a
	xor	#0x0132, b
cond_aov_end:
	popm	ar1
	ret

_cond_anov:
	pshm	ar1
	ld	#7, a
	cmpm	@tmp_w, #1792
	bc	cond_anov_end, ANOV
	add	#1, a
	and	#0xFF, b
	or	#0x0077, a
	xor	#0x0165, b
cond_anov_end:
	popm	ar1
	ret

_cond_beq:
	pshm	ar1
	ld	#8, a
	cmpm	@tmp_w, #2048
	bc	cond_beq_end, BEQ
	add	#1, a
	and	#0xFF, b
	or	#0x0088, a
	xor	#0x0198, b
cond_beq_end:
	popm	ar1
	ret

_cond_bneq:
	pshm	ar1
	ld	#9, a
	cmpm	@tmp_w, #2304
	bc	cond_bneq_end, BNEQ
	add	#1, a
	and	#0xFF, b
	or	#0x0099, a
	xor	#0x01CB, b
cond_bneq_end:
	popm	ar1
	ret

_cond_bgt:
	pshm	ar1
	ld	#10, a
	cmpm	@tmp_w, #2560
	bc	cond_bgt_end, BGT
	add	#1, a
	and	#0xFF, b
	or	#0x00AA, a
	xor	#0x01FE, b
cond_bgt_end:
	popm	ar1
	ret

_cond_bgeq:
	pshm	ar1
	ld	#11, a
	cmpm	@tmp_w, #2816
	bc	cond_bgeq_end, BGEQ
	add	#1, a
	and	#0xFF, b
	or	#0x00BB, a
	xor	#0x0231, b
cond_bgeq_end:
	popm	ar1
	ret

_cond_blt:
	pshm	ar1
	ld	#12, a
	cmpm	@tmp_w, #3072
	bc	cond_blt_end, BLT
	add	#1, a
	and	#0xFF, b
	or	#0x00CC, a
	xor	#0x0264, b
cond_blt_end:
	popm	ar1
	ret

_cond_bleq:
	pshm	ar1
	ld	#13, a
	cmpm	@tmp_w, #3328
	bc	cond_bleq_end, BLEQ
	add	#1, a
	and	#0xFF, b
	or	#0x00DD, a
	xor	#0x0297, b
cond_bleq_end:
	popm	ar1
	ret

_cond_bov:
	pshm	ar1
	ld	#14, a
	cmpm	@tmp_w, #3584
	bc	cond_bov_end, BOV
	add	#1, a
	and	#0xFF, b
	or	#0x00EE, a
	xor	#0x02CA, b
cond_bov_end:
	popm	ar1
	ret

_cond_bnov:
	pshm	ar1
	ld	#15, a
	cmpm	@tmp_w, #3840
	bc	cond_bnov_end, BNOV
	add	#1, a
	and	#0xFF, b
	or	#0x00FF, a
	xor	#0x02FD, b
cond_bnov_end:
	popm	ar1
	ret

_cond_tc:
	pshm	ar1
	ld	#16, a
	cmpm	@tmp_w, #4096
	bc	cond_tc_end, TC
	add	#1, a
	and	#0xFF, b
	or	#0x0110, a
	xor	#0x0330, b
cond_tc_end:
	popm	ar1
	ret

_cond_ntc:
	pshm	ar1
	ld	#17, a
	cmpm	@tmp_w, #4352
	bc	cond_ntc_end, NTC
	add	#1, a
	and	#0xFF, b
	or	#0x0121, a
	xor	#0x0363, b
cond_ntc_end:
	popm	ar1
	ret

_cond_c:
	pshm	ar1
	ld	#18, a
	cmpm	@tmp_w, #4608
	bc	cond_c_end, C
	add	#1, a
	and	#0xFF, b
	or	#0x0132, a
	xor	#0x0396, b
cond_c_end:
	popm	ar1
	ret

_cond_nc:
	pshm	ar1
	ld	#19, a
	cmpm	@tmp_w, #4864
	bc	cond_nc_end, NC
	add	#1, a
	and	#0xFF, b
	or	#0x0143, a
	xor	#0x03C9, b
cond_nc_end:
	popm	ar1
	ret

; ====================================================================
; SECTION 19: addressing-mode coverage matrix
; ====================================================================

; addressing mode: *ar2 (indirect)
_addrmode_00:
	ld	*ar2, a
	add	*ar2, a
	sub	*ar2, b
	and	*ar2, a
	or	*ar2, b
	xor	*ar2, a
	mpy	*ar2, a
	mac	*ar2, b
	mas	*ar2, a
	mpyr	*ar2, a
	mpyu	*ar2, b
	ret

; addressing mode: *ar2+ (indirect post-inc)
_addrmode_01:
	ld	*ar2+, a
	add	*ar2+, a
	sub	*ar2+, b
	and	*ar2+, a
	or	*ar2+, b
	xor	*ar2+, a
	mpy	*ar2+, a
	mac	*ar2+, b
	mas	*ar2+, a
	mpyr	*ar2+, a
	mpyu	*ar2+, b
	ret

; addressing mode: *ar2- (indirect post-dec)
_addrmode_02:
	ld	*ar2-, a
	add	*ar2-, a
	sub	*ar2-, b
	and	*ar2-, a
	or	*ar2-, b
	xor	*ar2-, a
	mpy	*ar2-, a
	mac	*ar2-, b
	mas	*ar2-, a
	mpyr	*ar2-, a
	mpyu	*ar2-, b
	ret

; addressing mode: *+ar2(1) (indirect with offset)
_addrmode_03:
	ld	*+ar2(1), a
	add	*+ar2(1), a
	sub	*+ar2(1), b
	and	*+ar2(1), a
	or	*+ar2(1), b
	xor	*+ar2(1), a
	mpy	*+ar2(1), a
	mac	*+ar2(1), b
	mas	*+ar2(1), a
	mpyr	*+ar2(1), a
	mpyu	*+ar2(1), b
	ret

; addressing mode: *ar2(5) (indirect with const offset)
_addrmode_04:
	ld	*ar2(5), a
	add	*ar2(5), a
	sub	*ar2(5), b
	and	*ar2(5), a
	or	*ar2(5), b
	xor	*ar2(5), a
	mpy	*ar2(5), a
	mac	*ar2(5), b
	mas	*ar2(5), a
	mpyr	*ar2(5), a
	mpyu	*ar2(5), b
	ret

; addressing mode: *ar2+0 (indirect post-add-AR0)
_addrmode_05:
	ld	*ar2+0, a
	add	*ar2+0, a
	sub	*ar2+0, b
	and	*ar2+0, a
	or	*ar2+0, b
	xor	*ar2+0, a
	mpy	*ar2+0, a
	mac	*ar2+0, b
	mas	*ar2+0, a
	mpyr	*ar2+0, a
	mpyu	*ar2+0, b
	ret

; addressing mode: *ar2-0 (indirect post-sub-AR0)
_addrmode_06:
	ld	*ar2-0, a
	add	*ar2-0, a
	sub	*ar2-0, b
	and	*ar2-0, a
	or	*ar2-0, b
	xor	*ar2-0, a
	mpy	*ar2-0, a
	mac	*ar2-0, b
	mas	*ar2-0, a
	mpyr	*ar2-0, a
	mpyu	*ar2-0, b
	ret

; addressing mode: *ar2+0% (circular post-add)
_addrmode_07:
	ld	*ar2+0%, a
	add	*ar2+0%, a
	sub	*ar2+0%, b
	and	*ar2+0%, a
	or	*ar2+0%, b
	xor	*ar2+0%, a
	mpy	*ar2+0%, a
	mac	*ar2+0%, b
	mas	*ar2+0%, a
	mpyr	*ar2+0%, a
	mpyu	*ar2+0%, b
	ret

; addressing mode: *ar2-0% (circular post-sub)
_addrmode_08:
	ld	*ar2-0%, a
	add	*ar2-0%, a
	sub	*ar2-0%, b
	and	*ar2-0%, a
	or	*ar2-0%, b
	xor	*ar2-0%, a
	mpy	*ar2-0%, a
	mac	*ar2-0%, b
	mas	*ar2-0%, a
	mpyr	*ar2-0%, a
	mpyu	*ar2-0%, b
	ret

; addressing mode: *ar2+% (circular post-inc)
_addrmode_09:
	ld	*ar2+%, a
	add	*ar2+%, a
	sub	*ar2+%, b
	and	*ar2+%, a
	or	*ar2+%, b
	xor	*ar2+%, a
	mpy	*ar2+%, a
	mac	*ar2+%, b
	mas	*ar2+%, a
	mpyr	*ar2+%, a
	mpyu	*ar2+%, b
	ret

; addressing mode: @tmp_w (DP-relative direct)
_addrmode_10:
	ld	@tmp_w, a
	add	@tmp_w, a
	sub	@tmp_w, b
	and	@tmp_w, a
	or	@tmp_w, b
	xor	@tmp_w, a
	mpy	@tmp_w, a
	mac	@tmp_w, b
	mas	@tmp_w, a
	mpyr	@tmp_w, a
	mpyu	@tmp_w, b
	ret

; ====================================================================
; SECTION 20: massive dense block — for raw byte-stream stress
; ====================================================================

_dense_huge:
	and	#0xF0F0, a
	xor	#0xAAAA, a
	rol	a
	sub	b, a
	exp	b
	and	*ar2+, a
	macr	*ar3+, *ar4+, a
	exp	a
	mpy	*ar2+, a
	squra	*ar2+, a
	ldr	*ar2+, a
	ld	*ar4+, a
	squrs	*ar2+, a
	sub	*ar2+, a
	masr	*ar2+, *ar4+, a
	add	#0x10, a
	squra	*ar2+, a
	sftl	a, -8
	sub	#0x20, a
	exp	b
	stl	b, *ar7+
	neg	a
	ldu	*ar2+, b
	mar	*ar4+0%
	squr	*ar2+, a
	sub	*ar3+, b
	xor	#0xAAAA, a
	sftl	a, -4
	exp	b
	ldu	*ar2+, b
	delay	*ar2
	exp	a
	mpyu	*ar2+, a
	nop
	norm	a
	ldu	*ar2+, b
	ror	b
	sth	b, *ar7+
	ltd	*ar3
	masr	*ar2+, *ar4+, a
	ldr	*ar2+, a
	sub	*ar2+, a
	macr	*ar3+, *ar4+, a
	mpyu	*ar2+, a
	sftl	a, 8
	rol	b
	squr	*ar2+, a
	mac	*ar2+, *ar3+, b
	or	#0xFF00, b
	norm	a
	xor	#0xAAAA, a
	ld	#0x100, a
	ldr	*ar2+, a
	ldu	*ar2+, b
	neg	b
	ltd	*ar3
	exp	b
	norm	a
	mpy	*ar3+, *ar4+, a
	or	#0xFF00, b
	masr	*ar2+, *ar4+, a
	sfta	b, -1
	xor	#0x5555, b
	and	#0x00FF, b
	ldr	*ar2+, a
	masr	*ar2+, *ar4+, a
	ldr	*ar2+, a
	macr	*ar3+, *ar4+, a
	mas	*ar2+, a
	ldr	*ar2+, a
	and	#0x00FF, b
	macr	*ar3+, *ar4+, a
	add	#0x10, a
	squrs	*ar2+, a
	abs	b
	add	*ar3+, b
	neg	a
	exp	a
	nop
	exp	a
	rol	a
	stl	a, *ar6+
	sftl	a, -8
	sub	a, b
	xor	*ar2+, a
	mpyu	*ar2+, a
	mpyu	*ar2+, a
	sth	a, *ar5+
	neg	a
	exp	a
	macr	*ar3+, *ar4+, a
	mar	*ar4+0%
	ldu	*ar2+, b
	sftl	b, -1
	mar	*ar3-
	ldu	*ar2+, b
	macr	*ar2+, a
	mar	*ar3-
	mas	*ar2+, a
	nop
	nop
	neg	b
	stl	a, *ar6+
	exp	a
	mpyr	*ar2+, a
	and	#0xF0F0, a
	ldr	*ar2+, a
	mpyr	*ar2+, a
	nop
	ror	a
	sftl	b, 1
	neg	a
	ldr	*ar2+, a
	ldr	*ar2+, a
	mac	*ar3+, *ar4+, a
	neg	a
	squrs	*ar2+, a
	squrs	*ar2+, a
	sfta	b, -1
	delay	*ar2
	exp	a
	mpyr	*ar2+, a
	add	b, a
	mar	*ar4+0%
	macr	*ar3+, *ar4+, a
	sub	b, a
	masr	*ar2+, *ar4+, a
	nop
	sub	b, a
	ror	a
	neg	b
	sth	b, *ar7+
	or	#0x0F0F, a
	ror	a
	squr	*ar2+, a
	squra	*ar2+, a
	ld	*ar5+, b
	mpy	*ar2+, a
	sub	#0x20, a
	mpy	*ar2+, a
	abs	b
	delay	*ar2
	ror	a
	mac	*ar3+, *ar4+, a
	rol	a
	or	#0xFF00, b
	ldu	*ar2+, b
	squrs	*ar2+, a
	and	#0x00FF, b
	squra	*ar2+, a
	norm	a
	mar	*ar2+
	mpyu	*ar2+, a
	sfta	a, 4
	sfta	a, -4
	or	#0x0F0F, a
	add	*ar2+, a
	squr	*ar2+, a
	add	*ar2+, a
	sfta	b, -1
	squra	*ar2+, a
	mpyr	*ar2+, a
	mas	*ar3+, *ar4+, a
	neg	a
	add	#0x10, a
	masr	*ar2+, *ar4+, a
	sth	a, *ar6+
	sth	b, *ar7+
	squra	*ar2+, a
	mpyu	*ar2+, a
	or	#0x0F0F, a
	sub	#0x20, a
	macr	*ar3+, *ar4+, a
	mac	*ar2+, a
	mas	*ar3+, *ar4+, a
	norm	a
	squrs	*ar2+, a
	ror	b
	stl	a, *ar6+
	and	*ar2+, a
	mac	*ar2+, *ar3+, b
	neg	a
	stl	a, *ar6+
	mpyr	*ar2+, a
	macr	*ar3+, *ar4+, a
	macr	*ar2+, a
	mpy	*ar2+, a
	exp	a
	mac	*ar2+, a
	sth	a, *ar6+
	squra	*ar2+, a
	ldu	*ar2+, b
	and	*ar2+, a
	mas	*ar3+, *ar4+, a
	xor	*ar2+, a
	sub	#0x20, a
	squrs	*ar2+, a
	sfta	a, -4
	squra	*ar2+, a
	masr	*ar2+, *ar4+, a
	ld	*ar4+, a
	neg	b
	norm	a
	and	*ar2+, a
	or	*ar2+, a
	sfta	a, 8
	sfta	a, -4
	ld	#0x100, a
	sftl	a, -8
	nop
	macr	*ar3+, *ar4+, a
	sub	a, b
	ror	b
	neg	a
	norm	a
	ror	a
	ldr	*ar2+, a
	neg	b
	mac	*ar2+, *ar3+, b
	mpyu	*ar2+, a
	or	*ar2+, a
	stl	b, *ar7+
	norm	b
	ltd	*ar3
	mpy	*ar3+, *ar4+, a
	add	#0x10, a
	add	*ar3+, b
	mpyu	*ar2+, a
	mpyr	*ar2+, a
	macr	*ar2+, a
	rol	a
	or	#0x0F0F, a
	and	#0xF0F0, a
	nop
	sftl	a, -8
	xor	#0x5555, b
	sftl	b, 1
	mas	*ar2+, a
	exp	b
	abs	b
	sfta	a, 4
	xor	*ar2+, a
	mac	*ar3+, *ar4+, a
	ldr	*ar2+, a
	mpyr	*ar2+, a
	ldr	*ar2+, a
	squr	*ar2+, a
	sfta	a, 4
	squr	*ar2+, a
	xor	*ar2+, a
	rol	b
	mpy	*ar3+, *ar4+, a
	abs	a
	add	*ar2+, a
	ldu	*ar2+, b
	and	#0x00FF, b
	mpyu	*ar2+, a
	abs	b
	add	*ar3+, b
	abs	b
	mpyu	*ar2+, a
	stl	a, *ar6+
	sub	b, a
	or	*ar2+, a
	mpy	*ar2+, a
	sth	a, *ar5+
	squrs	*ar2+, a
	ldu	*ar2+, b
	nop
	stl	a, *ar5+
	squrs	*ar2+, a
	abs	a
	stl	b, *ar7+
	sub	*ar3+, b
	mac	*ar2+, *ar3+, b
	and	#0xF0F0, a
	ltd	*ar3
	exp	a
	ldu	*ar2+, b
	mac	*ar2+, a
	sub	*ar3+, b
	masr	*ar2+, *ar4+, a
	abs	b
	squr	*ar2+, a
	ror	b
	mpyr	*ar2+, a
	ld	#0x100, a
	masr	*ar2+, *ar4+, a
	delay	*ar2
	ltd	*ar3
	nop
	delay	*ar2
	ror	b
	mpyu	*ar2+, a
	sub	#0x20, a
	and	#0x00FF, b
	mac	*ar3+, *ar4+, a
	nop
	mpyr	*ar2+, a
	or	*ar2+, a
	ldr	*ar2+, a
	mac	*ar3+, *ar4+, a
	sth	b, *ar7+
	mar	*ar3-
	neg	b
	rol	b
	ltd	*ar3
	sfta	a, 4
	and	#0x00FF, b
	masr	*ar2+, *ar4+, a
	sub	*ar3+, b
	masr	*ar2+, *ar4+, a
	ldu	*ar2+, b
	sfta	b, 1
	mpyr	*ar2+, a
	ld	*ar5+, b
	masr	*ar2+, *ar4+, a
	norm	b
	sth	a, *ar5+
	squra	*ar2+, a
	ldu	*ar2+, b
	and	#0x00FF, b
	squra	*ar2+, a
	xor	#0xAAAA, a
	squrs	*ar2+, a
	ld	*ar2+, a
	sub	#0x20, a
	nop
	sfta	b, -1
	ltd	*ar3
	sth	a, *ar5+
	mpyr	*ar2+, a
	squrs	*ar2+, a
	ltd	*ar3
	ld	*ar4+, a
	macr	*ar3+, *ar4+, a
	norm	b
	or	#0x0F0F, a
	stl	a, *ar5+
	mas	*ar2+, a
	ld	#0x100, a
	mar	*ar4+0%
	squr	*ar2+, a
	mar	*ar2+
	mpyu	*ar2+, a
	norm	a
	exp	b
	mar	*ar2+
	ldu	*ar2+, b
	norm	b
	mac	*ar2+, a
	sftl	a, 4
	mas	*ar3+, *ar4+, a
	mpyr	*ar2+, a
	xor	*ar2+, a
	squra	*ar2+, a
	squra	*ar2+, a
	sub	b, a
	and	*ar2+, a
	abs	b
	ldr	*ar2+, a
	nop
	or	#0x0F0F, a
	mpyr	*ar2+, a
	add	b, a
	ldu	*ar2+, b
	sub	*ar3+, b
	ror	b
	ror	a
	neg	b
	nop
	sub	a, b
	ltd	*ar3
	stl	a, *ar6+
	sfta	b, -1
	ltd	*ar3
	abs	a
	mpyu	*ar2+, a
	ltd	*ar3
	ltd	*ar3
	delay	*ar2
	squra	*ar2+, a
	xor	#0x5555, b
	ldu	*ar2+, b
	mac	*ar2+, *ar3+, b
	neg	b
	macr	*ar2+, a
	and	*ar2+, a
	squr	*ar2+, a
	rol	a
	ror	a
	sfta	b, -1
	squr	*ar2+, a
	ldr	*ar2+, a
	nop
	macr	*ar2+, a
	norm	a
	macr	*ar3+, *ar4+, a
	squr	*ar2+, a
	mpy	*ar3+, *ar4+, a
	rol	a
	mpyu	*ar2+, a
	mpyu	*ar2+, a
	abs	a
	squrs	*ar2+, a
	mpyr	*ar2+, a
	exp	a
	neg	a
	mac	*ar2+, a
	sub	#0x20, a
	stl	a, *ar5+
	mpyr	*ar2+, a
	squra	*ar2+, a
	mac	*ar2+, *ar3+, b
	and	#0x00FF, b
	sfta	b, -1
	mac	*ar3+, *ar4+, a
	masr	*ar2+, *ar4+, a
	abs	a
	squrs	*ar2+, a
	nop
	add	a, b
	mar	*ar3-
	squra	*ar2+, a
	mpy	*ar2+, a
	mpyu	*ar2+, a
	abs	b
	masr	*ar2+, *ar4+, a
	mpy	*ar2+, a
	sth	a, *ar6+
	mas	*ar2+, a
	abs	a
	add	b, a
	ldu	*ar2+, b
	sth	b, *ar7+
	squra	*ar2+, a
	rol	b
	abs	b
	sfta	a, -4
	stl	a, *ar5+
	ld	#0xFF00, b
	xor	#0xAAAA, a
	abs	b
	or	*ar2+, a
	delay	*ar2
	or	#0x0F0F, a
	abs	a
	squrs	*ar2+, a
	masr	*ar2+, *ar4+, a
	exp	a
	squrs	*ar2+, a
	abs	a
	mar	*ar3-
	norm	b
	mas	*ar2+, a
	norm	b
	rol	a
	mac	*ar2+, a
	norm	b
	squrs	*ar2+, a
	ldr	*ar2+, a
	mpyr	*ar2+, a
	mpyr	*ar2+, a
	stl	b, *ar7+
	squrs	*ar2+, a
	sfta	b, -1
	squra	*ar2+, a
	ldr	*ar2+, a
	sftl	b, 1
	nop
	squra	*ar2+, a
	sth	a, *ar6+
	sth	b, *ar7+
	sth	a, *ar5+
	norm	b
	neg	a
	delay	*ar2
	delay	*ar2
	sfta	a, 4
	sftl	a, -4
	rol	a
	mar	*ar2+
	mpy	*ar2+, a
	macr	*ar2+, a
	rol	b
	ltd	*ar3
	ldr	*ar2+, a
	sftl	b, -1
	neg	a
	or	*ar2+, a
	squrs	*ar2+, a
	xor	#0xAAAA, a
	mpy	*ar3+, *ar4+, a
	rol	b
	ltd	*ar3
	and	*ar2+, a
	masr	*ar2+, *ar4+, a
	squra	*ar2+, a
	mac	*ar2+, *ar3+, b
	mar	*ar2+
	nop
	mpyu	*ar2+, a
	add	*ar2+, a
	or	#0xFF00, b
	ltd	*ar3
	ror	a
	neg	b
	mpyu	*ar2+, a
	mpyu	*ar2+, a
	mpyu	*ar2+, a
	rol	b
	ror	a
	ldu	*ar2+, b
	macr	*ar2+, a
	masr	*ar2+, *ar4+, a
	nop
	nop
	squrs	*ar2+, a
	add	#0x10, a
	sub	a, b
	ldu	*ar2+, b
	mac	*ar2+, a
	mpyu	*ar2+, a
	squr	*ar2+, a
	squrs	*ar2+, a
	mpyu	*ar2+, a
	ror	b
	sftl	b, -1
	mar	*ar3-
	nop
	delay	*ar2
	or	#0xFF00, b
	macr	*ar2+, a
	squra	*ar2+, a
	nop
	mar	*ar4+0%
	stl	a, *ar5+
	exp	a
	stl	b, *ar7+
	sth	a, *ar5+
	macr	*ar3+, *ar4+, a
	sfta	a, -8
	macr	*ar3+, *ar4+, a
	ldr	*ar2+, a
	ld	*ar2+, a
	sth	b, *ar7+
	mpy	*ar2+, a
	and	#0xF0F0, a
	exp	b
	stl	b, *ar7+
	ldu	*ar2+, b
	or	#0xFF00, b
	abs	b
	mpyr	*ar2+, a
	mpyr	*ar2+, a
	sth	a, *ar6+
	sub	*ar3+, b
	squra	*ar2+, a
	delay	*ar2
	add	b, a
	add	a, b
	and	#0xF0F0, a
	or	*ar2+, a
	mac	*ar2+, a
	exp	a
	sftl	a, -4
	mpyu	*ar2+, a
	squrs	*ar2+, a
	sub	*ar2+, a
	stl	a, *ar6+
	exp	a
	mpy	*ar3+, *ar4+, a
	ltd	*ar3
	mas	*ar3+, *ar4+, a
	mac	*ar3+, *ar4+, a
	or	#0xFF00, b
	norm	a
	masr	*ar2+, *ar4+, a
	sth	b, *ar7+
	macr	*ar2+, a
	sth	a, *ar5+
	mpy	*ar2+, a
	rol	b
	mac	*ar2+, a
	sfta	a, 4
	sftl	a, 8
	nop
	sfta	b, 1
	abs	a
	or	#0xFF00, b
	rol	a
	ldu	*ar2+, b
	nop
	delay	*ar2
	squra	*ar2+, a
	sub	*ar2+, a
	and	*ar2+, a
	mac	*ar3+, *ar4+, a
	ldu	*ar2+, b
	ld	#0x100, a
	stl	a, *ar6+
	masr	*ar2+, *ar4+, a
	mpy	*ar3+, *ar4+, a
	sftl	a, 4
	squrs	*ar2+, a
	xor	#0xAAAA, a
	or	#0x0F0F, a
	squr	*ar2+, a
	exp	a
	macr	*ar3+, *ar4+, a
	macr	*ar3+, *ar4+, a
	neg	b
	ror	a
	mpyu	*ar2+, a
	delay	*ar2
	or	*ar2+, a
	ltd	*ar3
	squrs	*ar2+, a
	sfta	b, -1
	ldr	*ar2+, a
	neg	b
	add	a, b
	mac	*ar3+, *ar4+, a
	macr	*ar2+, a
	ltd	*ar3
	macr	*ar3+, *ar4+, a
	mas	*ar3+, *ar4+, a
	macr	*ar2+, a
	xor	*ar2+, a
	ror	b
	macr	*ar3+, *ar4+, a
	squra	*ar2+, a
	xor	*ar2+, a
	and	#0x00FF, b
	ldu	*ar2+, b
	squra	*ar2+, a
	sftl	a, -4
	ror	b
	stl	a, *ar6+
	or	*ar2+, a
	stl	b, *ar7+
	mpy	*ar3+, *ar4+, a
	macr	*ar3+, *ar4+, a
	mpyr	*ar2+, a
	xor	#0xAAAA, a
	norm	a
	squr	*ar2+, a
	mpy	*ar2+, a
	ror	a
	sth	a, *ar6+
	squra	*ar2+, a
	ror	b
	abs	a
	sfta	a, -8
	sth	a, *ar5+
	sub	#0x20, a
	ror	a
	squra	*ar2+, a
	mpyu	*ar2+, a
	mpy	*ar2+, a
	masr	*ar2+, *ar4+, a
	masr	*ar2+, *ar4+, a
	ld	*ar2+, a
	xor	*ar2+, a
	delay	*ar2
	norm	a
	squr	*ar2+, a
	mac	*ar2+, a
	sftl	a, -4
	ldr	*ar2+, a
	add	a, b
	mpyr	*ar2+, a
	mpyu	*ar2+, a
	mpyr	*ar2+, a
	add	b, a
	macr	*ar3+, *ar4+, a
	mar	*ar4+0%
	delay	*ar2
	masr	*ar2+, *ar4+, a
	sth	b, *ar7+
	ltd	*ar3
	or	*ar2+, a
	nop
	stl	a, *ar6+
	mar	*ar4+0%
	squr	*ar2+, a
	ltd	*ar3
	sth	a, *ar5+
	ldr	*ar2+, a
	ldr	*ar2+, a
	mac	*ar2+, *ar3+, b
	mpyu	*ar2+, a
	sub	*ar3+, b
	mpyu	*ar2+, a
	sftl	a, -8
	ror	a
	mac	*ar2+, a
	abs	b
	squra	*ar2+, a
	ld	*ar4+, a
	ldu	*ar2+, b
	norm	b
	delay	*ar2
	ldr	*ar2+, a
	mpyr	*ar2+, a
	squra	*ar2+, a
	nop
	and	#0x00FF, b
	ld	*ar5+, b
	mpyr	*ar2+, a
	sth	a, *ar6+
	nop
	mpy	*ar3+, *ar4+, a
	mpy	*ar3+, *ar4+, a
	sub	#0x20, a
	ror	b
	ldr	*ar2+, a
	or	#0xFF00, b
	and	#0xF0F0, a
	xor	#0xAAAA, a
	or	#0xFF00, b
	stl	a, *ar5+
	delay	*ar2
	macr	*ar3+, *ar4+, a
	sftl	a, 8
	squr	*ar2+, a
	mpyr	*ar2+, a
	stl	b, *ar7+
	delay	*ar2
	sfta	a, 4
	mpy	*ar3+, *ar4+, a
	squr	*ar2+, a
	and	#0xF0F0, a
	ror	a
	mpyu	*ar2+, a
	macr	*ar3+, *ar4+, a
	norm	b
	neg	b
	sub	*ar2+, a
	mpyr	*ar2+, a
	sftl	a, -4
	exp	a
	ltd	*ar3
	sth	a, *ar6+
	mar	*ar4+0%
	norm	b
	norm	b
	mar	*ar2+
	mac	*ar3+, *ar4+, a
	macr	*ar3+, *ar4+, a
	mar	*ar2+
	rol	b
	mas	*ar2+, a
	mpyr	*ar2+, a
	norm	a
	nop
	stl	a, *ar6+
	or	#0x0F0F, a
	mas	*ar3+, *ar4+, a
	and	#0x00FF, b
	squrs	*ar2+, a
	sfta	a, 4
	stl	b, *ar7+
	mpy	*ar2+, a
	sub	*ar2+, a
	mpy	*ar2+, a
	sfta	a, 8
	sub	a, b
	sfta	a, -8
	ldr	*ar2+, a
	mpyr	*ar2+, a
	and	*ar2+, a
	squra	*ar2+, a
	mas	*ar3+, *ar4+, a
	or	#0xFF00, b
	or	*ar2+, a
	xor	#0xAAAA, a
	masr	*ar2+, *ar4+, a
	squr	*ar2+, a
	and	*ar2+, a
	sth	a, *ar5+
	mpy	*ar2+, a
	ldr	*ar2+, a
	stl	b, *ar7+
	xor	#0xAAAA, a
	and	#0xF0F0, a
	delay	*ar2
	ltd	*ar3
	xor	*ar2+, a
	squr	*ar2+, a
	sfta	a, 4
	squra	*ar2+, a
	mpyu	*ar2+, a
	neg	b
	macr	*ar3+, *ar4+, a
	mac	*ar2+, *ar3+, b
	and	#0xF0F0, a
	xor	#0xAAAA, a
	rol	b
	neg	b
	or	#0xFF00, b
	exp	a
	mpyr	*ar2+, a
	squr	*ar2+, a
	squrs	*ar2+, a
	abs	b
	ltd	*ar3
	ltd	*ar3
	ldr	*ar2+, a
	rol	b
	sfta	a, -4
	or	*ar2+, a
	exp	b
	sub	b, a
	mpyr	*ar2+, a
	exp	a
	ld	*ar5+, b
	sub	#0x20, a
	xor	#0xAAAA, a
	macr	*ar3+, *ar4+, a
	mpyr	*ar2+, a
	macr	*ar2+, a
	masr	*ar2+, *ar4+, a
	nop
	mpyu	*ar2+, a
	mar	*ar3-
	stl	b, *ar7+
	xor	#0xAAAA, a
	sftl	a, -4
	ldr	*ar2+, a
	and	*ar2+, a
	mas	*ar2+, a
	delay	*ar2
	sth	a, *ar5+
	ldr	*ar2+, a
	neg	b
	mas	*ar3+, *ar4+, a
	and	*ar2+, a
	mpyu	*ar2+, a
	exp	b
	nop
	exp	b
	delay	*ar2
	or	*ar2+, a
	squra	*ar2+, a
	and	*ar2+, a
	sftl	a, -8
	mpy	*ar3+, *ar4+, a
	exp	b
	macr	*ar2+, a
	mpy	*ar3+, *ar4+, a
	abs	a
	squr	*ar2+, a
	sftl	b, 1
	norm	b
	nop
	and	#0x00FF, b
	nop
	mpyr	*ar2+, a
	sub	*ar3+, b
	add	*ar2+, a
	macr	*ar2+, a
	sth	b, *ar7+
	delay	*ar2
	mac	*ar2+, *ar3+, b
	sth	b, *ar7+
	sub	*ar2+, a
	macr	*ar2+, a
	mas	*ar3+, *ar4+, a
	sth	b, *ar7+
	mpyu	*ar2+, a
	mpyr	*ar2+, a
	or	#0x0F0F, a
	nop
	xor	#0x5555, b
	ldr	*ar2+, a
	nop
	sub	*ar2+, a
	add	a, b
	rol	b
	rol	a
	ltd	*ar3
	ldr	*ar2+, a
	neg	b
	sfta	a, -8
	sftl	b, 1
	nop
	add	b, a
	add	*ar3+, b
	squrs	*ar2+, a
	ltd	*ar3
	mpy	*ar3+, *ar4+, a
	ldu	*ar2+, b
	ltd	*ar3
	exp	b
	ror	b
	neg	b
	ldr	*ar2+, a
	mpy	*ar2+, a
	mpyr	*ar2+, a
	mac	*ar2+, *ar3+, b
	ltd	*ar3
	xor	#0xAAAA, a
	neg	a
	sftl	b, 1
	mpy	*ar3+, *ar4+, a
	norm	a
	ltd	*ar3
	or	#0xFF00, b
	norm	a
	squr	*ar2+, a
	sub	a, b
	squr	*ar2+, a
	rol	a
	macr	*ar2+, a
	sftl	a, -8
	xor	#0x5555, b
	norm	a
	ld	*ar5+, b
	neg	b
	mas	*ar3+, *ar4+, a
	stl	b, *ar7+
	neg	a
	exp	a
	ror	b
	squr	*ar2+, a
	sftl	b, -1
	mpyr	*ar2+, a
	nop
	rol	b
	sth	a, *ar6+
	xor	*ar2+, a
	ltd	*ar3
	abs	a
	and	#0x00FF, b
	ldu	*ar2+, b
	mar	*ar2+
	sfta	a, -8
	ldr	*ar2+, a
	or	*ar2+, a
	ror	b
	ldu	*ar2+, b
	mpyu	*ar2+, a
	delay	*ar2
	mar	*ar2+
	squra	*ar2+, a
	squra	*ar2+, a
	or	#0xFF00, b
	ldu	*ar2+, b
	ror	a
	macr	*ar3+, *ar4+, a
	delay	*ar2
	abs	a
	delay	*ar2
	mar	*ar4+0%
	mas	*ar3+, *ar4+, a
	ldr	*ar2+, a
	sftl	a, 4
	and	*ar2+, a
	mas	*ar3+, *ar4+, a
	sfta	a, -4
	mac	*ar2+, a
	and	#0x00FF, b
	stl	b, *ar7+
	delay	*ar2
	delay	*ar2
	mas	*ar2+, a
	nop
	mpyr	*ar2+, a
	or	*ar2+, a
	sub	#0x20, a
	mpy	*ar2+, a
	rol	a
	mpyu	*ar2+, a
	or	#0x0F0F, a
	mar	*ar2+
	mac	*ar2+, a
	exp	b
	delay	*ar2
	mpyu	*ar2+, a
	ror	a
	sfta	b, 1
	sth	a, *ar6+
	or	*ar2+, a
	sub	b, a
	ldr	*ar2+, a
	masr	*ar2+, *ar4+, a
	ror	b
	ldu	*ar2+, b
	stl	a, *ar6+
	mpyr	*ar2+, a
	sftl	a, -8
	neg	b
	and	#0xF0F0, a
	nop
	sftl	a, -8
	mpy	*ar2+, a
	mas	*ar3+, *ar4+, a
	sub	*ar3+, b
	sfta	a, -4
	ret

; ====================================================================
; SECTION 21: extra data tables — for relocation testing
; ====================================================================

	.sect	".rodata_extra"

table_big_a:
	.word	0x0000, 0x001F, 0x003E, 0x005D, 0x007C, 0x009B, 0x00BA, 0x00D9
	.word	0x00F8, 0x0117, 0x0136, 0x0155, 0x0174, 0x0193, 0x01B2, 0x01D1
	.word	0x01F0, 0x020F, 0x022E, 0x024D, 0x026C, 0x028B, 0x02AA, 0x02C9
	.word	0x02E8, 0x0307, 0x0326, 0x0345, 0x0364, 0x0383, 0x03A2, 0x03C1
	.word	0x03E0, 0x03FF, 0x041E, 0x043D, 0x045C, 0x047B, 0x049A, 0x04B9
	.word	0x04D8, 0x04F7, 0x0516, 0x0535, 0x0554, 0x0573, 0x0592, 0x05B1
	.word	0x05D0, 0x05EF, 0x060E, 0x062D, 0x064C, 0x066B, 0x068A, 0x06A9
	.word	0x06C8, 0x06E7, 0x0706, 0x0725, 0x0744, 0x0763, 0x0782, 0x07A1
	.word	0x07C0, 0x07DF, 0x07FE, 0x081D, 0x083C, 0x085B, 0x087A, 0x0899
	.word	0x08B8, 0x08D7, 0x08F6, 0x0915, 0x0934, 0x0953, 0x0972, 0x0991
	.word	0x09B0, 0x09CF, 0x09EE, 0x0A0D, 0x0A2C, 0x0A4B, 0x0A6A, 0x0A89
	.word	0x0AA8, 0x0AC7, 0x0AE6, 0x0B05, 0x0B24, 0x0B43, 0x0B62, 0x0B81
	.word	0x0BA0, 0x0BBF, 0x0BDE, 0x0BFD, 0x0C1C, 0x0C3B, 0x0C5A, 0x0C79
	.word	0x0C98, 0x0CB7, 0x0CD6, 0x0CF5, 0x0D14, 0x0D33, 0x0D52, 0x0D71
	.word	0x0D90, 0x0DAF, 0x0DCE, 0x0DED, 0x0E0C, 0x0E2B, 0x0E4A, 0x0E69
	.word	0x0E88, 0x0EA7, 0x0EC6, 0x0EE5, 0x0F04, 0x0F23, 0x0F42, 0x0F61
	.word	0x0F80, 0x0F9F, 0x0FBE, 0x0FDD, 0x0FFC, 0x101B, 0x103A, 0x1059
	.word	0x1078, 0x1097, 0x10B6, 0x10D5, 0x10F4, 0x1113, 0x1132, 0x1151
	.word	0x1170, 0x118F, 0x11AE, 0x11CD, 0x11EC, 0x120B, 0x122A, 0x1249
	.word	0x1268, 0x1287, 0x12A6, 0x12C5, 0x12E4, 0x1303, 0x1322, 0x1341
	.word	0x1360, 0x137F, 0x139E, 0x13BD, 0x13DC, 0x13FB, 0x141A, 0x1439
	.word	0x1458, 0x1477, 0x1496, 0x14B5, 0x14D4, 0x14F3, 0x1512, 0x1531
	.word	0x1550, 0x156F, 0x158E, 0x15AD, 0x15CC, 0x15EB, 0x160A, 0x1629
	.word	0x1648, 0x1667, 0x1686, 0x16A5, 0x16C4, 0x16E3, 0x1702, 0x1721
	.word	0x1740, 0x175F, 0x177E, 0x179D, 0x17BC, 0x17DB, 0x17FA, 0x1819
	.word	0x1838, 0x1857, 0x1876, 0x1895, 0x18B4, 0x18D3, 0x18F2, 0x1911
	.word	0x1930, 0x194F, 0x196E, 0x198D, 0x19AC, 0x19CB, 0x19EA, 0x1A09
	.word	0x1A28, 0x1A47, 0x1A66, 0x1A85, 0x1AA4, 0x1AC3, 0x1AE2, 0x1B01
	.word	0x1B20, 0x1B3F, 0x1B5E, 0x1B7D, 0x1B9C, 0x1BBB, 0x1BDA, 0x1BF9
	.word	0x1C18, 0x1C37, 0x1C56, 0x1C75, 0x1C94, 0x1CB3, 0x1CD2, 0x1CF1
	.word	0x1D10, 0x1D2F, 0x1D4E, 0x1D6D, 0x1D8C, 0x1DAB, 0x1DCA, 0x1DE9
	.word	0x1E08, 0x1E27, 0x1E46, 0x1E65, 0x1E84, 0x1EA3, 0x1EC2, 0x1EE1
	.word	0x1F00, 0x1F1F, 0x1F3E, 0x1F5D, 0x1F7C, 0x1F9B, 0x1FBA, 0x1FD9
	.word	0x1FF8, 0x2017, 0x2036, 0x2055, 0x2074, 0x2093, 0x20B2, 0x20D1
	.word	0x20F0, 0x210F, 0x212E, 0x214D, 0x216C, 0x218B, 0x21AA, 0x21C9
	.word	0x21E8, 0x2207, 0x2226, 0x2245, 0x2264, 0x2283, 0x22A2, 0x22C1
	.word	0x22E0, 0x22FF, 0x231E, 0x233D, 0x235C, 0x237B, 0x239A, 0x23B9
	.word	0x23D8, 0x23F7, 0x2416, 0x2435, 0x2454, 0x2473, 0x2492, 0x24B1
	.word	0x24D0, 0x24EF, 0x250E, 0x252D, 0x254C, 0x256B, 0x258A, 0x25A9
	.word	0x25C8, 0x25E7, 0x2606, 0x2625, 0x2644, 0x2663, 0x2682, 0x26A1
	.word	0x26C0, 0x26DF, 0x26FE, 0x271D, 0x273C, 0x275B, 0x277A, 0x2799
	.word	0x27B8, 0x27D7, 0x27F6, 0x2815, 0x2834, 0x2853, 0x2872, 0x2891
	.word	0x28B0, 0x28CF, 0x28EE, 0x290D, 0x292C, 0x294B, 0x296A, 0x2989
	.word	0x29A8, 0x29C7, 0x29E6, 0x2A05, 0x2A24, 0x2A43, 0x2A62, 0x2A81
	.word	0x2AA0, 0x2ABF, 0x2ADE, 0x2AFD, 0x2B1C, 0x2B3B, 0x2B5A, 0x2B79
	.word	0x2B98, 0x2BB7, 0x2BD6, 0x2BF5, 0x2C14, 0x2C33, 0x2C52, 0x2C71
	.word	0x2C90, 0x2CAF, 0x2CCE, 0x2CED, 0x2D0C, 0x2D2B, 0x2D4A, 0x2D69
	.word	0x2D88, 0x2DA7, 0x2DC6, 0x2DE5, 0x2E04, 0x2E23, 0x2E42, 0x2E61
	.word	0x2E80, 0x2E9F, 0x2EBE, 0x2EDD, 0x2EFC, 0x2F1B, 0x2F3A, 0x2F59
	.word	0x2F78, 0x2F97, 0x2FB6, 0x2FD5, 0x2FF4, 0x3013, 0x3032, 0x3051
	.word	0x3070, 0x308F, 0x30AE, 0x30CD, 0x30EC, 0x310B, 0x312A, 0x3149
	.word	0x3168, 0x3187, 0x31A6, 0x31C5, 0x31E4, 0x3203, 0x3222, 0x3241
	.word	0x3260, 0x327F, 0x329E, 0x32BD, 0x32DC, 0x32FB, 0x331A, 0x3339
	.word	0x3358, 0x3377, 0x3396, 0x33B5, 0x33D4, 0x33F3, 0x3412, 0x3431
	.word	0x3450, 0x346F, 0x348E, 0x34AD, 0x34CC, 0x34EB, 0x350A, 0x3529
	.word	0x3548, 0x3567, 0x3586, 0x35A5, 0x35C4, 0x35E3, 0x3602, 0x3621
	.word	0x3640, 0x365F, 0x367E, 0x369D, 0x36BC, 0x36DB, 0x36FA, 0x3719
	.word	0x3738, 0x3757, 0x3776, 0x3795, 0x37B4, 0x37D3, 0x37F2, 0x3811
	.word	0x3830, 0x384F, 0x386E, 0x388D, 0x38AC, 0x38CB, 0x38EA, 0x3909
	.word	0x3928, 0x3947, 0x3966, 0x3985, 0x39A4, 0x39C3, 0x39E2, 0x3A01
	.word	0x3A20, 0x3A3F, 0x3A5E, 0x3A7D, 0x3A9C, 0x3ABB, 0x3ADA, 0x3AF9
	.word	0x3B18, 0x3B37, 0x3B56, 0x3B75, 0x3B94, 0x3BB3, 0x3BD2, 0x3BF1
	.word	0x3C10, 0x3C2F, 0x3C4E, 0x3C6D, 0x3C8C, 0x3CAB, 0x3CCA, 0x3CE9
	.word	0x3D08, 0x3D27, 0x3D46, 0x3D65, 0x3D84, 0x3DA3, 0x3DC2, 0x3DE1

table_big_b:
	.word	0x0080, 0x00BB, 0x00F6, 0x0131, 0x016C, 0x01A7, 0x01E2, 0x021D
	.word	0x0258, 0x0293, 0x02CE, 0x0309, 0x0344, 0x037F, 0x03BA, 0x03F5
	.word	0x0430, 0x046B, 0x04A6, 0x04E1, 0x051C, 0x0557, 0x0592, 0x05CD
	.word	0x0608, 0x0643, 0x067E, 0x06B9, 0x06F4, 0x072F, 0x076A, 0x07A5
	.word	0x07E0, 0x081B, 0x0856, 0x0891, 0x08CC, 0x0907, 0x0942, 0x097D
	.word	0x09B8, 0x09F3, 0x0A2E, 0x0A69, 0x0AA4, 0x0ADF, 0x0B1A, 0x0B55
	.word	0x0B90, 0x0BCB, 0x0C06, 0x0C41, 0x0C7C, 0x0CB7, 0x0CF2, 0x0D2D
	.word	0x0D68, 0x0DA3, 0x0DDE, 0x0E19, 0x0E54, 0x0E8F, 0x0ECA, 0x0F05
	.word	0x0F40, 0x0F7B, 0x0FB6, 0x0FF1, 0x102C, 0x1067, 0x10A2, 0x10DD
	.word	0x1118, 0x1153, 0x118E, 0x11C9, 0x1204, 0x123F, 0x127A, 0x12B5
	.word	0x12F0, 0x132B, 0x1366, 0x13A1, 0x13DC, 0x1417, 0x1452, 0x148D
	.word	0x14C8, 0x1503, 0x153E, 0x1579, 0x15B4, 0x15EF, 0x162A, 0x1665
	.word	0x16A0, 0x16DB, 0x1716, 0x1751, 0x178C, 0x17C7, 0x1802, 0x183D
	.word	0x1878, 0x18B3, 0x18EE, 0x1929, 0x1964, 0x199F, 0x19DA, 0x1A15
	.word	0x1A50, 0x1A8B, 0x1AC6, 0x1B01, 0x1B3C, 0x1B77, 0x1BB2, 0x1BED
	.word	0x1C28, 0x1C63, 0x1C9E, 0x1CD9, 0x1D14, 0x1D4F, 0x1D8A, 0x1DC5
	.word	0x1E00, 0x1E3B, 0x1E76, 0x1EB1, 0x1EEC, 0x1F27, 0x1F62, 0x1F9D
	.word	0x1FD8, 0x2013, 0x204E, 0x2089, 0x20C4, 0x20FF, 0x213A, 0x2175
	.word	0x21B0, 0x21EB, 0x2226, 0x2261, 0x229C, 0x22D7, 0x2312, 0x234D
	.word	0x2388, 0x23C3, 0x23FE, 0x2439, 0x2474, 0x24AF, 0x24EA, 0x2525
	.word	0x2560, 0x259B, 0x25D6, 0x2611, 0x264C, 0x2687, 0x26C2, 0x26FD
	.word	0x2738, 0x2773, 0x27AE, 0x27E9, 0x2824, 0x285F, 0x289A, 0x28D5
	.word	0x2910, 0x294B, 0x2986, 0x29C1, 0x29FC, 0x2A37, 0x2A72, 0x2AAD
	.word	0x2AE8, 0x2B23, 0x2B5E, 0x2B99, 0x2BD4, 0x2C0F, 0x2C4A, 0x2C85
	.word	0x2CC0, 0x2CFB, 0x2D36, 0x2D71, 0x2DAC, 0x2DE7, 0x2E22, 0x2E5D
	.word	0x2E98, 0x2ED3, 0x2F0E, 0x2F49, 0x2F84, 0x2FBF, 0x2FFA, 0x3035
	.word	0x3070, 0x30AB, 0x30E6, 0x3121, 0x315C, 0x3197, 0x31D2, 0x320D
	.word	0x3248, 0x3283, 0x32BE, 0x32F9, 0x3334, 0x336F, 0x33AA, 0x33E5
	.word	0x3420, 0x345B, 0x3496, 0x34D1, 0x350C, 0x3547, 0x3582, 0x35BD
	.word	0x35F8, 0x3633, 0x366E, 0x36A9, 0x36E4, 0x371F, 0x375A, 0x3795
	.word	0x37D0, 0x380B, 0x3846, 0x3881, 0x38BC, 0x38F7, 0x3932, 0x396D
	.word	0x39A8, 0x39E3, 0x3A1E, 0x3A59, 0x3A94, 0x3ACF, 0x3B0A, 0x3B45

table_long:
	.long	0x00000000, 0x00010101, 0x00020202, 0x00030303
	.long	0x00040404, 0x00050505, 0x00060606, 0x00070707
	.long	0x00080808, 0x00090909, 0x000A0A0A, 0x000B0B0B
	.long	0x000C0C0C, 0x000D0D0D, 0x000E0E0E, 0x000F0F0F
	.long	0x00101010, 0x00111111, 0x00121212, 0x00131313
	.long	0x00141414, 0x00151515, 0x00161616, 0x00171717
	.long	0x00181818, 0x00191919, 0x001A1A1A, 0x001B1B1B
	.long	0x001C1C1C, 0x001D1D1D, 0x001E1E1E, 0x001F1F1F
	.long	0x00202020, 0x00212121, 0x00222222, 0x00232323
	.long	0x00242424, 0x00252525, 0x00262626, 0x00272727
	.long	0x00282828, 0x00292929, 0x002A2A2A, 0x002B2B2B
	.long	0x002C2C2C, 0x002D2D2D, 0x002E2E2E, 0x002F2F2F
	.long	0x00303030, 0x00313131, 0x00323232, 0x00333333
	.long	0x00343434, 0x00353535, 0x00363636, 0x00373737
	.long	0x00383838, 0x00393939, 0x003A3A3A, 0x003B3B3B
	.long	0x003C3C3C, 0x003D3D3D, 0x003E3E3E, 0x003F3F3F
	.long	0x00404040, 0x00414141, 0x00424242, 0x00434343
	.long	0x00444444, 0x00454545, 0x00464646, 0x00474747
	.long	0x00484848, 0x00494949, 0x004A4A4A, 0x004B4B4B
	.long	0x004C4C4C, 0x004D4D4D, 0x004E4E4E, 0x004F4F4F
	.long	0x00505050, 0x00515151, 0x00525252, 0x00535353
	.long	0x00545454, 0x00555555, 0x00565656, 0x00575757
	.long	0x00585858, 0x00595959, 0x005A5A5A, 0x005B5B5B
	.long	0x005C5C5C, 0x005D5D5D, 0x005E5E5E, 0x005F5F5F
	.long	0x00606060, 0x00616161, 0x00626262, 0x00636363
	.long	0x00646464, 0x00656565, 0x00666666, 0x00676767
	.long	0x00686868, 0x00696969, 0x006A6A6A, 0x006B6B6B
	.long	0x006C6C6C, 0x006D6D6D, 0x006E6E6E, 0x006F6F6F
	.long	0x00707070, 0x00717171, 0x00727272, 0x00737373
	.long	0x00747474, 0x00757575, 0x00767676, 0x00777777
	.long	0x00787878, 0x00797979, 0x007A7A7A, 0x007B7B7B
	.long	0x007C7C7C, 0x007D7D7D, 0x007E7E7E, 0x007F7F7F

table_floats:
	.float	$cos(0.0000), $sin(0.0000)
	.float	$cos(0.1000), $sin(0.1000)
	.float	$cos(0.2000), $sin(0.2000)
	.float	$cos(0.3000), $sin(0.3000)
	.float	$cos(0.4000), $sin(0.4000)
	.float	$cos(0.5000), $sin(0.5000)
	.float	$cos(0.6000), $sin(0.6000)
	.float	$cos(0.7000), $sin(0.7000)
	.float	$cos(0.8000), $sin(0.8000)
	.float	$cos(0.9000), $sin(0.9000)
	.float	$cos(1.0000), $sin(1.0000)
	.float	$cos(1.1000), $sin(1.1000)
	.float	$cos(1.2000), $sin(1.2000)
	.float	$cos(1.3000), $sin(1.3000)
	.float	$cos(1.4000), $sin(1.4000)
	.float	$cos(1.5000), $sin(1.5000)
	.float	$cos(1.6000), $sin(1.6000)
	.float	$cos(1.7000), $sin(1.7000)
	.float	$cos(1.8000), $sin(1.8000)
	.float	$cos(1.9000), $sin(1.9000)
	.float	$cos(2.0000), $sin(2.0000)
	.float	$cos(2.1000), $sin(2.1000)
	.float	$cos(2.2000), $sin(2.2000)
	.float	$cos(2.3000), $sin(2.3000)
	.float	$cos(2.4000), $sin(2.4000)
	.float	$cos(2.5000), $sin(2.5000)
	.float	$cos(2.6000), $sin(2.6000)
	.float	$cos(2.7000), $sin(2.7000)
	.float	$cos(2.8000), $sin(2.8000)
	.float	$cos(2.9000), $sin(2.9000)
	.float	$cos(3.0000), $sin(3.0000)
	.float	$cos(3.1000), $sin(3.1000)
	.float	$cos(3.2000), $sin(3.2000)
	.float	$cos(3.3000), $sin(3.3000)
	.float	$cos(3.4000), $sin(3.4000)
	.float	$cos(3.5000), $sin(3.5000)
	.float	$cos(3.6000), $sin(3.6000)
	.float	$cos(3.7000), $sin(3.7000)
	.float	$cos(3.8000), $sin(3.8000)
	.float	$cos(3.9000), $sin(3.9000)
	.float	$cos(4.0000), $sin(4.0000)
	.float	$cos(4.1000), $sin(4.1000)
	.float	$cos(4.2000), $sin(4.2000)
	.float	$cos(4.3000), $sin(4.3000)
	.float	$cos(4.4000), $sin(4.4000)
	.float	$cos(4.5000), $sin(4.5000)
	.float	$cos(4.6000), $sin(4.6000)
	.float	$cos(4.7000), $sin(4.7000)
	.float	$cos(4.8000), $sin(4.8000)
	.float	$cos(4.9000), $sin(4.9000)
	.float	$cos(5.0000), $sin(5.0000)
	.float	$cos(5.1000), $sin(5.1000)
	.float	$cos(5.2000), $sin(5.2000)
	.float	$cos(5.3000), $sin(5.3000)
	.float	$cos(5.4000), $sin(5.4000)
	.float	$cos(5.5000), $sin(5.5000)
	.float	$cos(5.6000), $sin(5.6000)
	.float	$cos(5.7000), $sin(5.7000)
	.float	$cos(5.8000), $sin(5.8000)
	.float	$cos(5.9000), $sin(5.9000)
	.float	$cos(6.0000), $sin(6.0000)
	.float	$cos(6.1000), $sin(6.1000)
	.float	$cos(6.2000), $sin(6.2000)
	.float	$cos(6.3000), $sin(6.3000)

table_atan:
	.float	$atan(0.0000)
	.float	$atan(0.0500)
	.float	$atan(0.1000)
	.float	$atan(0.1500)
	.float	$atan(0.2000)
	.float	$atan(0.2500)
	.float	$atan(0.3000)
	.float	$atan(0.3500)
	.float	$atan(0.4000)
	.float	$atan(0.4500)
	.float	$atan(0.5000)
	.float	$atan(0.5500)
	.float	$atan(0.6000)
	.float	$atan(0.6500)
	.float	$atan(0.7000)
	.float	$atan(0.7500)
	.float	$atan(0.8000)
	.float	$atan(0.8500)
	.float	$atan(0.9000)
	.float	$atan(0.9500)
	.float	$atan(1.0000)
	.float	$atan(1.0500)
	.float	$atan(1.1000)
	.float	$atan(1.1500)
	.float	$atan(1.2000)
	.float	$atan(1.2500)
	.float	$atan(1.3000)
	.float	$atan(1.3500)
	.float	$atan(1.4000)
	.float	$atan(1.4500)
	.float	$atan(1.5000)
	.float	$atan(1.5500)

table_acos:
	.float	$acos(0.0000)
	.float	$acos(0.0625)
	.float	$acos(0.1250)
	.float	$acos(0.1875)
	.float	$acos(0.2500)
	.float	$acos(0.3125)
	.float	$acos(0.3750)
	.float	$acos(0.4375)
	.float	$acos(0.5000)
	.float	$acos(0.5625)
	.float	$acos(0.6250)
	.float	$acos(0.6875)
	.float	$acos(0.7500)
	.float	$acos(0.8125)
	.float	$acos(0.8750)
	.float	$acos(0.9375)

table_asin:
	.float	$asin(0.0000)
	.float	$asin(0.0625)
	.float	$asin(0.1250)
	.float	$asin(0.1875)
	.float	$asin(0.2500)
	.float	$asin(0.3125)
	.float	$asin(0.3750)
	.float	$asin(0.4375)
	.float	$asin(0.5000)
	.float	$asin(0.5625)
	.float	$asin(0.6250)
	.float	$asin(0.6875)
	.float	$asin(0.7500)
	.float	$asin(0.8125)
	.float	$asin(0.8750)
	.float	$asin(0.9375)

	.sect	".text"

; ====================================================================
; SECTION 22: macros and pseudo-ops
; ====================================================================

	.asg	"*ar2+", PTR1		; substitution symbol for AR2+
	.asg	"*ar3+", PTR2
	.eval	16, COUNT


_macro_user:
	ld	PTR1, a			; resolves to: ld *ar2+, a
	add	PTR2, a			; resolves to: add *ar3+, a
	stm	#COUNT, brc		; resolves to: stm #16, brc
	ret

	.macro	DOUBLE	arg
	add	:arg:, :arg:		; double the arg in-place
	.endm

_macro_user2:
	DOUBLE	a			; A = A + A
	DOUBLE	b			; B = B + B
	ret

; ====================================================================
; SECTION 23: 200 more micro functions for symbol stress
; ====================================================================

_micro_040:
	ld	#0x0028, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_041:
	ld	#0x0029, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_042:
	ld	#0x002A, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_043:
	ld	#0x002B, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_044:
	ld	#0x002C, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_045:
	ld	#0x002D, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_046:
	ld	#0x002E, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_047:
	ld	#0x002F, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_048:
	ld	#0x0030, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_049:
	ld	#0x0031, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_050:
	ld	#0x0032, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_051:
	ld	#0x0033, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_052:
	ld	#0x0034, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_053:
	ld	#0x0035, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_054:
	ld	#0x0036, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_055:
	ld	#0x0037, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_056:
	ld	#0x0038, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_057:
	ld	#0x0039, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_058:
	ld	#0x003A, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_059:
	ld	#0x003B, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_060:
	ld	#0x003C, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_061:
	ld	#0x003D, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_062:
	ld	#0x003E, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_063:
	ld	#0x003F, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_064:
	ld	#0x0040, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_065:
	ld	#0x0041, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_066:
	ld	#0x0042, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_067:
	ld	#0x0043, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_068:
	ld	#0x0044, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_069:
	ld	#0x0045, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_070:
	ld	#0x0046, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_071:
	ld	#0x0047, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_072:
	ld	#0x0048, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_073:
	ld	#0x0049, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_074:
	ld	#0x004A, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_075:
	ld	#0x004B, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_076:
	ld	#0x004C, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_077:
	ld	#0x004D, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_078:
	ld	#0x004E, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_079:
	ld	#0x004F, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_080:
	ld	#0x0050, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_081:
	ld	#0x0051, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_082:
	ld	#0x0052, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_083:
	ld	#0x0053, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_084:
	ld	#0x0054, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_085:
	ld	#0x0055, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_086:
	ld	#0x0056, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_087:
	ld	#0x0057, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_088:
	ld	#0x0058, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_089:
	ld	#0x0059, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_090:
	ld	#0x005A, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_091:
	ld	#0x005B, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_092:
	ld	#0x005C, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_093:
	ld	#0x005D, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_094:
	ld	#0x005E, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_095:
	ld	#0x005F, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_096:
	ld	#0x0060, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_097:
	ld	#0x0061, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_098:
	ld	#0x0062, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_099:
	ld	#0x0063, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_100:
	ld	#0x0064, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_101:
	ld	#0x0065, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_102:
	ld	#0x0066, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_103:
	ld	#0x0067, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_104:
	ld	#0x0068, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_105:
	ld	#0x0069, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_106:
	ld	#0x006A, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_107:
	ld	#0x006B, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_108:
	ld	#0x006C, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_109:
	ld	#0x006D, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_110:
	ld	#0x006E, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_111:
	ld	#0x006F, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_112:
	ld	#0x0070, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_113:
	ld	#0x0071, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_114:
	ld	#0x0072, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_115:
	ld	#0x0073, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_116:
	ld	#0x0074, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_117:
	ld	#0x0075, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_118:
	ld	#0x0076, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_119:
	ld	#0x0077, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_120:
	ld	#0x0078, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_121:
	ld	#0x0079, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_122:
	ld	#0x007A, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_123:
	ld	#0x007B, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_124:
	ld	#0x007C, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_125:
	ld	#0x007D, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_126:
	ld	#0x007E, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_127:
	ld	#0x007F, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_128:
	ld	#0x0080, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_129:
	ld	#0x0081, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_130:
	ld	#0x0082, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_131:
	ld	#0x0083, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_132:
	ld	#0x0084, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_133:
	ld	#0x0085, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_134:
	ld	#0x0086, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_135:
	ld	#0x0087, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_136:
	ld	#0x0088, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_137:
	ld	#0x0089, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_138:
	ld	#0x008A, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_139:
	ld	#0x008B, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_140:
	ld	#0x008C, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_141:
	ld	#0x008D, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_142:
	ld	#0x008E, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_143:
	ld	#0x008F, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_144:
	ld	#0x0090, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_145:
	ld	#0x0091, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_146:
	ld	#0x0092, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_147:
	ld	#0x0093, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_148:
	ld	#0x0094, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_149:
	ld	#0x0095, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_150:
	ld	#0x0096, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_151:
	ld	#0x0097, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_152:
	ld	#0x0098, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_153:
	ld	#0x0099, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_154:
	ld	#0x009A, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_155:
	ld	#0x009B, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_156:
	ld	#0x009C, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_157:
	ld	#0x009D, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_158:
	ld	#0x009E, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_159:
	ld	#0x009F, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_160:
	ld	#0x00A0, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_161:
	ld	#0x00A1, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_162:
	ld	#0x00A2, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_163:
	ld	#0x00A3, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_164:
	ld	#0x00A4, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_165:
	ld	#0x00A5, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_166:
	ld	#0x00A6, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_167:
	ld	#0x00A7, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_168:
	ld	#0x00A8, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_169:
	ld	#0x00A9, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_170:
	ld	#0x00AA, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_171:
	ld	#0x00AB, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_172:
	ld	#0x00AC, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_173:
	ld	#0x00AD, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_174:
	ld	#0x00AE, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_175:
	ld	#0x00AF, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_176:
	ld	#0x00B0, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_177:
	ld	#0x00B1, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_178:
	ld	#0x00B2, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_179:
	ld	#0x00B3, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_180:
	ld	#0x00B4, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_181:
	ld	#0x00B5, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_182:
	ld	#0x00B6, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_183:
	ld	#0x00B7, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_184:
	ld	#0x00B8, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_185:
	ld	#0x00B9, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_186:
	ld	#0x00BA, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_187:
	ld	#0x00BB, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_188:
	ld	#0x00BC, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_189:
	ld	#0x00BD, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

_micro_190:
	ld	#0x00BE, a
	add	*ar2+, a
	stl	a, *ar3+
	ret

_micro_191:
	ld	#0x00BF, a
	sub	*ar2+, a
	stl	a, *ar3+
	ret

_micro_192:
	ld	#0x00C0, a
	and	*ar2+, a
	stl	a, *ar3+
	ret

_micro_193:
	ld	#0x00C1, a
	or	*ar2+, a
	stl	a, *ar3+
	ret

_micro_194:
	ld	#0x00C2, a
	xor	*ar2+, a
	stl	a, *ar3+
	ret

_micro_195:
	ld	#0x00C3, a
	mac	*ar2+, a
	stl	a, *ar3+
	ret

_micro_196:
	ld	#0x00C4, a
	mas	*ar2+, a
	stl	a, *ar3+
	ret

_micro_197:
	ld	#0x00C5, a
	mpy	*ar2+, a
	stl	a, *ar3+
	ret

_micro_198:
	ld	#0x00C6, a
	mpyr	*ar2+, a
	stl	a, *ar3+
	ret

_micro_199:
	ld	#0x00C7, a
	mpyu	*ar2+, a
	stl	a, *ar3+
	ret

; ====================================================================
; SECTION 24: super-dense final block (2000 instructions)
; ====================================================================

_dense_super:
	ltd	*ar3
	sth	a, *ar6+
	exp	b
	mar	*ar3-
	sth	a, *ar6+
	exp	b
	mac	*ar3+, *ar4+, a
	mas	*ar2+, a
	sfta	a, 4
	mpyr	*ar2+, a
	sth	b, *ar7+
	squr	*ar2+, a
	ltd	*ar3
	squrs	*ar2+, a
	macr	*ar3+, *ar4+, a
	and	#0x00FF, b
	exp	b
	sfta	a, 8
	ld	*ar5+, b
	sftl	b, -1
	rol	b
	stl	a, *ar6+
	sub	a, b
	rol	a
	masr	*ar2+, *ar4+, a
	mas	*ar2+, a
	squra	*ar2+, a
	neg	a
	sfta	b, 1
	sth	b, *ar7+
	ltd	*ar3
	ld	#0xFF00, b
	stl	b, *ar7+
	squra	*ar2+, a
	norm	a
	masr	*ar2+, *ar4+, a
	or	#0xFF00, b
	abs	a
	neg	b
	sfta	a, -8
	masr	*ar2+, *ar4+, a
	rol	a
	ld	*ar4+, a
	or	*ar2+, a
	ltd	*ar3
	ld	#0xFF00, b
	or	#0xFF00, b
	xor	#0x5555, b
	mpyr	*ar2+, a
	mpy	*ar3+, *ar4+, a
	rol	a
	nop
	neg	b
	ld	#0xFF00, b
	macr	*ar3+, *ar4+, a
	ld	*ar5+, b
	sth	a, *ar6+
	macr	*ar2+, a
	ldr	*ar2+, a
	stl	b, *ar7+
	macr	*ar2+, a
	ldr	*ar2+, a
	exp	a
	squra	*ar2+, a
	mar	*ar2+
	sth	b, *ar7+
	ldr	*ar2+, a
	mac	*ar3+, *ar4+, a
	squrs	*ar2+, a
	mpyr	*ar2+, a
	neg	b
	mpy	*ar3+, *ar4+, a
	sth	a, *ar5+
	delay	*ar2
	stl	a, *ar6+
	mac	*ar2+, a
	abs	b
	squra	*ar2+, a
	mpyr	*ar2+, a
	macr	*ar2+, a
	mar	*ar4+0%
	mpy	*ar2+, a
	macr	*ar2+, a
	sth	a, *ar5+
	exp	a
	sfta	b, 1
	or	#0xFF00, b
	ror	a
	sub	*ar3+, b
	ltd	*ar3
	ror	a
	masr	*ar2+, *ar4+, a
	mpy	*ar2+, a
	squrs	*ar2+, a
	ltd	*ar3
	mac	*ar2+, a
	ltd	*ar3
	ldr	*ar2+, a
	sub	#0x20, a
	ld	*ar5+, b
	mpyr	*ar2+, a
	sfta	b, 1
	masr	*ar2+, *ar4+, a
	masr	*ar2+, *ar4+, a
	ror	b
	or	*ar2+, a
	exp	b
	mac	*ar2+, a
	ror	b
	mpy	*ar2+, a
	mas	*ar3+, *ar4+, a
	squrs	*ar2+, a
	squra	*ar2+, a
	xor	#0xAAAA, a
	macr	*ar2+, a
	ldu	*ar2+, b
	or	#0x0F0F, a
	add	b, a
	and	*ar2+, a
	mas	*ar3+, *ar4+, a
	and	#0x00FF, b
	sftl	a, 4
	sfta	b, 1
	mpy	*ar2+, a
	ltd	*ar3
	squr	*ar2+, a
	macr	*ar2+, a
	neg	a
	squr	*ar2+, a
	macr	*ar2+, a
	mpyr	*ar2+, a
	stl	a, *ar5+
	masr	*ar2+, *ar4+, a
	or	*ar2+, a
	squrs	*ar2+, a
	mac	*ar3+, *ar4+, a
	stl	b, *ar7+
	mar	*ar2+
	squr	*ar2+, a
	and	*ar2+, a
	or	#0x0F0F, a
	norm	b
	macr	*ar2+, a
	mpyr	*ar2+, a
	and	#0x00FF, b
	neg	a
	masr	*ar2+, *ar4+, a
	ldu	*ar2+, b
	nop
	mac	*ar2+, *ar3+, b
	sfta	a, -8
	abs	b
	masr	*ar2+, *ar4+, a
	exp	a
	stl	a, *ar6+
	abs	b
	neg	b
	ld	#0xFF00, b
	sub	*ar2+, a
	and	#0x00FF, b
	mac	*ar2+, *ar3+, b
	ldr	*ar2+, a
	xor	#0x5555, b
	macr	*ar2+, a
	masr	*ar2+, *ar4+, a
	norm	a
	ror	a
	ltd	*ar3
	ror	b
	ld	#0xFF00, b
	delay	*ar2
	mar	*ar2+
	or	*ar2+, a
	ldu	*ar2+, b
	masr	*ar2+, *ar4+, a
	norm	a
	squr	*ar2+, a
	squr	*ar2+, a
	rol	b
	mpyr	*ar2+, a
	ltd	*ar3
	xor	*ar2+, a
	abs	b
	ldr	*ar2+, a
	ldr	*ar2+, a
	delay	*ar2
	ldu	*ar2+, b
	sth	b, *ar7+
	mpyu	*ar2+, a
	and	*ar2+, a
	neg	a
	and	#0xF0F0, a
	ltd	*ar3
	squr	*ar2+, a
	rol	b
	abs	a
	sfta	a, -4
	mpy	*ar2+, a
	squrs	*ar2+, a
	sub	*ar3+, b
	abs	b
	abs	a
	ld	#0xFF00, b
	sfta	b, 1
	nop
	mas	*ar3+, *ar4+, a
	squr	*ar2+, a
	xor	*ar2+, a
	nop
	mar	*ar2+
	nop
	rol	a
	squr	*ar2+, a
	xor	#0xAAAA, a
	exp	a
	macr	*ar3+, *ar4+, a
	rol	b
	ld	*ar4+, a
	delay	*ar2
	mar	*ar4+0%
	or	*ar2+, a
	mpy	*ar2+, a
	add	*ar3+, b
	nop
	abs	b
	sth	a, *ar5+
	ldu	*ar2+, b
	mas	*ar3+, *ar4+, a
	neg	a
	squra	*ar2+, a
	squrs	*ar2+, a
	mpy	*ar2+, a
	masr	*ar2+, *ar4+, a
	ldr	*ar2+, a
	sth	a, *ar5+
	sftl	a, 4
	mas	*ar2+, a
	ror	a
	sth	a, *ar6+
	abs	b
	ld	#0xFF00, b
	mpy	*ar3+, *ar4+, a
	sth	b, *ar7+
	stl	a, *ar6+
	squr	*ar2+, a
	delay	*ar2
	or	#0xFF00, b
	add	a, b
	exp	b
	ldr	*ar2+, a
	or	*ar2+, a
	ror	b
	xor	*ar2+, a
	ldr	*ar2+, a
	add	*ar2+, a
	and	#0xF0F0, a
	mas	*ar3+, *ar4+, a
	rol	a
	delay	*ar2
	ltd	*ar3
	ldu	*ar2+, b
	ld	*ar5+, b
	mpyu	*ar2+, a
	squra	*ar2+, a
	masr	*ar2+, *ar4+, a
	neg	a
	neg	b
	abs	a
	ldu	*ar2+, b
	macr	*ar2+, a
	or	*ar2+, a
	squr	*ar2+, a
	ld	#0x100, a
	mac	*ar3+, *ar4+, a
	add	b, a
	mpy	*ar3+, *ar4+, a
	and	#0xF0F0, a
	mas	*ar2+, a
	add	*ar2+, a
	ldr	*ar2+, a
	sth	a, *ar5+
	sftl	a, -8
	sftl	a, 8
	delay	*ar2
	ldu	*ar2+, b
	squr	*ar2+, a
	delay	*ar2
	ld	*ar3+, b
	ldr	*ar2+, a
	add	#0x10, a
	delay	*ar2
	sftl	b, -1
	rol	a
	sub	*ar3+, b
	mas	*ar2+, a
	mac	*ar3+, *ar4+, a
	norm	a
	sfta	a, -8
	sftl	a, 4
	mar	*ar2+
	squr	*ar2+, a
	mar	*ar2+
	sfta	a, -4
	sub	*ar3+, b
	mpyu	*ar2+, a
	squr	*ar2+, a
	xor	*ar2+, a
	ldr	*ar2+, a
	mar	*ar2+
	nop
	mpy	*ar3+, *ar4+, a
	delay	*ar2
	masr	*ar2+, *ar4+, a
	ld	*ar5+, b
	ror	b
	rol	b
	delay	*ar2
	sub	*ar2+, a
	sth	b, *ar7+
	or	*ar2+, a
	rol	a
	nop
	ror	a
	ld	*ar4+, a
	abs	b
	masr	*ar2+, *ar4+, a
	exp	b
	abs	b
	rol	b
	mac	*ar2+, a
	rol	a
	macr	*ar2+, a
	nop
	exp	a
	mpyr	*ar2+, a
	ldr	*ar2+, a
	neg	a
	stl	a, *ar5+
	mpyu	*ar2+, a
	ror	a
	stl	a, *ar5+
	mac	*ar2+, a
	mpyr	*ar2+, a
	xor	#0x5555, b
	mar	*ar4+0%
	mpy	*ar3+, *ar4+, a
	xor	#0x5555, b
	squra	*ar2+, a
	and	#0x00FF, b
	squrs	*ar2+, a
	mar	*ar2+
	ror	b
	sftl	b, -1
	mpyu	*ar2+, a
	abs	a
	mpy	*ar3+, *ar4+, a
	stl	b, *ar7+
	squrs	*ar2+, a
	masr	*ar2+, *ar4+, a
	ldr	*ar2+, a
	nop
	abs	b
	or	#0x0F0F, a
	ror	a
	ror	b
	or	*ar2+, a
	abs	a
	ror	b
	sfta	b, -1
	neg	a
	masr	*ar2+, *ar4+, a
	mpyr	*ar2+, a
	mas	*ar3+, *ar4+, a
	stl	a, *ar6+
	mpy	*ar2+, a
	sub	b, a
	mpyr	*ar2+, a
	exp	a
	ldr	*ar2+, a
	mac	*ar3+, *ar4+, a
	or	#0x0F0F, a
	ror	b
	ror	b
	mar	*ar2+
	ltd	*ar3
	ld	#0x100, a
	sub	a, b
	mas	*ar3+, *ar4+, a
	add	*ar2+, a
	mpyr	*ar2+, a
	ror	b
	delay	*ar2
	rol	b
	squra	*ar2+, a
	squrs	*ar2+, a
	stl	b, *ar7+
	squrs	*ar2+, a
	ld	*ar5+, b
	mar	*ar3-
	and	*ar2+, a
	or	*ar2+, a
	mar	*ar2+
	sub	#0x20, a
	neg	b
	delay	*ar2
	sth	b, *ar7+
	sftl	a, -4
	ldr	*ar2+, a
	xor	*ar2+, a
	masr	*ar2+, *ar4+, a
	ldr	*ar2+, a
	ldr	*ar2+, a
	rol	a
	mpyr	*ar2+, a
	ldr	*ar2+, a
	ltd	*ar3
	nop
	delay	*ar2
	squra	*ar2+, a
	ld	*ar5+, b
	squra	*ar2+, a
	sfta	a, 4
	ror	a
	stl	a, *ar6+
	sub	*ar2+, a
	xor	*ar2+, a
	neg	a
	and	#0xF0F0, a
	abs	a
	exp	b
	ldr	*ar2+, a
	sfta	a, 8
	ld	*ar2+, a
	mpyr	*ar2+, a
	stl	a, *ar5+
	mpy	*ar2+, a
	norm	a
	rol	a
	ld	*ar3+, b
	ror	a
	mar	*ar3-
	and	*ar2+, a
	add	b, a
	exp	a
	mac	*ar3+, *ar4+, a
	ld	#0xFF00, b
	mar	*ar4+0%
	rol	a
	mas	*ar2+, a
	mac	*ar3+, *ar4+, a
	ror	a
	sth	a, *ar5+
	stl	a, *ar6+
	mac	*ar2+, a
	sth	b, *ar7+
	mpyu	*ar2+, a
	squra	*ar2+, a
	sub	a, b
	mpyu	*ar2+, a
	mpy	*ar3+, *ar4+, a
	ld	#0xFF00, b
	ldr	*ar2+, a
	squrs	*ar2+, a
	mac	*ar2+, *ar3+, b
	mar	*ar3-
	mpyr	*ar2+, a
	ldr	*ar2+, a
	norm	a
	ror	b
	sftl	a, 4
	mas	*ar3+, *ar4+, a
	mar	*ar2+
	ltd	*ar3
	xor	#0xAAAA, a
	rol	b
	mar	*ar3-
	mar	*ar2+
	mpyr	*ar2+, a
	mpy	*ar3+, *ar4+, a
	mac	*ar2+, a
	ror	a
	mpy	*ar2+, a
	squrs	*ar2+, a
	squr	*ar2+, a
	mas	*ar3+, *ar4+, a
	stl	a, *ar6+
	sftl	a, -8
	mpy	*ar2+, a
	squrs	*ar2+, a
	abs	b
	rol	b
	masr	*ar2+, *ar4+, a
	delay	*ar2
	mpy	*ar3+, *ar4+, a
	nop
	ldr	*ar2+, a
	xor	#0x5555, b
	sftl	a, 4
	ror	a
	squrs	*ar2+, a
	and	*ar2+, a
	exp	a
	macr	*ar3+, *ar4+, a
	masr	*ar2+, *ar4+, a
	masr	*ar2+, *ar4+, a
	nop
	mar	*ar3-
	xor	*ar2+, a
	ld	*ar4+, a
	mpyr	*ar2+, a
	squrs	*ar2+, a
	add	*ar2+, a
	ldr	*ar2+, a
	mar	*ar3-
	squra	*ar2+, a
	squra	*ar2+, a
	abs	b
	delay	*ar2
	or	#0xFF00, b
	neg	b
	squrs	*ar2+, a
	masr	*ar2+, *ar4+, a
	ror	b
	norm	b
	squr	*ar2+, a
	ltd	*ar3
	add	b, a
	mpyr	*ar2+, a
	squrs	*ar2+, a
	mac	*ar2+, *ar3+, b
	squrs	*ar2+, a
	norm	a
	mpyu	*ar2+, a
	ldu	*ar2+, b
	ldr	*ar2+, a
	macr	*ar2+, a
	masr	*ar2+, *ar4+, a
	ldr	*ar2+, a
	ltd	*ar3
	mar	*ar3-
	ltd	*ar3
	and	#0xF0F0, a
	sfta	a, -4
	stl	a, *ar6+
	squrs	*ar2+, a
	sftl	b, 1
	ror	b
	ld	#0xFF00, b
	nop
	xor	*ar2+, a
	abs	b
	ldr	*ar2+, a
	sub	*ar3+, b
	neg	a
	ldr	*ar2+, a
	squr	*ar2+, a
	sth	b, *ar7+
	ror	a
	mpy	*ar2+, a
	macr	*ar3+, *ar4+, a
	or	#0xFF00, b
	mpyu	*ar2+, a
	add	b, a
	rol	a
	rol	a
	mac	*ar2+, a
	ldr	*ar2+, a
	sfta	a, 4
	masr	*ar2+, *ar4+, a
	sftl	b, 1
	xor	#0x5555, b
	ld	#0x100, a
	squr	*ar2+, a
	squr	*ar2+, a
	and	*ar2+, a
	xor	*ar2+, a
	sfta	b, -1
	mar	*ar4+0%
	ror	a
	macr	*ar3+, *ar4+, a
	xor	*ar2+, a
	mpyr	*ar2+, a
	mpyr	*ar2+, a
	xor	*ar2+, a
	mac	*ar2+, *ar3+, b
	macr	*ar3+, *ar4+, a
	mpy	*ar2+, a
	norm	a
	ldr	*ar2+, a
	squr	*ar2+, a
	stl	a, *ar5+
	sth	a, *ar6+
	masr	*ar2+, *ar4+, a
	nop
	squrs	*ar2+, a
	mac	*ar2+, *ar3+, b
	stl	a, *ar5+
	masr	*ar2+, *ar4+, a
	ldr	*ar2+, a
	sfta	a, -8
	ldr	*ar2+, a
	ldr	*ar2+, a
	ldu	*ar2+, b
	sfta	a, -4
	mpyu	*ar2+, a
	nop
	mac	*ar2+, *ar3+, b
	norm	a
	add	b, a
	nop
	sth	a, *ar6+
	squr	*ar2+, a
	mac	*ar3+, *ar4+, a
	ltd	*ar3
	mac	*ar2+, a
	norm	b
	sftl	b, 1
	sth	a, *ar5+
	add	#0x10, a
	nop
	mac	*ar2+, *ar3+, b
	add	*ar3+, b
	nop
	exp	b
	xor	#0x5555, b
	squrs	*ar2+, a
	exp	a
	stl	a, *ar5+
	sfta	a, -4
	mas	*ar2+, a
	or	#0x0F0F, a
	ldr	*ar2+, a
	add	#0x10, a
	sftl	a, 8
	mac	*ar2+, a
	ldu	*ar2+, b
	mpyr	*ar2+, a
	squra	*ar2+, a
	squrs	*ar2+, a
	ltd	*ar3
	squrs	*ar2+, a
	ldu	*ar2+, b
	ror	b
	nop
	stl	a, *ar6+
	macr	*ar2+, a
	macr	*ar2+, a
	ltd	*ar3
	nop
	macr	*ar3+, *ar4+, a
	mac	*ar3+, *ar4+, a
	mac	*ar3+, *ar4+, a
	ror	b
	abs	b
	sub	#0x20, a
	mar	*ar2+
	macr	*ar3+, *ar4+, a
	mpyu	*ar2+, a
	neg	b
	norm	b
	macr	*ar2+, a
	xor	#0x5555, b
	stl	a, *ar5+
	mac	*ar2+, a
	and	#0x00FF, b
	mac	*ar3+, *ar4+, a
	ltd	*ar3
	or	#0xFF00, b
	ld	*ar3+, b
	nop
	squrs	*ar2+, a
	ldu	*ar2+, b
	sub	*ar2+, a
	ld	#0x100, a
	squrs	*ar2+, a
	ror	a
	neg	b
	exp	b
	mar	*ar4+0%
	mpy	*ar3+, *ar4+, a
	ltd	*ar3
	add	a, b
	sftl	b, 1
	abs	b
	and	*ar2+, a
	ld	*ar4+, a
	mac	*ar2+, *ar3+, b
	ldr	*ar2+, a
	ldr	*ar2+, a
	sth	a, *ar5+
	ror	b
	mac	*ar2+, a
	squra	*ar2+, a
	ldu	*ar2+, b
	ldr	*ar2+, a
	squrs	*ar2+, a
	ld	#0x100, a
	ror	a
	add	*ar2+, a
	sth	b, *ar7+
	squra	*ar2+, a
	sftl	a, -8
	sth	a, *ar5+
	mpy	*ar2+, a
	delay	*ar2
	ldu	*ar2+, b
	rol	b
	ldr	*ar2+, a
	stl	b, *ar7+
	norm	b
	ldu	*ar2+, b
	stl	b, *ar7+
	ror	a
	or	#0xFF00, b
	add	b, a
	exp	a
	mpyr	*ar2+, a
	ld	#0xFF00, b
	macr	*ar2+, a
	delay	*ar2
	rol	b
	ldu	*ar2+, b
	neg	a
	mpyr	*ar2+, a
	masr	*ar2+, *ar4+, a
	mpyr	*ar2+, a
	squra	*ar2+, a
	exp	b
	masr	*ar2+, *ar4+, a
	ld	*ar2+, a
	nop
	exp	b
	stl	b, *ar7+
	delay	*ar2
	squra	*ar2+, a
	or	#0x0F0F, a
	mpy	*ar3+, *ar4+, a
	mpy	*ar2+, a
	ldr	*ar2+, a
	or	*ar2+, a
	sth	a, *ar6+
	squrs	*ar2+, a
	abs	a
	neg	b
	exp	b
	mpyr	*ar2+, a
	ldr	*ar2+, a
	sfta	a, -8
	macr	*ar3+, *ar4+, a
	add	a, b
	abs	a
	mpyr	*ar2+, a
	abs	a
	norm	b
	mpyr	*ar2+, a
	mac	*ar2+, a
	sfta	a, 8
	and	#0x00FF, b
	ror	a
	ror	a
	rol	a
	ldr	*ar2+, a
	sth	b, *ar7+
	and	*ar2+, a
	abs	a
	mac	*ar2+, a
	mar	*ar4+0%
	ltd	*ar3
	mar	*ar3-
	squrs	*ar2+, a
	ld	*ar3+, b
	xor	#0x5555, b
	mpy	*ar2+, a
	exp	b
	exp	b
	ld	*ar2+, a
	squr	*ar2+, a
	sftl	a, -8
	add	*ar3+, b
	ld	*ar4+, a
	stl	b, *ar7+
	macr	*ar2+, a
	mpy	*ar2+, a
	ldr	*ar2+, a
	norm	a
	stl	a, *ar6+
	mar	*ar4+0%
	mac	*ar2+, a
	ldu	*ar2+, b
	norm	b
	masr	*ar2+, *ar4+, a
	abs	a
	norm	a
	sfta	a, 4
	ldu	*ar2+, b
	ltd	*ar3
	mar	*ar2+
	mar	*ar3-
	sth	a, *ar5+
	or	#0xFF00, b
	squrs	*ar2+, a
	mac	*ar2+, a
	rol	b
	exp	b
	sub	b, a
	xor	*ar2+, a
	masr	*ar2+, *ar4+, a
	and	#0x00FF, b
	exp	b
	squrs	*ar2+, a
	xor	#0x5555, b
	squr	*ar2+, a
	norm	b
	masr	*ar2+, *ar4+, a
	stl	a, *ar6+
	ror	b
	sftl	a, -8
	sfta	a, -8
	or	*ar2+, a
	nop
	sth	a, *ar6+
	mar	*ar2+
	macr	*ar3+, *ar4+, a
	mpy	*ar2+, a
	add	*ar3+, b
	ld	*ar2+, a
	ror	a
	ldu	*ar2+, b
	ldu	*ar2+, b
	mpyr	*ar2+, a
	rol	a
	mpy	*ar3+, *ar4+, a
	mas	*ar3+, *ar4+, a
	add	*ar3+, b
	masr	*ar2+, *ar4+, a
	or	#0xFF00, b
	or	#0xFF00, b
	ldu	*ar2+, b
	ror	a
	delay	*ar2
	masr	*ar2+, *ar4+, a
	nop
	mpyr	*ar2+, a
	sth	b, *ar7+
	macr	*ar3+, *ar4+, a
	macr	*ar3+, *ar4+, a
	or	#0x0F0F, a
	add	#0x10, a
	mar	*ar2+
	ldr	*ar2+, a
	mpyr	*ar2+, a
	or	#0x0F0F, a
	norm	a
	nop
	nop
	neg	b
	mpyr	*ar2+, a
	abs	b
	nop
	ror	a
	squrs	*ar2+, a
	ldu	*ar2+, b
	sub	*ar2+, a
	ror	b
	mpyr	*ar2+, a
	delay	*ar2
	stl	b, *ar7+
	ltd	*ar3
	and	#0xF0F0, a
	neg	b
	ldr	*ar2+, a
	ldu	*ar2+, b
	squr	*ar2+, a
	norm	a
	masr	*ar2+, *ar4+, a
	mac	*ar2+, *ar3+, b
	and	#0xF0F0, a
	ror	a
	exp	b
	norm	b
	exp	b
	delay	*ar2
	ldr	*ar2+, a
	sftl	a, -8
	mar	*ar2+
	mar	*ar4+0%
	ltd	*ar3
	ldr	*ar2+, a
	mas	*ar2+, a
	sub	*ar2+, a
	ldu	*ar2+, b
	norm	b
	sth	a, *ar6+
	mpy	*ar3+, *ar4+, a
	ld	#0xFF00, b
	mpyu	*ar2+, a
	norm	b
	mpy	*ar3+, *ar4+, a
	sftl	a, -4
	delay	*ar2
	squrs	*ar2+, a
	masr	*ar2+, *ar4+, a
	ror	b
	sth	a, *ar6+
	mar	*ar4+0%
	masr	*ar2+, *ar4+, a
	exp	b
	squrs	*ar2+, a
	ldr	*ar2+, a
	sftl	b, 1
	rol	b
	stl	b, *ar7+
	sth	b, *ar7+
	ld	#0xFF00, b
	abs	a
	ror	a
	sub	*ar3+, b
	sub	*ar3+, b
	xor	#0x5555, b
	mpyr	*ar2+, a
	ldr	*ar2+, a
	ldr	*ar2+, a
	xor	#0x5555, b
	squra	*ar2+, a
	mpyr	*ar2+, a
	delay	*ar2
	sth	a, *ar6+
	nop
	sftl	a, 8
	xor	#0xAAAA, a
	sub	b, a
	mpyu	*ar2+, a
	exp	b
	xor	*ar2+, a
	and	*ar2+, a
	mac	*ar2+, *ar3+, b
	neg	a
	xor	*ar2+, a
	squrs	*ar2+, a
	squra	*ar2+, a
	mas	*ar2+, a
	mas	*ar3+, *ar4+, a
	mpy	*ar2+, a
	or	#0x0F0F, a
	mpyu	*ar2+, a
	delay	*ar2
	nop
	mac	*ar3+, *ar4+, a
	nop
	squrs	*ar2+, a
	masr	*ar2+, *ar4+, a
	mas	*ar2+, a
	squrs	*ar2+, a
	sftl	a, 4
	abs	b
	ltd	*ar3
	rol	b
	ldu	*ar2+, b
	and	*ar2+, a
	stl	a, *ar5+
	delay	*ar2
	stl	b, *ar7+
	rol	b
	ror	a
	macr	*ar2+, a
	neg	b
	mac	*ar2+, *ar3+, b
	mpyu	*ar2+, a
	add	a, b
	ld	*ar4+, a
	macr	*ar2+, a
	macr	*ar2+, a
	and	#0x00FF, b
	mac	*ar3+, *ar4+, a
	delay	*ar2
	exp	b
	abs	a
	squrs	*ar2+, a
	mpyu	*ar2+, a
	rol	a
	squrs	*ar2+, a
	rol	a
	mas	*ar2+, a
	nop
	squrs	*ar2+, a
	delay	*ar2
	ld	*ar3+, b
	ldu	*ar2+, b
	nop
	ror	b
	rol	a
	exp	b
	add	b, a
	ltd	*ar3
	exp	a
	squra	*ar2+, a
	xor	#0xAAAA, a
	stl	b, *ar7+
	ror	a
	macr	*ar2+, a
	rol	b
	ld	#0xFF00, b
; ====================================================================

	.global	_add_forms
	.global	_addc_addm_adds
	.global	_sub_forms
	.global	_mpy_forms
	.global	_mac_forms
	.global	_abs_neg_squr
	.global	_exp_norm_minmax_rnd
	.global	_lmem_arith
	.global	_ld_forms
	.global	_ldr_ldu_ldm
	.global	_st_forms
	.global	_move_family
	.global	_push_pop
	.global	_logic_forms
	.global	_shift_forms
	.global	_bit_ops
	.global	_compare_ops
	.global	_branch_forms
	.global	_call_forms
	.global	_banz_demo
	.global	_acc_branch_demo
	.global	_rc_demo
	.global	_return_variants
	.global	_repeat_forms
	.global	_xc_demo
	.global	_parallel_demo
	.global	_dsp_special
	.global	_sxxcd_demo
	.global	_io_forms
	.global	_status_demo
	.global	_misc_demo
	.global	_stress_00
	.global	_stress_01
	.global	_stress_02
	.global	_stress_03
	.global	_stress_04
	.global	_stress_05
	.global	_stress_06
	.global	_stress_07
	.global	_stress_08
	.global	_stress_09
	.global	_stress_10
	.global	_stress_11
	.global	_stress_12
	.global	_stress_13
	.global	_stress_14
	.global	_stress_15
	.global	_stress_16
	.global	_stress_17
	.global	_stress_18
	.global	_stress_19
	.global	_pipeline_init
	.global	_pipeline_fir_block
	.global	_pipeline_iir_block
	.global	_pipeline_compander
	.global	_jump_table
	.global	_micro_00
	.global	_micro_01
	.global	_micro_02
	.global	_micro_03
	.global	_micro_04
	.global	_micro_05
	.global	_micro_06
	.global	_micro_07
	.global	_micro_08
	.global	_micro_09
	.global	_micro_10
	.global	_micro_11
	.global	_micro_12
	.global	_micro_13
	.global	_micro_14
	.global	_micro_15
	.global	_micro_16
	.global	_micro_17
	.global	_micro_18
	.global	_micro_19
	.global	_micro_20
	.global	_micro_21
	.global	_micro_22
	.global	_micro_23
	.global	_micro_24
	.global	_micro_25
	.global	_micro_26
	.global	_micro_27
	.global	_micro_28
	.global	_micro_29
	.global	_micro_30
	.global	_micro_31
	.global	_micro_32
	.global	_micro_33
	.global	_micro_34
	.global	_micro_35
	.global	_micro_36
	.global	_micro_37
	.global	_micro_38
	.global	_micro_39
	.global	_dense_stream

	.global	_cond_aeq
	.global	_cond_aneq
	.global	_cond_agt
	.global	_cond_ageq
	.global	_cond_alt
	.global	_cond_aleq
	.global	_cond_aov
	.global	_cond_anov
	.global	_cond_beq
	.global	_cond_bneq
	.global	_cond_bgt
	.global	_cond_bgeq
	.global	_cond_blt
	.global	_cond_bleq
	.global	_cond_bov
	.global	_cond_bnov
	.global	_cond_tc
	.global	_cond_ntc
	.global	_cond_c
	.global	_cond_nc
	.global	_addrmode_00
	.global	_addrmode_01
	.global	_addrmode_02
	.global	_addrmode_03
	.global	_addrmode_04
	.global	_addrmode_05
	.global	_addrmode_06
	.global	_addrmode_07
	.global	_addrmode_08
	.global	_addrmode_09
	.global	_addrmode_10
	.global	_dense_huge
	.global	_macro_user
	.global	_macro_user2
	.global	_micro_040
	.global	_micro_041
	.global	_micro_042
	.global	_micro_043
	.global	_micro_044
	.global	_micro_045
	.global	_micro_046
	.global	_micro_047
	.global	_micro_048
	.global	_micro_049
	.global	_micro_050
	.global	_micro_051
	.global	_micro_052
	.global	_micro_053
	.global	_micro_054
	.global	_micro_055
	.global	_micro_056
	.global	_micro_057
	.global	_micro_058
	.global	_micro_059
	.global	_micro_060
	.global	_micro_061
	.global	_micro_062
	.global	_micro_063
	.global	_micro_064
	.global	_micro_065
	.global	_micro_066
	.global	_micro_067
	.global	_micro_068
	.global	_micro_069
	.global	_micro_070
	.global	_micro_071
	.global	_micro_072
	.global	_micro_073
	.global	_micro_074
	.global	_micro_075
	.global	_micro_076
	.global	_micro_077
	.global	_micro_078
	.global	_micro_079
	.global	_micro_080
	.global	_micro_081
	.global	_micro_082
	.global	_micro_083
	.global	_micro_084
	.global	_micro_085
	.global	_micro_086
	.global	_micro_087
	.global	_micro_088
	.global	_micro_089
	.global	_micro_090
	.global	_micro_091
	.global	_micro_092
	.global	_micro_093
	.global	_micro_094
	.global	_micro_095
	.global	_micro_096
	.global	_micro_097
	.global	_micro_098
	.global	_micro_099
	.global	_micro_100
	.global	_micro_101
	.global	_micro_102
	.global	_micro_103
	.global	_micro_104
	.global	_micro_105
	.global	_micro_106
	.global	_micro_107
	.global	_micro_108
	.global	_micro_109
	.global	_micro_110
	.global	_micro_111
	.global	_micro_112
	.global	_micro_113
	.global	_micro_114
	.global	_micro_115
	.global	_micro_116
	.global	_micro_117
	.global	_micro_118
	.global	_micro_119
	.global	_micro_120
	.global	_micro_121
	.global	_micro_122
	.global	_micro_123
	.global	_micro_124
	.global	_micro_125
	.global	_micro_126
	.global	_micro_127
	.global	_micro_128
	.global	_micro_129
	.global	_micro_130
	.global	_micro_131
	.global	_micro_132
	.global	_micro_133
	.global	_micro_134
	.global	_micro_135
	.global	_micro_136
	.global	_micro_137
	.global	_micro_138
	.global	_micro_139
	.global	_micro_140
	.global	_micro_141
	.global	_micro_142
	.global	_micro_143
	.global	_micro_144
	.global	_micro_145
	.global	_micro_146
	.global	_micro_147
	.global	_micro_148
	.global	_micro_149
	.global	_micro_150
	.global	_micro_151
	.global	_micro_152
	.global	_micro_153
	.global	_micro_154
	.global	_micro_155
	.global	_micro_156
	.global	_micro_157
	.global	_micro_158
	.global	_micro_159
	.global	_micro_160
	.global	_micro_161
	.global	_micro_162
	.global	_micro_163
	.global	_micro_164
	.global	_micro_165
	.global	_micro_166
	.global	_micro_167
	.global	_micro_168
	.global	_micro_169
	.global	_micro_170
	.global	_micro_171
	.global	_micro_172
	.global	_micro_173
	.global	_micro_174
	.global	_micro_175
	.global	_micro_176
	.global	_micro_177
	.global	_micro_178
	.global	_micro_179
	.global	_micro_180
	.global	_micro_181
	.global	_micro_182
	.global	_micro_183
	.global	_micro_184
	.global	_micro_185
	.global	_micro_186
	.global	_micro_187
	.global	_micro_188
	.global	_micro_189
	.global	_micro_190
	.global	_micro_191
	.global	_micro_192
	.global	_micro_193
	.global	_micro_194
	.global	_micro_195
	.global	_micro_196
	.global	_micro_197
	.global	_micro_198
	.global	_micro_199
	.global	_dense_super
	.end
