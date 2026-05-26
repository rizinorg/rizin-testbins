;
; 07_compiler_style.s — Mimics output of TI's cl500 C compiler.
;
; assemble with:
;   tic54x-coff-as -o 07_compiler_style.o 07_compiler_style.s
;
; This file is hand-written but follows the conventions cl500 4.2.0
; (the C5400 family Code Generation Tools shipped with CCSv5)
; actually emits, as observed by disassembling a real compiled .coff:
;
;   - Symbols are leading-underscored (`_func` for C `func`)
;   - Branch labels look like `$C$L1`, `$C$L2`, ... globally numbered
;   - DWARF lexical-block labels: `$C$DW$L$_funcname$N$B/$E` pairs
;   - String literals: `$C$SL1`, `$C$SL2`, ... in .const
;   - Function prologue (with locals):
;         pshm  ar1               ; save caller fp
;         frame #-N                ; reserve N words on stack
;         stlm  a, ar1             ; stash first arg-or-fp via A.lo
;   - Function epilogue:
;         frame #N
;         popm  ar1
;         ret
;   - Leaf-style (no locals): pshm ar1 / body / popm ar1 / ret
;   - DP-relative locals: dld DP+0x00, b  /  dst b, DP+0x00 etc.
;   - 32-bit globals accessed via *(addr) absolute-direct
;   - Lots of nops (0xF495) scattered for pipeline scheduling
;
	.mmregs

; .bss for uninitialized C globals
	.bss	_count,    1
	.bss	_table,    8

; .const for read-only initialized data
	.sect	".const"

$C$SL1:	.byte	"Hello, C54x!", 0
$C$SL2:	.word	1, 2, 3, 4, 5, 6, 7, 8

	.global	_square
	.global	_abs_val
	.global	_clamp
	.global	_sum_array
	.global	_increment_all
	.global	_factorial
	.global	_init_table
	.global	_main

	.text

;----------------------------------------------------------------------
; int square(int x)
;   x in A on entry. Returns x*x in A. Leaf — no frame.
;----------------------------------------------------------------------
_square:
	stlm	a, t			; T = x (compiler uses STLM to set T)
	mpy	t, a			; A = T * T  (signed)
	ret

;----------------------------------------------------------------------
; int abs_val(int x)
;   x in A. Returns |x| in A. Leaf.
;----------------------------------------------------------------------
_abs_val:
	abs	a			; A = |A|
	ret

;----------------------------------------------------------------------
; int clamp(int x, int lo, int hi)
;   x in A; lo, hi on stack at *+ar1(2), *+ar1(3)
;----------------------------------------------------------------------
_clamp:
	pshm	ar1
	frame	#-1
	stlm	a, ar1			; save x
	; if (x < lo) goto $C$L1
	ldm	ar1, a
	sub	*+ar1(2), a
	bcd	$C$L1, AGEQ
	nop
	ldm	ar1, a
	ld	*+ar1(2), a
	b	$C$L2
$C$L1:
	; if (x > hi) return hi
	ldm	ar1, a
	sub	*+ar1(3), a
	bcd	$C$L2, ALEQ
	nop
	ldm	ar1, a
	ld	*+ar1(3), a
$C$L2:
	frame	#1
	popm	ar1
	ret

;----------------------------------------------------------------------
; int sum_array(int *p, int n)
;   p in AR2, n in A. Returns sum in A.
;----------------------------------------------------------------------
_sum_array:
	pshm	ar1
	frame	#-2
	stlm	a, ar1
	nop				; pipeline scheduling
	ldm	ar1, b
	sub	#1, b
	bc	$C$L4, BLT
	stlm	b, brc
	ld	#0, a
	rptb	$C$L3-1
	add	*ar2+, a
$C$L3:
$C$L4:
	frame	#2
	popm	ar1
	ret

;----------------------------------------------------------------------
; void increment_all(int *p, int n)
;----------------------------------------------------------------------
_increment_all:
	pshm	ar1
	frame	#-1
	stlm	a, ar1
	nop
	ldm	ar1, b
	sub	#1, b
	bc	$C$L6, BLT
	stlm	b, brc
	rptb	$C$L5-1
	ld	*ar2, a
	add	#1, a
	stl	a, *ar2+
$C$L5:
$C$L6:
	frame	#1
	popm	ar1
	ret

;----------------------------------------------------------------------
; int factorial(int n) — recursive
;----------------------------------------------------------------------
_factorial:
	pshm	ar1
	frame	#-2
	stlm	a, ar1
	nop
	ldm	ar1, a
	sub	#2, a
	bcd	$C$L7, ALT
	nop
	ld	#1, a
	b	$C$L8
$C$L7:
	ldm	ar1, a
	sub	#1, a
	call	_factorial
	stl	a, *+ar1(1)
	ldm	ar1, a
	stlm	a, t
	mpy	*+ar1(1), a
$C$L8:
	frame	#2
	popm	ar1
	ret

;----------------------------------------------------------------------
; void init_table(void)
;----------------------------------------------------------------------
_init_table:
	pshm	ar1
	nop
	stm	#_table, ar2
	stm	#$C$SL2, ar3
	stm	#7, brc
	rptb	$C$L9-1
	mvdd	*ar3+, *ar2+
$C$L9:
	popm	ar1
	ret

;----------------------------------------------------------------------
; int main(void)
;----------------------------------------------------------------------
_main:
	pshm	ar1
	frame	#-4
	stm	#0, ar1
	call	_init_table
	ld	#5, a
	call	_square
	stl	a, *+ar1(1)
	ld	#-7, a
	call	_abs_val
	add	*+ar1(1), a
	stl	a, *+ar1(2)
	stm	#_table, ar2
	ld	#8, a
	call	_sum_array
	add	*+ar1(2), a
	stl	a, *+ar1(3)
	ld	#5, a
	call	_factorial
	add	*+ar1(3), a
	stl	a, @_count
	ld	#0, a
	frame	#4
	popm	ar1
	ret

	.end
