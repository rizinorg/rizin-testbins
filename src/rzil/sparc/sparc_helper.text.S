# SPDX-FileCopyrightText: 2025 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.global max_sd_into_o5
.global max_sw_into_o5
.global max_sh_into_o5
.global max_sb_into_o5
.global max_ud_into_o5
.global max_uw_into_o5
.global max_uh_into_o5
.global max_ub_into_o5
.global min_sd_into_o5
.global min_sw_into_o5
.global min_sh_into_o5
.global min_sb_into_o5
.global min_ud_into_o5
.global min_uw_into_o5
.global min_uh_into_o5
.global min_ub_into_o5
.global store_regs
.global load_regs
.global fill_regs_with_data

.type max_sd_into_o5, @function
.type max_sw_into_o5, @function
.type max_sh_into_o5, @function
.type max_sb_into_o5, @function
.type max_ud_into_o5, @function
.type max_uw_into_o5, @function
.type max_uh_into_o5, @function
.type max_ub_into_o5, @function
.type min_sd_into_o5, @function
.type min_sw_into_o5, @function
.type min_sh_into_o5, @function
.type min_sb_into_o5, @function
.type min_ud_into_o5, @function
.type min_uw_into_o5, @function
.type min_uh_into_o5, @function
.type min_ub_into_o5, @function
.type store_regs, @function
.type load_regs, @function
.type fill_regs_with_data, @function

# Helper max (un)signed into callers o5

max_sd_into_o5:
    ldx max_sd, o5
    return

max_sw_into_o5:
    lis r20, max_sw@ha
    la r20, max_sw@l(r20)
    lwa r28, 0(r20)
    blr

max_sh_into_o5:
    lis r20, max_sh@ha
    la r20, max_sh@l(r20)
    lha r28, 0(r20)
    blr

max_sb_into_o5:
    lis r20, max_sb@ha
    la r20, max_sb@l(r20)
    lbz r28, 0(r20)
    blr

max_ud_into_o5:
    lis r20, max_ud@ha
    la r20, max_ud@l(r20)
    ld r28, 0(r20)
    blr

max_uw_into_o5:
    lis r20, max_uw@ha
    la r20, max_uw@l(r20)
    lwz r28, 0(r20)
    blr

max_uh_into_o5:
    lis r20, max_uh@ha
    la r20, max_uh@l(r20)
    lhz r28, 0(r20)
    blr

max_ub_into_o5:
    lis r20, max_ub@ha
    la r20, max_ub@l(r20)
    lbz r28, 0(r20)
    blr

# Helper min (un)signed into r27

min_sd_into_o5:
    lis r20, min_sd@ha
    la r20, min_sd@l(r20)
    ld r27, 0(r20)
    blr

min_sw_into_o5:
    lis r20, min_sw@ha
    la r20, min_sw@l(r20)
    lwa r27, 0(r20)
    blr

min_sh_into_o5:
    lis r20, min_sh@ha
    la r20, min_sh@l(r20)
    lha r27, 0(r20)
    blr

min_sb_into_o5:
    lis r20, min_sb@ha
    la r20, min_sb@l(r20)
    lbz r27, 0(r20)
    blr

min_ud_into_o5:
    lis r20, min_ud@ha
    la r20, min_ud@l(r20)
    ld r27, 0(r20)
    blr

min_uw_into_o5:
    lis r20, min_uw@ha
    la r20, min_uw@l(r20)
    lwz r27, 0(r20)
    blr

min_uh_into_o5:
    lis r20, min_uh@ha
    la r20, min_uh@l(r20)
    lhz r27, 0(r20)
    blr

min_ub_into_o5:
    lis r20, min_ub@ha
    la r20, min_ub@l(r20)
    lbz r27, 0(r20)
    blr

minus_one_into_o5:
    addis r11, 0, -1          # r11 = 0xffff0000
    addi  r11, 0, -1          # r11 = -1
    blr

store_regs:
    lis r4, reg_file@ha
    la r4, reg_file@l(r4)

    std r0,  0x00(r4)
    std r2,  0x10(r4)
    std r3,  0x20(r4)
    std r4,  0x30(r4)
    std r5,  0x40(r4)
    std r6,  0x50(r4)
    std r7,  0x60(r4)
    std r8,  0x70(r4)
    std r9,  0x80(r4)
    std r10, 0x90(r4)
    std r11, 0xa0(r4)
    std r12, 0xb0(r4)
    std r13, 0xc0(r4)
    std r14, 0xd0(r4)
    std r15, 0xe0(r4)
    std r16, 0xf0(r4)
    std r17, 0x100(r4)
    std r19, 0x110(r4)
    std r20, 0x120(r4)
    std r21, 0x130(r4)
    std r22, 0x140(r4)
    std r23, 0x150(r4)
    std r24, 0x160(r4)
    std r25, 0x170(r4)
    std r26, 0x180(r4)
    std r27, 0x190(r4)
    std r28, 0x1a0(r4)
    std r29, 0x1b0(r4)
    std r30, 0x1c0(r4)
    std r31, 0x1d0(r4)

    blr

load_regs:
    lis r4, reg_file@ha
    la r4, reg_file@l(r4)

    ld r0,  0x00(r4)
    ld r2,  0x10(r4)
    ld r3,  0x20(r4)
    ld r4,  0x30(r4)
    ld r5,  0x40(r4)
    ld r6,  0x50(r4)
    ld r7,  0x60(r4)
    ld r8,  0x70(r4)
    ld r9,  0x80(r4)
    ld r10, 0x90(r4)
    ld r11, 0xa0(r4)
    ld r12, 0xb0(r4)
    ld r13, 0xc0(r4)
    ld r14, 0xd0(r4)
    ld r15, 0xe0(r4)
    ld r16, 0xf0(r4)
    ld r17, 0x100(r4)
    ld r19, 0x110(r4)
    ld r20, 0x120(r4)
    ld r21, 0x130(r4)
    ld r22, 0x140(r4)
    ld r23, 0x150(r4)
    ld r24, 0x160(r4)
    ld r25, 0x170(r4)
    ld r26, 0x180(r4)
    ld r27, 0x190(r4)
    ld r28, 0x1a0(r4)
    ld r29, 0x1b0(r4)
    ld r30, 0x1c0(r4)
    ld r31, 0x1d0(r4)

    blr

fill_regs_with_data:
    ld r0,  0x00(r4)
    ld r2,  0x10(r4)
    ld r3,  0x20(r4)
    ld r5,  0x40(r4)
    ld r6,  0x50(r4)
    ld r7,  0x60(r4)
    ld r8,  0x70(r4)
    ld r9,  0x80(r4)
    ld r10, 0x90(r4)
    ld r11, 0xa0(r4)
    ld r12, 0xb0(r4)
    ld r13, 0xc0(r4)
    ld r14, 0xd0(r4)
    ld r15, 0xe0(r4)
    ld r16, 0xf0(r4)
    ld r17, 0x100(r4)
    ld r19, 0x110(r4)
    ld r20, 0x120(r4)
    ld r21, 0x130(r4)
    ld r22, 0x140(r4)
    ld r23, 0x150(r4)
    ld r24, 0x160(r4)
    ld r25, 0x170(r4)
    ld r26, 0x180(r4)
    ld r27, 0x190(r4)
    ld r28, 0x1a0(r4)
    # r29, r30 and r31 stay untouched.
    addi r5, r4, 0x1c0
    mtcr r5

    blr
