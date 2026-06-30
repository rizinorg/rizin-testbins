; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
;
; 10_full_program.asm -- a complete small TMS320C2x routine.
;
; Combines the categories: it sums an array (with a CALL'd helper), scales the
; sum, runs a 3-tap MAC, applies a saturating add under OVM, stores results
; through indirect addressing, and finishes at IDLE.  A realistic mixed-workload
; image for the disassembler, analysis and the RzIL VM.
;
        .org 0
        ldpk 6              ; data base word 0x300

        ; build an array a[0..3] = {10,20,30,40}
        lack 10
        sacl 0
        lack 20
        sacl 1
        lack 30
        sacl 2
        lack 40
        sacl 3

        ; sum = a[0]+a[1]+a[2]+a[3] via straight adds
        zac
        add 0
        add 1
        add 2
        add 3               ; ACC = 100
        sacl 4              ; sum

        ; scale: sum << 1
        sfl                 ; ACC = 200
        sacl 5

        ; 3-tap MAC: c={2,3,4} . a[0..2]
        lack 2
        sacl 8
        lack 3
        sacl 9
        lack 4
        sacl 10
        larp 2
        lrlk 2, 0x300       ; AR2 -> a[]
        lrlk 3, 0x308       ; AR3 -> c[]
        zac
        lt *+, 3
        mpy *+, 2
        lta *+, 3
        mpy *+, 2
        lta *+, 3
        mpy *+, 2
        apac                ; ACC = 2*10+3*20+4*30 = 200
        ldpk 6
        sacl 6

        ; saturating add under OVM
        sovm
        lalk 0x7FFF, 16     ; ACC near +max
        adlk 0x7FFF, 0
        addk 1              ; would overflow -> saturates to 0x7FFFFFFF
        rovm
        sach 7              ; high word of saturated result

        ; store a marker through indirect
        larp 4
        lrlk 4, 0x320
        lack 0x5A
        sacl *+, 0
        sach *, 0

        idle
