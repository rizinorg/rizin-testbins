; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
;
; 04_fir_filter.asm -- TMS320C2x FIR / dot-product kernel.
;
; The canonical DSP MAC chain on the single-accumulator C2x: an 8-tap dot
; product y = sum(h[i] * x[i]) computed with the LT / MPY / LTA / APAC idiom and
; indirect post-increment addressing through AR2 (samples) and AR3 (coeffs).
;
; x = {1,2,3,4,5,6,7,8}, h = {8,7,6,5,4,3,2,1}
; y = 8+14+18+20+20+18+14+8 = 120 = 0x78
;
        .org 0
        ldpk 6              ; data page base word 0x300

        ; samples x[0..7] at 0x300..0x307
        lack 1
        sacl 0
        lack 2
        sacl 1
        lack 3
        sacl 2
        lack 4
        sacl 3
        lack 5
        sacl 4
        lack 6
        sacl 5
        lack 7
        sacl 6
        lack 8
        sacl 7
        ; coeffs h[0..7] at 0x308..0x30F
        lack 8
        sacl 8
        lack 7
        sacl 9
        lack 6
        sacl 10
        lack 5
        sacl 11
        lack 4
        sacl 12
        lack 3
        sacl 13
        lack 2
        sacl 14
        lack 1
        sacl 15

        ; dot product
        larp 2
        lrlk 2, 0x300       ; AR2 -> x[]
        lrlk 3, 0x308       ; AR3 -> h[]
        zac
        lt *+, 3            ; T = x0 ; ARP -> AR3
        mpy *+, 2           ; P = x0*h0 ; ARP -> AR2
        lta *+, 3           ; ACC += P ; T = x1 ; ARP -> AR3
        mpy *+, 2           ; P = x1*h1
        lta *+, 3
        mpy *+, 2
        lta *+, 3
        mpy *+, 2
        lta *+, 3
        mpy *+, 2
        lta *+, 3
        mpy *+, 2
        lta *+, 3
        mpy *+, 2
        lta *+, 3
        mpy *+, 2
        apac                ; final accumulate -> ACC = 120
        ldpk 6
        sacl 16             ; store result word

        idle
