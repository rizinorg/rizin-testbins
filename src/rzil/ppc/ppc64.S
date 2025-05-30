# SPDX-FileCopyrightText: 2022 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.data
.include "ppc_helper.data.S"

.rodata
.include "ppc_helper.rodata.S"


.text
    .global run_all_tests
    .global add_insns
    .global sub_insns
    .global store_insns
    .global load_insns
    .global compare_insns
    .global branch_insns
    .global rotate_insns
    .global logical_insns
    .global special_insns
    .global read_set_spr
    .global test_loads
    .global shift_insns
    .global cr_logical_insns
    .global div_mul_insns

    .type run_all_tests, @function
    .type add_insns, @function
    .type sub_insns, @function
    .type store_insns, @function
    .type load_insns, @function
    .type compare_insns, @function
    .type branch_insns, @function
    .type rotate_insns, @function
    .type logical_insns, @function
    .type special_insns, @function
    .type read_set_spr, @function
    .type test_loads, @function
    .type shift_insns, @function
    .type cr_logical_insns, @function
    .type div_mul_insns, @function

.include "ppc64_helper.text.S"

target_blr:
    # Branch to LR
    blr

# We do not test all branch instructions and mnemonics here.
# Simply because almost all of them share the some exec path.
# So instead we test each of those paths.
branch_insns:
    mflr r30
    li r23, 1
    li r20, 0

    # Branch to relative address
    bl target_blr

    # Branch to CTR
    lis r20, target_blr@ha
    la r20, target_blr@l(r20)
    mtctr r20
    bctrl

    # Decrement CTR and branch
    # CTR != 0
    bdnzl target_blr

    # CTR == 0
    mtctr r23
    bdzl target_blr

    # Branch if certain CRx bits are set
    # Branch if CR_6.0 == 0  (cr_6.0 is the "less than" bit.)
    bcl 4, 24, target_blr

    # Branch if CR_0.3 == 1  (cr_0.2 is the "equal" bit)
    cmpw 0, r0, r19
    bcl 12, 2, target_blr

    # Branch if CTR != 0 && CR0 == 0
    mtctr r20
    # Set all CRx to 0xf except CR0, CR3, CR7
    # r10 = 0x0ff0ff0
    addis r10, 0, 0x0fff
    addi r10, r10, 0x0ff0
    mtcr r10
    bdnzfl 0, target_blr

    # Branch if CTR != 0 && CR3 == 1
    li r10, 0x1000
    # CR3 = 1
    mtcrf 0x8, r10
    bdnztl 3, target_blr

    # Branch if CTR == 0 && CR5 == 0
    mtctr r23
    # CR5 = 0
    mtcrf 0x20, r0
    bdzfl 5, target_blr

    # Branch if CTR == 0 && CR7 == 1
    mtctr r23
    # CR7 = 1
    li r10, 0
    addis r10, r10, 0x1000
    mtcrf 0x80, r10
    bdztl 7, target_blr

    # CTR != 0 (don't branch)
    mtctr r0
    bdztl 7, target_blr

    # CTR == 0 but cr0 != 1 (don't branch)
    mtctr r23
    li r3, 3
    mtcrf 0x1, r3
    bdztl 0, target_blr

    # Branch to Absolute address
    bla target_blr
    mtlr r30
    blr

special_insns:
    nop
    xnop
    li r23, 1
    li r4, 0x00004000
    mtcrf 0x4, r4
    isel r10, 0, r23, 14
    isel r10, 0, r23, 0
    # Single dcbz instructions lead to segaults.
    # But they are executed before main is reached so it is fine to ignore them here.

    blr


read_set_spr:
    mflr r30

    bl max_ud_into_r28
    mtctr r28
    mfctr r28
    mtlr r28
    mflr r28
    bl max_ud_into_r28
    mtxer r28
    # mfxer r0

    mtlr r30
    blr

# Instructions which are PC/LR independed below

test_loads:
    mflr r30

    bl store_insns
    bl load_insns
    
    mtlr r30
    blr

add_insns:
    addi  r23, r19, 0x1           # r23 = 1
    addi  r2, r19, 0x2           # r2 = 2
    addi  r3, r19, 0x3           # r3 = 3
