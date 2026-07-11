; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
;
; 02_logic_shifts.asm -- TMS320C2x logical and shift/rotate coverage.
;
; AND/OR/XOR with memory, the ANDK/ORK/XORK long-immediate forms, the
; SFL/SFR/ROL/ROR shifters (carry in/out), CMPL, and the T-controlled shifts
; LACT/ADDT.  Builds a value through a sequence of bit operations.
;
        .org 0
        ldpk 4

        lalk 0x0F0F, 0
        sacl 0              ; mem = 0x0F0F
        lalk 0x00FF, 0
        sacl 1
        lalk 0x3300, 0
        sacl 2

        lalk 0xF0F0, 0
        and 0               ; ACC = 0xF0F0 & 0x0F0F = 0
        or 2                ; ACC = 0x3300
        xor 0               ; ACC = 0x3300 ^ 0x0F0F = 0x3C0F
        sacl 3

        ; immediate logicals
        lack 0
        ork 0xFF00, 0       ; ACC = 0xFF00
        andk 0x0FF0, 0      ; ACC = 0x0F00
        xork 0x00F0, 0      ; ACC = 0x0FF0
        cmpl                ; ACC = ~0x0FF0 = 0xFFFFF00F
        sacl 4

        ; shifts and rotates through carry
        sc                  ; C = 1
        lack 1
        rol                 ; ACC = 3 (carry into bit0), C = 0
        rol                 ; ACC = 6
        sfl                 ; ACC = 12
        sfr                 ; ACC = 6
        ror                 ; rotate right through carry
        sacl 5

        ; T-controlled shift (LACT shifts by T[3:0])
        lalk 4, 0
        sacl 6
        lt 6                ; T = 4
        lalk 0x0003, 0
        sacl 7
        lact 7              ; ACC = mem[7] << (T & 0xf) = 3 << 4 = 0x30
        sacl 8

        idle
