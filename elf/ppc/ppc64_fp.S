# SPDX-FileCopyrightText: 2022 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.data
.align 12
msg:
    .string "Hello, world!\n"
    len = . - msg       # length of our dear string

.align 4
store_b:
    .byte 0
.align 4
store_h:
    .hword 0
.align 4
store_w:
    .word 0
.align 4
store_d:
    .llong 0
.align 4

.rodata
.include "ppc_helper.rodata.S"


.text
    .global add_insns
    .global sub_insns
    .global store_insns
    .global load_insns
    .global compare_insns
    .global branch_insns

.include "ppc_helper.text.S"

add_insns:
    addi  r1, r30, 0x1           # r1 = 1
    addi  r2, r30, 0x2           # r2 = 2
    addi  r3, r30, 0x3           # r3 = 3
simple_add:
    add.   r4, r1, r3             # r4 = 4
no_carry_16bit_imm:
    addi  r10, r30, -1          # r10 = 0xffffffffff  ca = 0
    addic. r0, r10, 1            # r0 = 0x0 ca = 1
no_carry_set_neg_imm:
    addis r11, r30, -1          # r11 = 0xffff0000
    addi  r11, r30, -1          # r11 = -1
carry_set_and_add:
    addic. r12, r11, 1           # r12 = 0 ca = 1
    adde.  r13, r30, r1          # r13 = 2 ca = 0
carry_add_minus_1:
    addic. r12, r11, 1           # r12 = 0 ca = 1
    addme. r16, r0               # r16 = 0 ca = 0
carry_add:
    addic. r12, r11, 1           # r12 = 0 ca = 1
    addze. r17, r0               # r17 = 1 ca = 0
cr0_neg_result:
    addme. r17, r0               # r17 = -1 ca = 0

    blr

sub_insns:
    li r0, 0
    li r1, 1
    li r2, 2
    li r3, 3
simple_sub_cr0:
    subf. r1, r2, r3             # r1 = 1
    subf. r0, r1, r1             # r0 = 0
    subf. r11, r1, r0            # r11 = -1
simple_sub_carry:
    subfc. r11, r1, r0           # ca = 0
    subfc. r0, r1, r1            # ca = 1
sub_imm_carry:
    subfic r11, r1, 0           # ca = 0
    subfic r0, r2, 2            # ca = 1
sub_carry_add:
    subfe. r11, r1, r30          # r11 = -1 ca = 0
    subfe. r12, r1, r30          # r12 = -2 ca = 0
sub_carry_minus_one:
    subfme. r13, r1              # r13 = -3 ca = 1
    subfme. r12, r1              # r12 = -2 ca = 0
sub_not_ra_carry:
    subfze. r11, r0              # r11 = -1 ca = 0
    subfc. r0, r1, r1            # ca = 1
    subfze. r10, r0              # r10 = 0 ca = 1

    blr

# Store instructions set all bits at their address.
store_insns:
    li r4, 4
    li r11, -1
    li r12, 0x10
    li r13, 0x20
    li r14, 0x30

    lis r21, store_b@ha
    la r21, store_b@l(r21)

    stb r11, 0x00(r21)
    sth r11, 0x10(r21)
    stw r11, 0x20(r21)
    std r11, 0x0c(r21) # 0x0c gets shifted to 0x30

    stbx r11, r21, r0
    sthx r11, r21, r12
    stwx r11, r21, r13
    stdx r11, r21, r14

    stbu r11, 0x00(r21)
    sthu r11, 0x10(r21)
    stwu r11, 0x10(r21)
    stdu r11, 0x04(r21) # 0x04 gets shifted to 0x10

load_insns:
    li r11, 0x00
    li r12, 0x10
    li r13, 0x20
    li r14, 0x30
    lis r21, store_b@ha
    la r21, store_b@l(r21)

    lbz r11, 0x00(r21)
    lhz r11, 0x10(r21)
    lwz r11, 0x20(r21)
    ld  r11, 0x0c(r21) # 0xc << 2 = 0x30

    lbzx r11, r21, r0
    lhzx r11, r21, r12
    lwzx r11, r21, r13
    ldx  r11, r21, r14

    lha r11, 0x10(r21) # r11 = -1
    lwa r11, 0x0c(r21) # 0xc << 2 = 0x30 ; r11 = -1

