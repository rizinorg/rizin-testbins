; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
;
; TMS320C2x RzIL emulation exerciser.
;
; A self-contained program that drives the RzIL virtual machine through loops,
; a multiply-accumulate chain, a buffer transformation, a subroutine call and
; the data/stack memory model, so the emulateme test can assert a rich final
; state rather than a single scalar. All data lives on page 6 (DP=6, word base
; 0x300) which the test reads back at byte address 0x600 onward. The program
; ends in a one-instruction self-loop so the VM settles on a stable state that
; the test reaches with "aezsu".
;
; Computed results (data page 6):
;   0x310  sum of x[]                = 0x001f
;   0x311  sum of squares of x[]     = 0x00ad   (high word at 0x312 = 0)
;   0x313  2 * sum, via subroutine   = 0x003e
;   0x314  logic/shift fold of sumsq = 0x010f
;   0x318..0x31f  x[i] ^ 0x5a        = 59 5b 5e 5b 5f 53 58 5c

        .org 0
start:
        ldpk 6

; Initialise x[0..7] = {3,1,4,1,5,9,2,6} at page offset 0 using AR1 with
; post-increment indirect stores.
        lrlk 1, 0x300
        larp 1
        lack 3
        sacl *+
        lack 1
        sacl *+
        lack 4
        sacl *+
        lack 1
        sacl *+
        lack 5
        sacl *+
        lack 9
        sacl *+
        lack 2
        sacl *+
        lack 6
        sacl *+

; Accumulate the array with a BANZ-controlled loop. AR1 walks x[], AR4 is the
; loop counter; the running total is kept in memory at offset 0x10.
        lrlk 1, 0x300
        lrlk 4, 7
        zac
        sacl 0x10
sloop:
        larp 1
        lac *+, 0
        add 0x10
        sacl 0x10
        larp 4
        banz sloop, *-

; Sum of squares through a multiply-accumulate chain: LT/MPY load the product
; register and APAC folds it into the accumulator each iteration.
        lrlk 1, 0x300
        lrlk 4, 7
        zac
        sacl 0x11
qloop:
        larp 1
        lt *, 0
        mpy *+
        apac
        larp 4
        banz qloop, *-
        sach 0x12
        sacl 0x11

; Buffer transform: XOR every element of x[] with 0x5a and write the result to
; a second array at offset 0x18, walking source and destination with AR1/AR2.
        lrlk 1, 0x300
        lrlk 2, 0x318
        lrlk 4, 7
xloop:
        larp 1
        lac *+, 0
        xork 0x5a
        larp 2
        sacl *+
        larp 4
        banz xloop, *-

; Call a subroutine that doubles the accumulator. The call and return exercise
; the stack model, and the subroutine itself pushes and pops the accumulator.
        lac 0x10, 0
        call dbl
        sacl 0x13

; Fold the sum of squares through a chain of logical and shift operations.
        lac 0x11, 0
        andk 0xff
        sfl
        ork 0x100
        xork 0x55
        sacl 0x14

; Settle on a stable state for the test to observe.
done:
        b done

; Doubling subroutine: save and restore the accumulator across a shift-left.
dbl:
        push
        pop
        sfl
        ret