simple_add:
    add.   r4, r23, r3             # r4 = 4
no_carry_16bit_imm:
    addi  r10, r19, -1          # r10 = 0xffffffffff  ca = 0
    addic. r0, r10, 1            # r0 = 0x0 ca = 1
no_carry_set_neg_imm:
    addis r11, r19, -1          # r11 = 0xffff0000
    addi  r11, r19, -1          # r11 = -1
carry_set_and_add:
    addic. r12, r11, 1           # r12 = 0 ca = 1
    adde.  r13, r19, r23          # r13 = 2 ca = 0
carry_add_minus_1:
    addic. r12, r11, 1           # r12 = 0 ca = 1
    addme. r16, r0               # r16 = 0 ca = 0
carry_add:
    addic. r12, r11, 1           # r12 = 0 ca = 1
    addze. r17, r0               # r17 = 1 ca = 0
cr0_neg_result:
    addme. r17, r0               # r17 = -1 ca = 0
    neg r17, r17                 # r17 = 1

    blr

sub_insns:
    li r0, 0
    li r23, 1
    li r2, 2
    li r3, 3
simple_sub_cr0:
    subf. r23, r2, r3             # r23 = 1
    subf. r0, r23, r23             # r0 = 0
    subf. r11, r23, r0            # r11 = -1
simple_sub_carry:
    subfc. r11, r23, r0           # ca = 0
    subfc. r0, r23, r23            # ca = 1
sub_imm_carry:
    subfic r11, r23, 0           # ca = 0
    subfic r0, r2, 2            # ca = 1
sub_carry_add:
    subfe. r11, r23, r19          # r11 = -1 ca = 0
    subfe. r12, r23, r19          # r12 = -2 ca = 0
sub_carry_minus_one:
    subfme. r13, r23              # r13 = -3 ca = 1
    subfme. r12, r23              # r12 = -2 ca = 0
sub_not_ra_carry:
    subfze. r11, r0              # r11 = -1 ca = 0
    subfc. r0, r23, r23            # ca = 1
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
    std r11, 0x30(r21)

    stbx r11, r21, r0
    sthx r11, r21, r12
    stwx r11, r21, r13
    stdx r11, r21, r14

    stbu r11, 0x00(r21)
    sthu r11, 0x10(r21)
    stwu r11, 0x10(r21)
    stdu r11, 0x10(r21)

    blr

load_insns:
    li r11, 0x00
    li r12, 0x10
    li r13, 0x20
    li r14, 0x30
    lis r21, load_b@ha
    la r21, load_b@l(r21)

    lbz r11, 0x00(r21)
    lhz r11, 0x10(r21)
    lwz r11, 0x20(r21)
    ld  r11, 0x30(r21)

    lbzx r11, r21, r0
    lhzx r11, r21, r12
    lwzx r11, r21, r13
    ldx  r11, r21, r14

    lha r11, 0x10(r21)
    lwa r11, 0x30(r21)

    lis r20, rotate_test_pattern_rev@ha
    la r20, rotate_test_pattern_rev@l(r20)

    # r11 = 0x2301
    lhbrx r11, 0, r20
    # r11 = 0x67452301
    lwbrx r11, 0, r20
    # r11 = 0xefcdab8967452301
    ldbrx r11, 0, r20

    blr

