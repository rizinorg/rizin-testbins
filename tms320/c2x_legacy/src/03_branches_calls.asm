; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
;
; 03_branches_calls.asm -- TMS320C2x control-flow coverage.
;
; The conditional-branch set (BZ/BNZ/BGZ/BLEZ/BGEZ/BLZ/BV/BNV/BC/BNC), an
; unconditional B, and a CALL/RET pair exercising the (synthetic) stack.  The
; program walks a short decision tree and a subroutine, ending with a known ACC.
;
        .org 0
        ldpk 4

        ; subroutine call: add5 adds 5 to ACC
        lack 10
        call add5           ; ACC = 15
        sacl 0

        ; conditional branch on sign
        zac
        sub 0               ; ACC = -15  (mem[0] = 15)
        blz neg_path        ; taken (ACC < 0)
        lack 0xEE           ; (skipped)
        b done_sign
neg_path:
        lack 0x42           ; ACC = 0x42
done_sign:
        sacl 1

        ; BZ / BNZ
        zac
        bz  was_zero        ; taken
        lack 0xFF
was_zero:
        lack 0x7
        bnz nonzero         ; taken
        lack 0xFF
nonzero:
        sacl 2

        ; carry-based branch
        lalk 0xFFFF, 1      ; ACC = 0xFFFE
        addk 2              ; overflow into carry; ACC = 0x10000
        bc  had_carry       ; taken
        lack 0xAA
        b after_c
had_carry:
        lack 0x5A
after_c:
        sacl 3

        idle

; add5: ACC += 5 ; return
add5:
        addk 5
        ret
