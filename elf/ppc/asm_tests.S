# SPDX-FileCopyrightText: 2022 r0t127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.text

asm:
    addi  r0, r30, 0x4
    add r0, r1, r2
    addic r0, r1, 1
    addis r0, r30, 1
    addme r0, r2
    addze r0, r2
    li r0, 1
    subf r0, r1, r2
    subfc r0, r1, r2
    subfic r0, r2, 1
    subfe r0, r1, r2
    subfme r0, r2
    subfze r0, r2
    lis r0, 1
    stb r0, 0x4(r30)
    sth r0, 0x4(r30)
    stw r0, 0x4(r30)
    std r0, 0x4(r30)
    stbx r0, r30, r1
    sthx r0, r30, r1
    stwx r0, r30, r1
    stdx r0, r30, r1
    stbu r0, 0x4(r30)
    sthu r0, 0x4(r30)
    stwu r0, 0x4(r30)
    stdu r0, 0x4(r30)
    lbz r0, 0x4(r30)
    lhz r0, 0x4(r30)
    lwz r0, 0x4(r30)
    ld  r0, 0x4(r30)
    lbzx r0, r30, r1
    lhzx r0, r30, r1
    lwzx r0, r30, r1
    ldx  r0, r30, r1
    lha r0, 0x4(r30)
    lwa r0, 0x4(r30)
    ldu r0, 0x4(r30)
    ldux r0, r30, r1
    lhax r0, r30, r1
    lwax r0, r30, r1
    lhaux r0, r30, r1
    lwaux r0, r30, r1
    and r0, r1, r2
    andc r0, r1, r2
    andi. r0, r2, 0x4
    andis. r30, r0, 0x4
    mr r5, r20
    or r0, r30, r1
    orc r0, r1, r2
    ori r0, r30, 0x4
    oris r0, r2, 0x4
    xor r0, r1, r2
    xori r0, r30, 0x4
    xoris r0, r2, 0x4
    nand r0, r1, r2
    nor r0, r1, r2
    cmpw 0, r0, r1
    cmpd 1, r0, r1
    cmpwi 2, r0, -1
    cmpdi 3, r0, 1
    cmplw 4, r0, r1
    cmpld 5, r0, r1
    cmplwi 6, r0, 0
    cmpldi 7, r0, 1
    b 0x4
	ba 0x4
	bcctr 4, 0
	bcctrl 4, 0
	bc 4, 0, 0x4
    bc 4, 1, 0x4
	bcl 4, 0, 0x4
	bclr 4, 0
	bclrl 4, 0
	bctr
	bctrl
	bdnz 0x4
	bdnza 0x4
	bdnzl 0x4
	bdnzla 0x4
	bdnzlr
	bdnzlrl
	bdz 0x4
	bdza 0x4
	bdzl 0x4
	bdzla 0x4
	bdzlr
	bdzlrl
	bl 0x4
	bla 0x4
	blr
	blrl
    nop
    mtctr r28
    mfctr r28
    mtlr r28
    mflr r28
    # sldi r10, r20, 16 # Broken in rizins capstone version
    slwi r10, r20, 16
    srwi r10, r20, 16