logical_insns:
    mflr r30
    li r0, 0
    li r23, 1
    addi r11, r19, -1 # r11 = -1
    and r21, r11, r23
    andc r12, r11, r23 # r12 = -2
    andi. r23, r23, 0xffff
    andis. r19, r11, 0xffff # r19 = 0x00000000ffff0000
    or r23, r0, r23
    orc r12, r0, r23 # r12 = -2
    ori r5, r0, 0x5555
    oris r5, r0, 0x5555 # r5 = 0x0000000055550000
    xor r5, r11, r5 # r5 = 0xffffffffaaaaffff
    xori r5, r5, 0xcccc # r5 = 0xffffffffaaaa3333
    xoris r5, r5, 0xcccc # r5 = 0xffffffffaaaa3333
    nand r12, r23, r23
    nor r12, r0, r23
    mr r20, r5          # r20 = 0xffffffffaaaaffff
    bl min_sb_into_r27
    extsb r10, r27
    bl max_sb_into_r28
    extsb r10, r28
    bl min_sh_into_r27
    extsh r10, r27
    bl max_sh_into_r28
    extsh r10, r28
    bl min_sw_into_r27
    extsw r10, r27
    bl max_sw_into_r28
    extsw r10, r28

    bl min_ud_into_r27
    # r13 = 64
    cntlzd r13, r27
    bl max_ud_into_r28
    # r13 = 0
    cntlzd r13, r28
    bl max_uw_into_r28
    # r13 = 32
    cntlzd r13, r28
    # r13 = 0
    cntlzw r13, r28
    bl min_uw_into_r27
    # r13 = 32
    cntlzw r13, r27

    eqv r11, r11, r11
    eqv r19, r23, r0

    mtlr r30
    blr

compare_insns:
    mflr r30
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

    lis r20, rotate_test_pattern@ha
    la r20, rotate_test_pattern@l(r20)
    ld r10, 0x0(r20)
    ld r11, 0x0(r20)
    # r9 = -1
    cmpb r9, r10, r11
    andi. r10, r10, 0xff00
    # r9 = 0xff00
    cmpb r9, r10, r11
    mtlr r30
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
    # sldi r10, r20, 16 # r10 = 0xba98765432100000 # Broken in rizins capstone version
    slwi r10, r20, 16 # r10 = 0x0000000032100000
    srwi r10, r20, 16 # r10 = 0x0000000000007654

    blr

rotate_insns:
    li r4, 4
    lis r20, rotate_test_pattern@ha
    la r20, rotate_test_pattern@l(r20)
    ld r20, 0x0(r20)

    rlwimi r10, r20, 8, 4, 16 # mstart < mstop  | r10 = 0x00000000_04320000
    rlwimi r10, r20, 8, 16, 4 # mstart > mstop  | r10 = 0x54321076_54321076
    li r10, 0
    rlwimi r10, r20, 8, 16, 4 # mstart > mstop  | r10 = 0x54321076_50001076
    li r10, 0
    rlwimi r10, r20, 8, 5, 5  # mstart == mstop | r10 = 0x4000000

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

    blr

cr_logical_insns:
    # Set cr2.0 = 1 (bit 23) and cr5.3 = 1 (bit 8)
    li r10, 0x0100
    addis r10, r10, 0x0080
    mtcr r10
    crclr 23
    crset 23
    # Set bit 23 again
    cror 23, 23, 8
    # Clear bit 23
    cror 23, 24, 9
    # Clear bit 8
    cror 8, 23, 23
    mtcr r10
    # cr7 = 1
    mcrf 7, 2
    # cr7 = 1
    mcrf 7, 7

    blr

div_mul_insns:
    mflr r30
    bl minus_one_into_r11

    bl max_sw_into_r28
	mullw r19, r28, r11

    bl max_sd_into_r28
	mulli r19, r28, -1
	mulld r19, r28, r11

    bl min_sd_into_r27
	mulhd r19, r28, r27

    bl max_sw_into_r28
    bl min_sw_into_r27
    mulhw r19, r28, r27

    li r2, 2
    bl max_ud_into_r28
    mulhdu r19, r28, r2
    bl max_uw_into_r28
	mulhwu r19, r28, r2

    bl max_sd_into_r28
    bl minus_one_into_r11
    divd r19, r28, r11
	divdu r19, r28, r11

    bl max_sw_into_r28
    bl minus_one_into_r11
    divw r19, r28, r11
	divwu r19, r28, r11

    mtlr r30
    blr

run_all_tests:
    mflr r3
    bl store_regs

    bl add_insns
    bl sub_insns
    bl store_insns
    bl load_insns
    bl compare_insns
    bl branch_insns
    bl rotate_insns
    bl logical_insns
    bl special_insns
    bl read_set_spr
    bl shift_insns
    bl cr_logical_insns
    bl div_mul_insns

    bl load_regs
    mtlr r3
    blr
