; SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
; SPDX-License-Identifier: LGPL-3.0-only
;
; 05_status_data.asm -- TMS320C2x status, data-move and table coverage.
;
; The status register save/restore pair (SST/LST and SST1/LST1), the mode bits
; (SOVM/ROVM, SSXM/RSXM, SPM, SC/RC, STC/RTC), the DMOV data shift, and the
; ZALH/ZALS/ZALR accumulator loads.  Demonstrates that the modelled status bits
; round-trip through memory.
;
        .org 0
        ldpk 0              ; DP = 0 so SST page-0 and LST addressing agree

        ; set a distinctive mode/flag state
        sovm                ; OVM = 1
        ssxm                ; SXM = 1
        spm 2               ; PM = 2
        stc                 ; TC = 1
        larp 3              ; ARP = 3

        sst  0x40           ; store ST0 (ARP, OVM, ...) to page-0 0x40
        sst1 0x41           ; store ST1 (TC, SXM, PM, ...) to page-0 0x41

        ; clobber the state
        rovm
        rsxm
        spm 0
        rtc
        larp 0

        ; restore
        lst  0x40           ; ARP, OVM, DP <- mem
        lst1 0x41           ; TC, SXM, PM, C, ARP <- mem

        ; accumulator high/low loads
        ldpk 6
        lalk 0x1234, 0
        sacl 0              ; mem = 0x1234
        zalh 0              ; ACC = 0x1234 << 16
        zals 0              ; ACC = 0x00001234
        zalr 0              ; ACC = (0x1234<<16)|0x8000
        sach 1
        sacl 2

        ; DMOV: mem[ea+1] = mem[ea]
        lack 0x5A
        sacl 3
        dmov 3              ; mem[4] = mem[3]
        idle
