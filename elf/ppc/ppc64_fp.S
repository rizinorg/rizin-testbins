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
min_sd:
    .llong 0x8000000000000000
min_sw:
    .long 0x80000000
min_sh:
    .hword 0x8000
min_sb:
    .byte 0x80
min_ud:
    .llong 0x0
min_uw:
    .long 0x0
min_uh:
    .hword 0x0
min_ub:
    .byte 0x0
max_sd:
    .llong 0x7fffffffffffffff
max_sw:
    .long 0x7fffffff
max_sh:
    .hword 0x7fff
max_sb:
    .byte 0x7f
max_ud:
    .llong 0xffffffffffffffff
max_uw:
    .long 0xffffffff
max_uh:
    .hword 0xffff
max_ub:
    .byte 0xff
.align 4


.text

    .global max_sd_into_r28
    .global min_sd_into_r27
    .global max_sw_into_r28
    .global min_sw_into_r27
    .global max_sh_into_r28
    .global min_sh_into_r27
    .global max_sb_into_r28
    .global min_sb_into_r27
    .global max_ud_into_r28
    .global min_ud_into_r27
    .global max_uw_into_r28
    .global min_uw_into_r27
    .global max_uh_into_r28
    .global min_uh_into_r27
    .global max_ub_into_r28
    .global min_ub_into_r27
    .global add_insns
    .global sub_insns
    .global store_insns
    .global load_insns

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
    li r1, 1
    addi r11, r30, -1 # r11 = -1

    cmpw 0, r0, r1
    cmpd 1, r0, r1
    cmplw 4, r0, r1
    cmpld 5, r0, r1
    cmpwi 2, r0, -1
    cmpdi 3, r0, 1
    cmplwi 6, r0, 0
    cmpldi 7, r0, 1


# Helper max (un)signed into r28

max_sd_into_r28:
    lis r20, max_sd@ha
    la r20, max_sd@l(r21)
    ld r28, 0(r20)
    blr

max_sw_into_r28:
    lis r20, max_sw@ha
    la r20, max_sw@l(r21)
    lwa r28, 0(r20)
    blr

max_sh_into_r28:
    lis r20, max_sh@ha
    la r20, max_sh@l(r21)
    lha r28, 0(r20)
    blr

max_sb_into_r28:
    lis r20, max_sb@ha
    la r20, max_sb@l(r21)
    lbz r28, 0(r20)
    blr

max_ud_into_r28:
    lis r20, max_ud@ha
    la r20, max_ud@l(r21)
    ld r28, 0(r20)
    blr

max_uw_into_r28:
    lis r20, max_uw@ha
    la r20, max_uw@l(r21)
    lwz r28, 0(r20)
    blr

max_uh_into_r28:
    lis r20, max_uh@ha
    la r20, max_uh@l(r21)
    lhz r28, 0(r20)
    blr

max_ub_into_r28:
    lis r20, max_ub@ha
    la r20, max_ub@l(r21)
    lbz r28, 0(r20)
    blr

# Helper min (un)signed into r27

min_sd_into_r27:
    lis r20, min_sd@ha
    la r20, min_sd@l(r21)
    ld r27, 0(r20)
    blr

min_sw_into_r27:
    lis r20, min_sw@ha
    la r20, min_sw@l(r21)
    lwa r27, 0(r20)
    blr

min_sh_into_r27:
    lis r20, min_sh@ha
    la r20, min_sh@l(r21)
    lha r27, 0(r20)
    blr

min_sb_into_r27:
    lis r20, min_sb@ha
    la r20, min_sb@l(r21)
    lbz r27, 0(r20)
    blr

min_ud_into_r27:
    lis r20, min_ud@ha
    la r20, min_ud@l(r21)
    ld r27, 0(r20)
    blr

min_uw_into_r27:
    lis r20, min_uw@ha
    la r20, min_uw@l(r21)
    lwz r27, 0(r20)
    blr

min_uh_into_r27:
    lis r20, min_uh@ha
    la r20, min_uh@l(r21)
    lhz r27, 0(r20)
    blr

min_ub_into_r27:
    lis r20, min_ub@ha
    la r20, min_ub@l(r21)
    lbz r27, 0(r20)
    blr