logical_insns:
    li r0, 0
    li r1, 1
    addi r11, r30, -1 # r11 = -1
    and r21, r11, r1
    andc r12, r11, r1 # r12 = -2
    andi. r1, r1, 0xffff
    andis. r30, r11, 0xffff # r30 = 0x00000000ffff0000
    or r1, r0, r1
    orc r12, r0, r1 # r12 = -2
    ori r5, r0, 0x5555
    oris r5, r0, 0x5555 # r5 = 0x0000000055550000
    xor r5, r11, r5 # r5 = 0xffffffffaaaaffff
    xori r5, r5, 0xcccc # r5 = 0xffffffffaaaa3333
    xoris r5, r5, 0xcccc # r5 = 0xffffffffaaaa3333
    nand r12, r1, r1
    nor r12, r0, r1

compare_insns:
    li r0, 0

    bl max_sw_into_r28
    cmpw 0, r0, r28
    bl max_sd_into_r28
    cmpd 0, r0, r28

    bl min_sw_into_r27
    cmpd 1, r0, r27
    bl min_sd_into_r27
    cmpd 1, r0, r27

    bl max_uw_into_r28
    cmplw 2, r0, r28
    bl max_ud_into_r28
    cmpld 2, r0, r28

    bl min_uw_into_r27
    cmplw 3, r0, r27
    bl min_ud_into_r27
    cmpld 3, r0, r27

    cmpwi 4, r0, -1
    cmpdi 5, r0, 1
    cmplwi 6, r0, -1
    cmpldi 7, r0, 1

branch_insns:
    li r1, 1
    li r20, 0
    # Branch to:
    # Relative address
    bl target_blr
    # CTR
    lis r20, target_blr@ha
    la r20, target_blr@l(r20)
    mtctr r20
    bctrl
    # decrement ctr.
    # CTR != 0
    bdnzl target_blr
    # CTR == 0
    mtctr r1
    bdzl target_blr
    # Branch if CR_6.0 = 0  (cr_6.0 = less than bit.)
    bcl 4, 24, target_blr
    # Branch if CR_0.3 == 1  (cr_0.2 = equal bit)
    cmpw 0, r0, r30
    bcl 12, 2, target_blr
    # Absolute address
    ba 0xc0ffe0 # Branch into nowhere
target_blr:
    # Branch to LR
    blr

shift_insns:

    li r4, 4

    lis r20, rotate_test_pattern@ha
    la r20, rotate_test_pattern@l(r20)
    ld r20, 0x0(r20)
    # 0xfedcba9876543210
    sld r10, r20, r4 # r10 = 0xedcba98765432100
    srd r10, r20, r4 # r10 = 0x0fedcba987654321
    slw r10, r20, r4 # r10 = 0x0000000065432100
    srw r10, r20, r4 # r10 = 0x0000000007654321
    srad r10, r20, r4 # r10 = 0xffedcba987654321
    sradi r10, r20, 4 # r10 = 0xffedcba987654321
    lis r22, rotate_test_pattern_rev@ha
    la r22, rotate_test_pattern_rev@l(r22)
    ld r22, 0x0(r22)
    sraw r10, r22, r4 # r10 = 0xfffffffff89abcde
    srawi r10, r22, 4 # r10 = 0xfffffffff89abcde

rotate_insns:
    li r4, 4
    lis r20, rotate_test_pattern@ha
    la r20, rotate_test_pattern@l(r20)
    ld r20, 0x0(r20)

    rlwimi r10, r20, 8, 4, 16 # mstart < mstop  | rot: r10 = 0x54321076_54321076 -> mask r10 = 0x00000000_04320000
    rlwimi r10, r20, 8, 16, 4 # mstart > mstop  | rot: r10 = 0x54321076_54321076 -> mask r10 = 0x54321076_54321076
    li r10, 0
    rlwimi r10, r20, 8, 16, 4 # mstart > mstop  | rot: r10 = 0xdcba9876_54321000 -> mask r10 = 0x54321076_50001076
    li r10, 0
    rlwimi r10, r20, 8, 4, 4  # mstart == mstop | rot: r10 = 0x54321076_54321076 -> mask r10 = 0x54321076_54321076

    rldicl r10, r20, 4, 16 # r10 = 0x0000a987_6543210f

    li r10, 0
    rldimi r10, r20, 4, 8 # Mask mstart < mstop ? rot: r10 = 0xedcba987_6543210f -> mask r10 = 0x00cba987_65432100
    rotld r10, r20, 4     # r10 = 0xedcba987_6543210f
    rotlw r10, r20, 4     # r10 = 0x65432107_65432107
    clrldi r10, r20, 12   # r10 = 0x000cba98_76543210
    clrlwi r10, r20, 12   # r10 = 0x00000000_00043210
    clrldi. r10, r20, 1   # r10 = 0x7edcba98_76543210
    clrldi. r10, r20, 0   # r10 = 0xfedcba98_76543210
    clrldi. r10, r20, 60  # r10 = 0x00000000_00000000



