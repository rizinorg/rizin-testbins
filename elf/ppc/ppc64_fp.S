# SPDX-FileCopyrightText: 2022 Rot127 <unisono@quyllur.org>
# SPDX-License-Identifier: LGPL-3.0-only

.data
.align 24
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
    .long 0
.align 4


.text
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
