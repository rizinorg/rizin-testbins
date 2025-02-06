	.file	1 "emulateme.nostd.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.module	arch=mips2
	.text
	.section	.sdata,"aw"
	.align	2
	.type	uart_address, @object
	.size	uart_address, 4
uart_address:
	.word	305419896
	.local	uart_position
	.comm	uart_position,8,8
	.text
	.align	2
	.globl	uart_write_text
	.set	nomips16
	.set	nomicromips
	.ent	uart_write_text
	.type	uart_write_text, @function
uart_write_text:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	sw	$7,28($fp)
	sw	$6,24($fp)
	move	$3,$0
	move	$2,$0
	sw	$3,4($fp)
	sw	$2,0($fp)
	b	$L2
	nop

$L3:
	lw	$2,4($fp)
	lw	$3,16($fp)
	addu	$2,$3,$2
	lb	$5,0($2)
	lw	$4,%gp_rel(uart_address)($28)
	lw	$3,%gp_rel(uart_position+4)($28)
	lw	$2,%gp_rel(uart_position)($28)
	move	$2,$3
	addu	$2,$4,$2
	andi	$3,$5,0x00ff
	sb	$3,0($2)
	lw	$5,%gp_rel(uart_position+4)($28)
	lw	$4,%gp_rel(uart_position)($28)
	li	$7,1			# 0x1
	move	$6,$0
	addu	$3,$5,$7
	sltu	$8,$3,$5
	addu	$2,$4,$6
	addu	$4,$8,$2
	move	$2,$4
	sw	$3,%gp_rel(uart_position+4)($28)
	sw	$2,%gp_rel(uart_position)($28)
	lw	$5,4($fp)
	lw	$4,0($fp)
	li	$7,1			# 0x1
	move	$6,$0
	addu	$3,$5,$7
	sltu	$8,$3,$5
	addu	$2,$4,$6
	addu	$4,$8,$2
	move	$2,$4
	sw	$3,4($fp)
	sw	$2,0($fp)
$L2:
	lw	$3,24($fp)
	lw	$2,0($fp)
	sltu	$2,$2,$3
	bne	$2,$0,$L3
	nop

	lw	$3,24($fp)
	lw	$2,0($fp)
	bne	$3,$2,$L5
	nop

	lw	$3,28($fp)
	lw	$2,4($fp)
	sltu	$2,$2,$3
	bne	$2,$0,$L3
	nop

$L5:
	nop
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	uart_write_text
	.size	uart_write_text, .-uart_write_text
	.rdata
	.align	2
$LC0:
	.ascii	"0123456789abcdef\000"
	.text
	.align	2
	.globl	uart_write_hex
	.set	nomips16
	.set	nomicromips
	.ent	uart_write_hex
	.type	uart_write_hex, @function
uart_write_hex:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	move	$2,$4
	sb	$2,16($fp)
	lui	$2,%hi($LC0)
	addiu	$2,$2,%lo($LC0)
	sw	$2,0($fp)
	lbu	$2,16($fp)
	srl	$2,$2,4
	sb	$2,4($fp)
	lbu	$2,16($fp)
	andi	$2,$2,0xf
	sb	$2,5($fp)
	lbu	$2,4($fp)
	lw	$3,0($fp)
	addu	$2,$3,$2
	lb	$5,0($2)
	lw	$4,%gp_rel(uart_address)($28)
	lw	$3,%gp_rel(uart_position+4)($28)
	lw	$2,%gp_rel(uart_position)($28)
	move	$2,$3
	addu	$2,$4,$2
	andi	$3,$5,0x00ff
	sb	$3,0($2)
	lbu	$2,5($fp)
	lw	$3,0($fp)
	addu	$2,$3,$2
	lb	$5,0($2)
	lw	$4,%gp_rel(uart_address)($28)
	lw	$3,%gp_rel(uart_position+4)($28)
	lw	$2,%gp_rel(uart_position)($28)
	move	$2,$3
	addiu	$2,$2,1
	addu	$2,$4,$2
	andi	$3,$5,0x00ff
	sb	$3,0($2)
	lw	$5,%gp_rel(uart_position+4)($28)
	lw	$4,%gp_rel(uart_position)($28)
	li	$7,2			# 0x2
	move	$6,$0
	addu	$3,$5,$7
	sltu	$8,$3,$5
	addu	$2,$4,$6
	addu	$4,$8,$2
	move	$2,$4
	sw	$3,%gp_rel(uart_position+4)($28)
	sw	$2,%gp_rel(uart_position)($28)
	nop
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	uart_write_hex
	.size	uart_write_hex, .-uart_write_hex
	.align	2
	.globl	c_strlen
	.set	nomips16
	.set	nomicromips
	.ent	c_strlen
	.type	c_strlen, @function
