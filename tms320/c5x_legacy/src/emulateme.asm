; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
;
; emulateme.asm -- TMS320C5x (real C5x object encoding) RzIL emulation exerciser.
;
; The C5x counterpart of the C2x exerciser: it drives the Rizin RzIL virtual
; machine through BANZ loops, a multiply-accumulate chain, a buffer transform,
; a subroutine call and the data/stack memory model. Data lives on page 6
; (DP=6, word base 0x300), read back by the test at byte address 0x600 onward.
; Branch operands are word addresses; the loop labels are noted in comments.
; The program ends in a self-loop so the VM settles on a stable state reached
; with "aezsu". Assembled by tms320-rs assembler with label resolution.
;
; Computed results (data page 6):
;   0x310  sum of x[]                = 0x001f
;   0x311  sum of squares of x[]     = 0x00ad   (high word at 0x312 = 0)
;   0x313  2 * sum, via subroutine   = 0x003e
;   0x314  logic/shift fold of sumsq = 0x010f
;   0x318..0x31f  x[i] ^ 0x5a        = 59 5b 5e 5b 5f 53 58 5c

	ldp #0x6

; Initialise x[0..7] = {3,1,4,1,5,9,2,6} via AR1 with post-increment stores.
	lar ar1, #0x300
	mar *, ar1
	lacl #0x3
	sacl *+
	lacl #0x1
	sacl *+
	lacl #0x4
	sacl *+
	lacl #0x1
	sacl *+
	lacl #0x5
	sacl *+
	lacl #0x9
	sacl *+
	lacl #0x2
	sacl *+
	lacl #0x6
	sacl *+

; Accumulate the array with a BANZ loop (sloop at word 0x1a). AR1 walks x[],
; AR4 counts down, the running total is kept at offset 0x10.
	lar ar1, #0x300
	lar ar4, #0x7
	lacl #0x0
	sacl 0x10
	mar *, ar4
	mar *, ar1
	lacc *+
	add 0x10
	sacl 0x10
	mar *, ar4
	banz 0x1a, *-

; Sum of squares through a multiply-accumulate chain (qloop at word 0x26):
; LT/MPY build the product and APAC folds it into the accumulator each pass.
	lar ar1, #0x300
	lar ar4, #0x7
	lacl #0x0
	mar *, ar4
	mar *, ar1
	lt *
	mpy *+
	apac
	mar *, ar4
	banz 0x26, *-
	sach 0x12
	sacl 0x11

; Buffer transform (xloop at word 0x35): XOR every x[] element with 0x5a and
; store the result to a second array at offset 0x18 via AR1/AR2.
	lar ar1, #0x300
	lar ar2, #0x318
	lar ar4, #0x7
	mar *, ar4
	mar *, ar1
	lacc *+
	xor #0x5a
	mar *, ar2
	sacl *+
	mar *, ar4
	banz 0x35, *-

; Call a subroutine (dbl at word 0x4d) that doubles the accumulator; the call,
; the return and the push/pop inside exercise the stack model.
	lacc 0x10
	call 0x4d
	sacl 0x13

; Fold the sum of squares through logical and shift operations.
	lacc 0x11
	and #0xff
	sfl
	or #0x100
	xor #0x55
	sacl 0x14

; Settle on a stable state for the test to observe (done at word 0x4b).
	b 0x4b

; Doubling subroutine: save and restore the accumulator across a shift-left.
	push
	pop
	sfl
	ret
