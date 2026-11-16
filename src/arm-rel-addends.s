@ SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
@ SPDX-License-Identifier: LGPL-3.0-only
@
@ Implicit addends of Arm REL relocations, assembled for both byte orders.
@ Each relocation has a distinct addend, so that a field read from the wrong
@ bits or an addend lost or applied twice shows in the result.
@
@   arm-linux-gnueabi-as -o ../elf/arm-rel-addends.o arm-rel-addends.s
@   arm-linux-gnueabi-as -EB -o ../elf/armeb-rel-addends.o arm-rel-addends.s

	.syntax	unified
	.arch	armv7-a
	.set	abs_small, 0x40
	.globl	abs_small

	.text
	.arm
	.globl	_start
_start:
	bl	ext_func
	bl	ext_func + 0x40
	b	ext_func
	beq	ext_func + 8
	@ Calls to Thumb code are BLX, which keeps bit 1 of the offset in H.
	blx	ext_tfunc
	bl	thumb_local
	bl	thumb_local + 4
	@ MOVW and MOVT both hold a signed 16-bit addend.
	movw	r0, #:lower16:ext_data + 0x1234
	movt	r0, #:upper16:ext_data + 0x1234
	movw	r1, #:lower16:ext_data - 4
	movt	r1, #:upper16:ext_data - 4
1:	movw	r4, #:lower16:(ext_data + 0x10 - (1b + 8))
2:	movt	r4, #:upper16:(ext_data + 0x10 - (2b + 8))
	@ The first chunk of the offset starts at an odd bit, so it rounds up.
	add	r5, pc, #:pc_g0_nc:(far_data - 8)
	ldr	r6, [r5, #:pc_g1:(far_data - 4)]
	.reloc	., R_ARM_LDR_PC_G0, ext_data
	ldr	r0, [pc, #-0x20]
	.reloc	., R_ARM_LDRS_PC_G0, near_data
	ldrh	r0, [pc, #-0x24]
	.reloc	., R_ARM_LDC_PC_G0, near_data
	ldc	p1, c2, [pc, #-0x28]
	.reloc	., R_ARM_ABS12, abs_small
	ldr	r0, [r1, #0x10]
	ldr	r2, =ext_data + 0x20
	ldr	r3, =ext_data - 0x10
	bx	lr
	.ltorg

	.section .text.thumb, "ax", %progbits
	.thumb
	.thumb_func
	.type	thumb_local, %function
thumb_local:
	bl	ext_tfunc
	bl	ext_tfunc + 0x40
	b.w	ext_tfunc + 0x10
	beq.w	ext_tfunc + 0x40000
	beq.w	ext_tfunc - 0x40000
	bl	ext_tfunc + 0x400000
	@ A BLX at a halfword offset branches from the word-aligned PC.
	nop
	blx	ext_func
	@ A BLX to Thumb code becomes a BL.
	.reloc	., R_ARM_THM_CALL, thumb_local
	.inst.w	0xf7ffeffe
	movw	r0, #:lower16:ext_data + 0x5678
	movt	r0, #:upper16:ext_data + 0x5678
	movw	r1, #:lower16:ext_data - 8
	movt	r1, #:upper16:ext_data - 8
3:	movw	r4, #:lower16:(ext_data + 0x20 - (3b + 4))
4:	movt	r4, #:upper16:(ext_data + 0x20 - (4b + 4))
	.reloc	., R_ARM_THM_ALU_PREL_11_0, near_data
	addw	r0, pc, #0x904
	.reloc	., R_ARM_THM_ALU_PREL_11_0, near_data
	subw	r1, pc, #0x10
	.reloc	., R_ARM_THM_PC12, ext_data
	ldr.w	r2, [pc, #-0x10]
	.reloc	., R_ARM_THM_JUMP11, near_data
	b	. + 0x10
	.reloc	., R_ARM_THM_JUMP11, near_data
	b	. - 0x10
	.reloc	., R_ARM_THM_ABS5, abs_small
	ldr	r0, [r1, #0x8]
	.reloc	., R_ARM_THM_ALU_ABS_G0_NC, ext_data
	adds	r0, #0x12
	.reloc	., R_ARM_THM_ALU_ABS_G3_NC, ext_data
	adds	r0, #0x78
	bx	lr

	.section .text.near, "ax", %progbits
	.align	2
	.thumb
	nop
	.reloc	., R_ARM_THM_JUMP6, near_data
	cbz	r0, . + 0x10
	.reloc	., R_ARM_THM_PC8, near_data
	ldr	r2, [pc, #0x8]
	.reloc	., R_ARM_THM_JUMP8, near_data
	beq	. + 0x10
	.reloc	., R_ARM_THM_JUMP8, near_data
	bne	. - 0x20
	bx	lr

	.section .rodata.near, "a", %progbits
	.align	4
near_data:
	.space	0x10

	.data
	.align	2
	.word	ext_data + 0x20
	.word	ext_data - . + 0x10
	.word	ext_func - 4
	.word	thumb_local + 4
	.word	thumb_local(TARGET1) + 4
	.word	ext_got(TARGET2) + 0xc
	.word	ext_got(GOT) + 4
	.word	ext_got(GOTOFF) + 8
	.word	ext_got(GOT_PREL) + 0xc
	.word	ext_got(sbrel) + 0x10
	.word	ext_tls(tlsgd) + 4
	.word	ext_tls(tlsldm) + 8
	.word	ext_tls(tlsldo) + 0xc
	.word	ext_tls(gottpoff) + 0x10
	.word	ext_tls(tpoff) + 0x14
	@ Against the absolute symbol, so the result fits.
	.reloc	., R_ARM_ABS16, abs_small
	.short	0x1234
	.reloc	., R_ARM_ABS16, abs_small
	.short	-2
	.reloc	., R_ARM_ABS8, abs_small
	.byte	0x7f
	.reloc	., R_ARM_ABS8, abs_small
	.byte	-3
	.short	0

	.section .ARM.exidx.test, "a", %progbits
	.reloc	., R_ARM_PREL31, _start
	.word	0x8
	.reloc	., R_ARM_PREL31, thumb_local
	.word	0x7ffffffc

	.section .data.far, "aw", %progbits
	.space	0x500
far_data:
	.word	0