c_strlen:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	move	$3,$0
	move	$2,$0
	sw	$3,4($fp)
	sw	$2,0($fp)
	b	$L8
	nop

$L9:
	lw	$2,16($fp)
	addiu	$2,$2,1
	sw	$2,16($fp)
	lw	$5,4($fp)
	lw	$4,0($fp)
	li	$7,1			# 0x1
	move	$6,$0
	addu	$3,$5,$7
	sltu	$8,$3,$5
	addu	$2,$4,$6
	addu	$4,$8,$2
	move	$2,$4
	sw	$3,4($fp)
	sw	$2,0($fp)
$L8:
	lw	$2,16($fp)
	lb	$2,0($2)
	bne	$2,$0,$L9
	nop

	lw	$3,4($fp)
	lw	$2,0($fp)
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	c_strlen
	.size	c_strlen, .-c_strlen
	.data
	.align	2
	.type	seckrit, @object
	.size	seckrit, 17
seckrit:
	.ascii	"QSMwX\024Q_El\027\177nx\177\034\000"
	.text
	.align	2
	.globl	decrypt
	.set	nomips16
	.set	nomicromips
	.ent	decrypt
	.type	decrypt, @function
decrypt:
	.frame	$fp,32,$31		# vars= 24, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$fp,28($sp)
	move	$fp,$sp
	sw	$4,32($fp)
	sb	$0,0($fp)
	move	$3,$0
	move	$2,$0
	sw	$3,12($fp)
	sw	$2,8($fp)
	b	$L12
	nop

$L13:
	lui	$2,%hi(seckrit)
	addiu	$3,$2,%lo(seckrit)
	lw	$2,12($fp)
	addu	$2,$3,$2
	lbu	$3,0($2)
	lw	$2,12($fp)
	lw	$4,32($fp)
	addu	$2,$4,$2
	lb	$2,0($2)
	andi	$2,$2,0x00ff
	xor	$2,$3,$2
	andi	$3,$2,0x00ff
	lui	$2,%hi(seckrit)
	addiu	$4,$2,%lo(seckrit)
	lw	$2,12($fp)
	addu	$2,$4,$2
	sb	$3,0($2)
	lui	$2,%hi(seckrit)
	addiu	$3,$2,%lo(seckrit)
	lw	$2,12($fp)
	addu	$2,$3,$2
	lbu	$3,0($2)
	lbu	$2,0($fp)
	xor	$2,$3,$2
	sb	$2,0($fp)
	lw	$5,12($fp)
	lw	$4,8($fp)
	li	$7,1			# 0x1
	move	$6,$0
	addu	$3,$5,$7
	sltu	$8,$3,$5
	addu	$2,$4,$6
	addu	$4,$8,$2
	move	$2,$4
	sw	$3,12($fp)
	sw	$2,8($fp)
$L12:
	lw	$2,8($fp)
	bne	$2,$0,$L20
	nop

	lw	$2,8($fp)
	bne	$2,$0,$L13
	nop

	lw	$2,12($fp)
	sltu	$2,$2,16
	bne	$2,$0,$L13
	nop

$L20:
	lbu	$2,0($fp)
	li	$3,88			# 0x58
	beq	$2,$3,$L15
	nop

	move	$2,$0
	b	$L16
	nop

$L15:
	move	$3,$0
	move	$2,$0
	sw	$3,20($fp)
	sw	$2,16($fp)
	b	$L17
	nop

