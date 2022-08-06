# SPDX-FileCopyrightText: 2022 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.global max_sw_into_r28
.global max_sh_into_r28
.global max_sb_into_r28
.global max_uw_into_r28
.global max_uh_into_r28
.global max_ub_into_r28
.global min_sw_into_r27
.global min_sh_into_r27
.global min_uw_into_r27
.global min_uh_into_r27
.global min_ub_into_r27
.global store_regs
.global load_regs

.type max_sw_into_r28, @function
.type max_sh_into_r28, @function
.type max_sb_into_r28, @function
.type max_uw_into_r28, @function
.type max_uh_into_r28, @function
.type max_ub_into_r28, @function
.type min_sw_into_r27, @function
.type min_sh_into_r27, @function
.type min_uw_into_r27, @function
.type min_uh_into_r27, @function
.type min_ub_into_r27, @function
.type store_regs, @function
.type load_regs, @function

# Helper max (un)signed into r28

max_sw_into_r28:
    lis r20, max_sw@ha
    la r20, max_sw@l(r20)
    lwz r28, 0(r20)
    blr

max_sh_into_r28:
    lis r20, max_sh@ha
    la r20, max_sh@l(r20)
    lha r28, 0(r20)
    blr

max_sb_into_r28:
    lis r20, max_sb@ha
    la r20, max_sb@l(r20)
    lbz r28, 0(r20)
    blr

max_uw_into_r28:
    lis r20, max_uw@ha
    la r20, max_uw@l(r20)
    lwz r28, 0(r20)
    blr

max_uh_into_r28:
    lis r20, max_uh@ha
    la r20, max_uh@l(r20)
    lhz r28, 0(r20)
    blr

max_ub_into_r28:
    lis r20, max_ub@ha
    la r20, max_ub@l(r20)
    lbz r28, 0(r20)
    blr

# Helper min (un)signed into r27

min_sw_into_r27:
    lis r20, min_sw@ha
    la r20, min_sw@l(r20)
    lwz r27, 0(r20)
    blr

min_sh_into_r27:
    lis r20, min_sh@ha
    la r20, min_sh@l(r20)
    lha r27, 0(r20)
    blr

min_sb_into_r27:
    lis r20, min_sb@ha
    la r20, min_sb@l(r20)
    lbz r27, 0(r20)
    blr

min_uw_into_r27:
    lis r20, min_uw@ha
    la r20, min_uw@l(r20)
    lwz r27, 0(r20)
    blr

min_uh_into_r27:
    lis r20, min_uh@ha
    la r20, min_uh@l(r20)
    lhz r27, 0(r20)
    blr

min_ub_into_r27:
    lis r20, min_ub@ha
    la r20, min_ub@l(r20)
    lbz r27, 0(r20)
    blr

minus_one_into_r11:
    addis r11, 0, -1          # r11 = 0xffff0000
    addi  r11, 0, -1          # r11 = -1
    blr

store_regs:
    lis r4, reg_file@ha
    la r4, reg_file@l(r4)

    stw r0,  0x00(r4)
    stw r2,  0x10(r4)
    stw r3,  0x20(r4)
    stw r4,  0x30(r4)
    stw r5,  0x40(r4)
    stw r6,  0x50(r4)
    stw r7,  0x60(r4)
    stw r8,  0x70(r4)
    stw r9,  0x80(r4)
    stw r10, 0x90(r4)
    stw r11, 0xa0(r4)
    stw r12, 0xb0(r4)
    stw r13, 0xc0(r4)
    stw r14, 0xd0(r4)
    stw r15, 0xe0(r4)
    stw r16, 0xf0(r4)
    stw r17, 0x100(r4)
    stw r19, 0x110(r4)
    stw r20, 0x120(r4)
    stw r21, 0x130(r4)
    stw r22, 0x140(r4)
    stw r23, 0x150(r4)
    stw r24, 0x160(r4)
    stw r25, 0x170(r4)
    stw r26, 0x180(r4)
    stw r27, 0x190(r4)
    stw r28, 0x1a0(r4)
    stw r29, 0x1b0(r4)
    stw r30, 0x1c0(r4)
    stw r31, 0x200(r4)

    blr

load_regs:
    lis r4, reg_file@ha
    la r4, reg_file@l(r4)

    lwz r0,  0x00(r4)
    lwz r2,  0x10(r4)
    lwz r3,  0x20(r4)
    lwz r4,  0x30(r4)
    lwz r5,  0x40(r4)
    lwz r6,  0x50(r4)
    lwz r7,  0x60(r4)
    lwz r8,  0x70(r4)
    lwz r9,  0x80(r4)
    lwz r10, 0x90(r4)
    lwz r11, 0xa0(r4)
    lwz r12, 0xb0(r4)
    lwz r13, 0xc0(r4)
    lwz r14, 0xd0(r4)
    lwz r15, 0xe0(r4)
    lwz r16, 0xf0(r4)
    lwz r17, 0x100(r4)
    lwz r19, 0x110(r4)
    lwz r20, 0x120(r4)
    lwz r21, 0x130(r4)
    lwz r22, 0x140(r4)
    lwz r23, 0x150(r4)
    lwz r24, 0x160(r4)
    lwz r25, 0x170(r4)
    lwz r26, 0x180(r4)
    lwz r27, 0x190(r4)
    lwz r28, 0x1a0(r4)
    lwz r29, 0x1b0(r4)
    lwz r30, 0x1c0(r4)
    lwz r31, 0x200(r4)

    blr
