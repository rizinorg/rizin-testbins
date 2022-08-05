# SPDX-FileCopyrightText: 2022 r0t127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.data
.include "ppc_helper.data.S"

.rodata
.include "ppc_helper.rodata.S"

.text

asm_collection:
    # fill random data
    # mtctr r0
    # bctrl
    addi  r0, r26, 0x4
    add r0, r1, r2
    addic r0, r1, 1
    addis r0, r26, 1
    addme r0, r2
    addze r0, r2
    adde r0, r2, r1
    addc r0, r2, r1
    subf r0, r1, r2
    subfc r0, r1, r2
    subfic r0, r2, 1
    subfe r0, r1, r2
    subfme r0, r2
    subfze r0, r2
    neg r1, r3

    ### STORES BEGIN
    # Set store playground
    # lis r26, store_b@ha
    # la r26, store_b@l(r26)
    dcbz r1, r0
    stb r0, 0x4(r26)
    sth r0, 0x4(r26)
    stw r0, 0x4(r26)
    std r0, 0x4(r26)
    stbx r0, r26, r1
    sthx r0, r26, r1
    stwx r0, r26, r1
    stdx r0, r26, r1
    stbu r0, 0x4(r26)
    sthu r0, 0x4(r26)
    stwu r0, 0x4(r26)
    stdu r0, 0x4(r26)
    stbux r0, r26, r1
    sthux r0, r26, r1
    stwux r0, r26, r1
    stdux r0, r26, r1
    stbcix r0, r26, r1
    sthcix r0, r26, r1
    stwcix r0, r26, r1
    stdcix r0, r26, r1
    ### STORES END

    ### LOADS BEGIN
    # Set load playground
    # lis r26, store_b@ha
    # la r26, store_b@l(r26)
    li r0, 1
    lis r0, 1
    la r0, 0x8(r26)
    lbz r0, 0x4(r26)
    lbzx r0, r26, r1
    lbzu r0, 0x8(r26)
    lbzux r0, r26, r1
    lbzcix r0, r26, r1
    lha r0, 0x4(r26)
    lhz r0, 0x4(r26)
    lhzx r0, r26, r1
    lhzu r0, 0x8(r26)
    lhzux r0, r26, r1
    lhax r0, r26, r1
    lhaux r0, r26, r1
    lhzcix r0, r26, r1
    lwa r0, 0x4(r26)
    lwz r0, 0x4(r26)
    lwzx r0, r26, r1
    lwax r0, r26, r1
    lwaux r0, r26, r1
    lwzcix r0, r26, r1
    ld  r0, 0x4(r26)
    ldx  r0, r26, r1
    ldu r0, 0x4(r26)
    ldux r0, r26, r1
    ldcix r0, r26, r1
    lhbrx r0, r26, r1
    lwbrx r0, r26, r1
    ldbrx r0, r26, r1
    ### LOADS END

    # fill random data
    # mtctr r0
    # bctrl
    and r0, r1, r2
    andc r0, r1, r2
    andi. r0, r2, 0x4
    andis. r26, r0, 0x4
    mr r5, r20

    # fill random data
    # mtctr r0
    # bctrl
    or r0, r26, r1
    orc r0, r1, r2
    ori r0, r26, 0x4
    oris r0, r2, 0x4

    # fill random data
    # mtctr r0
    # bctrl
    xor r0, r1, r2
    xori r0, r26, 0x4
    xoris r0, r2, 0x4

    # fill random data
    # mtctr r0
    # bctrl
    nand r0, r1, r2
    nor r0, r1, r2

    # fill random data
    # mtctr r0
    # bctrl
    cmpb 0, r0, r1
    eqv r0, r1, r6

    # fill random data
    # mtctr r0
    # bctrl
    extsb r0, r4
    extsh r0, r4
    extsw r0, r4

    # fill random data
    # mtctr r0
    # bctrl
    cntlzd r0, r1
    cntlzd r0, r1

    # fill random data
    # mtctr r0
    # bctrl
    cmpw 3, r0, r1
    cmpd 5, r0, r1
    cmpwi 2, r0, -1
    cmpdi 3, r0, 1
    cmplw 4, r0, r1
    cmpld 5, r0, r1
    cmplwi 6, r0, 0
    cmpldi 7, r0, 1

    ### BRANCH BEGIN
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
	bca 4, 3, 0x18
	bcla 4, 4, 0x18
	bdnzt 4, 0x7fe4
	bdnztl 4, 0x7fe4
	bdnzta 4, 0x7fe4
	bdnztla 4, 0x7fe4
	bdnzf 4, 0x7fe4
	bdnzfl 4, 0x7fe4
	bdnzfa 4, 0x7fe4
	bdnzfla 4, 0x7fe4
	bdzt 4, 0x7fe4
	bdzta 4, 0x7fe4
	bdztl 4, 0x7fe4
	bdztla 4, 0x7fe4
	bdzf 4, 0x7fe4
	bdzfa 4, 0x7fe4
	bdzfl 4, 0x7fe4
	bdzfla 4, 0x7fe4
    ### BRANCH END

    # fill random data
    # mtctr r0
    # bctrl
    nop
    xnop
    mtcrf 0x4, r4
    isel r10, 0, r23, 14
    mtctr r28
    mfctr r28
    mtlr r28
    mflr r28
    mtxer r28
    mfxer r0
    mfcr r10
    mfctr r10
    mffs 3
    mflr r10
    mfmsr r10
    mfocrf r10, 1
    mfspr r10, 2
    mftb r10
    mfvscr 2
    mtcrf 1, 12
    mtctr r10
    mtfsb0 2
    mtfsb1 1
    mtfsf 3, 1
    mtfsfi 4, 4
    mtlr r10
    mtmsr r10
    mtmsrd r10
    mtocrf 1, 2
    mtspr 0xf, 1
    mtvscr 1
    mfxer r10
    mfrtcu r10
    mfrtcl r10
    mfdscr r10
    mfdsisr r10
    mfdar r10
    mfcfar r10
    mfamr r10
    mfdbatu r10, 2
    mfdbatl r10, 1
    mfibatu r10, 3
    mfibatl 1, 1
    mfasr r10
    mfpvr r10
    mftbu r10
    mtxer r10
    mtdscr r10
    mtdsisr r10
    mtdar r10
    mtcfar r10
    mtamr r10
    mttbl r10
    mttbu r10
    mtdbatu 3, 4
    mtdbatl 3, 4
    mtibatu 3, 4
    mtibatl 3, 4


    # fill random data
    # mtctr r0
    # bctrl
    sld r10, r20, r4
    srd r10, r20, r4
    slw r10, r20, r4
    srw r10, r20, r4
    srad r10, r20, r4
    sradi r10, r20, 4
    lis r22, rotate_test_pattern_rev@ha
    la r22, rotate_test_pattern_rev@l(r22)
    ld r22, 0x0(r22)
    sraw r10, r22, r4
    srawi r10, r22, 4
    slwi r10, r20, 16
    srwi r10, r20, 16
    # sldi r10, r20, 16 # Broken in rizins capstone version

    # fill random data
    # mtctr r0
    # bctrl
    rlwimi r10, r20, 8, 5, 5
    rldicl r10, r20, 4, 16
    rldimi r10, r20, 4, 8
    rotld r10, r20, 4
    rotlw r10, r20, 4
    rotlwi r10, 2, 4
    clrlwi r10, r20, 12
    clrldi. r10, r20, 60
    rldcl r10, r20, 4, 16
    rldcr r10, r20, 4, 16
    rldicr r10, r20, 4, 16
    rlwinm r10, r20, 4, 16
    rlwnm r10, r20, 4, 16
    rotldi r10, r20, 4

    # fill random data
    # mtctr r0
    # bctrl
    divd r4, r6, r7
    divdu r4, r6, r7
    divw r4, r6, r7
    divwu r4, r6, r7
    mulhd r4, r6, r7
    mulhdu r4, r6, r7
    mulhw r4, r6, r7
    mulhwu r4, r6, r7
    mulld r4, r6, r7
    mulli r4, r6, 7
    mullw r4, r6, r7

    # fill random data
    # mtctr r0
    # bctrl
    creqv 15, 4, 7
    crxor 15, 4, 7
    crand 15, 4, 7
    crandc 15, 4, 7
    crnand 15, 4, 7
    crnor 15, 4, 7
    cror 15, 4, 7
    crorc 15, 4, 7
    crset 15
    crnot 15, 4
    crmove 15, 4
    crclr 15
    mcrf 4, 3   