$L18:
	lui	$2,%hi(seckrit)
	addiu	$3,$2,%lo(seckrit)
	lw	$2,20($fp)
	addu	$2,$3,$2
	lbu	$3,0($2)
	lbu	$2,0($fp)
	xor	$2,$3,$2
	andi	$3,$2,0x00ff
	lui	$2,%hi(seckrit)
	addiu	$4,$2,%lo(seckrit)
	lw	$2,20($fp)
	addu	$2,$4,$2
	sb	$3,0($2)
	lw	$5,20($fp)
	lw	$4,16($fp)
	li	$7,1			# 0x1
	move	$6,$0
	addu	$3,$5,$7
	sltu	$8,$3,$5
	addu	$2,$4,$6
	addu	$4,$8,$2
	move	$2,$4
	sw	$3,20($fp)
	sw	$2,16($fp)
$L17:
	lw	$2,16($fp)
	bne	$2,$0,$L21
	nop

	lw	$2,16($fp)
	bne	$2,$0,$L18
	nop

	lw	$2,20($fp)
	sltu	$2,$2,16
	bne	$2,$0,$L18
	nop

$L21:
	li	$2,1			# 0x1
$L16:
	move	$sp,$fp
	lw	$fp,28($sp)
	addiu	$sp,$sp,32
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	decrypt
	.size	decrypt, .-decrypt
	.rdata
	.align	2
$LC1:
	.ascii	"usage: emulateme [key]\012\000"
	.align	2
$LC2:
	.ascii	"wrong length.\012\000"
	.align	2
$LC3:
	.ascii	"wrong key.\012\000"
	.align	2
$LC4:
	.ascii	"Decrypted: \000"
	.align	2
$LC5:
	.ascii	"\012\000"
	.text
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$fp,32,$31		# vars= 8, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$fp,24($sp)
	move	$fp,$sp
	sw	$4,32($fp)
	sw	$5,36($fp)
	lw	$2,32($fp)
	li	$3,2			# 0x2
	beq	$2,$3,$L23
	nop

	li	$7,23			# 0x17
	move	$6,$0
	lui	$2,%hi($LC1)
	addiu	$4,$2,%lo($LC1)
	jal	uart_write_text
	nop

	li	$2,1			# 0x1
	b	$L24
	nop

$L23:
	lw	$2,36($fp)
	lw	$2,4($2)
	sw	$2,16($fp)
	lw	$4,16($fp)
	jal	c_strlen
	nop

	bne	$2,$0,$L28
	nop

	li	$4,16			# 0x10
	beq	$3,$4,$L29
	nop

$L28:
	li	$7,14			# 0xe
	move	$6,$0
	lui	$2,%hi($LC2)
	addiu	$4,$2,%lo($LC2)
	jal	uart_write_text
	nop

	li	$2,1			# 0x1
	b	$L24
	nop

$L29:
	lw	$4,16($fp)
	jal	decrypt
	nop

	bne	$2,$0,$L27
	nop

	li	$7,11			# 0xb
	move	$6,$0
	lui	$2,%hi($LC3)
	addiu	$4,$2,%lo($LC3)
	jal	uart_write_text
	nop

	li	$2,1			# 0x1
	b	$L24
	nop

$L27:
	li	$7,11			# 0xb
	move	$6,$0
	lui	$2,%hi($LC4)
	addiu	$4,$2,%lo($LC4)
	jal	uart_write_text
	nop

	li	$7,16			# 0x10
	move	$6,$0
	lui	$2,%hi(seckrit)
	addiu	$4,$2,%lo(seckrit)
	jal	uart_write_text
	nop

	li	$7,1			# 0x1
	move	$6,$0
	lui	$2,%hi($LC5)
	addiu	$4,$2,%lo($LC5)
	jal	uart_write_text
	nop

	move	$2,$0
$L24:
	move	$sp,$fp
	lw	$31,28($sp)
	lw	$fp,24($sp)
	addiu	$sp,$sp,32
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 14.2.0"
