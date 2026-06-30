; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
;
; 01_arithmetic.asm -- TMS320C2x arithmetic and load/store coverage.
;
; Ported in spirit from the C54x coff1/01_arithmetic.s, re-expressed for the
; single-accumulator C2x: ADD/SUB with shifts and the H/S/T/C variants, the
; ADDK/SUBK/ADLK/SBLK/LALK immediates, ABS/NEG, the LT/MPY/PAC product chain
; and direct + indirect (post-modify) data addressing.
;
; Computes  ((5 + 3) << 1) - |0 - 7| + (6 * 7)  and leaves it in a scratch word,
; touching every arithmetic addressing form on the way.  Data lives on page 4
; (word base 0x200) to stay clear of the program image.
;
        .org 0
        ldpk 4              ; DP = 4  -> data page base word 0x200

        ; seed a few data words
        lalk 7, 0
        sacl 0              ; mem[0x200] = 7
        lalk 6, 0
        sacl 1              ; mem[0x201] = 6
        lalk 0x55, 0
        sacl 2              ; mem[0x202] = 0x55

        ; accumulator immediates and shifts
        lack 5
        addk 3              ; ACC = 8
        sfl                 ; ACC = 16
        sacl 3              ; mem[0x203] = 16

        ; subtract with |.| via ABS
        zac
        sub 0               ; ACC = -7
        abs                 ; ACC = 7
        neg                 ; ACC = -7
        abs                 ; ACC = 7
        sacl 4

        ; long immediates
        lalk 0x1234, 0
        adlk 0x0100, 0      ; ACC = 0x1334
        sblk 0x0034, 0      ; ACC = 0x1300
        andk 0x0F00, 0      ; ACC = 0x0300
        sacl 5

        ; product chain: P = 6 * 7, accumulate
        lt 1                ; T = 6
        mpy 0               ; P = 6 * 7 = 42
        pac                 ; ACC = 42
        apac                ; ACC = 84
        spac                ; ACC = 42
        sacl 6

        ; indirect addressing with post-increment
        larp 2
        lrlk 2, 0x210
        lack 0x11
        sacl *+, 0          ; mem[0x210] = 0x11 ; AR2 -> 0x211
        lack 0x22
        sacl *, 0           ; mem[0x211] = 0x22
        lrlk 2, 0x210
        zac
        add *+, 0           ; ACC += 0x11
        add *, 0            ; ACC += 0x22  -> ACC = 0x33
        sacl 7

        idle
