	.file	1 "emulateme.nostd.c"
	.section .mdebug.abiO64
	.previous
	.section .gcc_compiled_long32
	.previous
	.nan	legacy
	.module	fp=64
	.module	oddspreg
	.module	arch=mips4
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
	.mask	0x40000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sd	$fp,8($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	sd	$5,24($fp)
	sd	$0,0($fp)
	b	$L2
	nop

$L3:
	ld	$2,0($fp)
	sll	$3,$2,0
	lw	$2,16($fp)
	addu	$2,$2,$3
	lb	$4,0($2)
	lw	$2,%gp_rel(uart_address)($28)
	ld	$3,%gp_rel(uart_position)($28)
	sll	$3,$3,0
	addu	$2,$2,$3
	andi	$3,$4,0x00ff
	sb	$3,0($2)
	ld	$2,%gp_rel(uart_position)($28)
	daddiu	$2,$2,1
	sd	$2,%gp_rel(uart_position)($28)
	ld	$2,0($fp)
	daddiu	$2,$2,1
	sd	$2,0($fp)
$L2:
	ld	$3,0($fp)
	ld	$2,24($fp)
	sltu	$2,$3,$2
	bne	$2,$0,$L3
	nop

	nop
	nop
	move	$sp,$fp
	ld	$fp,8($sp)
	addiu	$sp,$sp,16
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	uart_write_text
	.size	uart_write_text, .-uart_write_text
	.rdata
	.align	3
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
	.mask	0x40000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sd	$fp,8($sp)
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
	lb	$4,0($2)
	lw	$2,%gp_rel(uart_address)($28)
	ld	$3,%gp_rel(uart_position)($28)
	sll	$3,$3,0
	addu	$2,$2,$3
	andi	$3,$4,0x00ff
	sb	$3,0($2)
	lbu	$2,5($fp)
	lw	$3,0($fp)
	addu	$2,$3,$2
	lb	$4,0($2)
	lw	$3,%gp_rel(uart_address)($28)
	ld	$2,%gp_rel(uart_position)($28)
	sll	$2,$2,0
	addiu	$2,$2,1
	addu	$2,$3,$2
	andi	$3,$4,0x00ff
	sb	$3,0($2)
	ld	$2,%gp_rel(uart_position)($28)
	daddiu	$2,$2,2
	sd	$2,%gp_rel(uart_position)($28)
	nop
	move	$sp,$fp
	ld	$fp,8($sp)
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
	.mask	0x40000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sd	$fp,8($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	sd	$0,0($fp)
	b	$L6
	nop

$L7:
	lw	$2,16($fp)
	addiu	$2,$2,1
	sw	$2,16($fp)
	ld	$2,0($fp)
	daddiu	$2,$2,1
	sd	$2,0($fp)
$L6:
	lw	$2,16($fp)
	lb	$2,0($2)
	bne	$2,$0,$L7
	nop

	ld	$2,0($fp)
	move	$sp,$fp
	ld	$fp,8($sp)
	addiu	$sp,$sp,16
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	c_strlen
	.size	c_strlen, .-c_strlen
	.data
	.align	3
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
	.mask	0x40000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sd	$fp,24($sp)
	move	$fp,$sp
	sw	$4,32($fp)
	sb	$0,0($fp)
	sd	$0,8($fp)
	b	$L10
	nop

$L11:
	lui	$2,%hi(seckrit)
	addiu	$3,$2,%lo(seckrit)
	lw	$2,12($fp)
	addu	$2,$3,$2
	lbu	$3,0($2)
	ld	$2,8($fp)
	sll	$4,$2,0
	lw	$2,32($fp)
	addu	$2,$2,$4
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
	ld	$2,8($fp)
	daddiu	$2,$2,1
	sd	$2,8($fp)
$L10:
	ld	$2,8($fp)
	sltu	$2,$2,16
	bne	$2,$0,$L11
	nop

	lbu	$3,0($fp)
	li	$2,88			# 0x58
	beq	$3,$2,$L12
	nop

	move	$2,$0
	b	$L13
	nop

$L12:
	sd	$0,16($fp)
	b	$L14
	nop

$L15:
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
	ld	$2,16($fp)
	daddiu	$2,$2,1
	sd	$2,16($fp)
$L14:
	ld	$2,16($fp)
	sltu	$2,$2,16
	bne	$2,$0,$L15
	nop

	li	$2,1			# 0x1
$L13:
	move	$sp,$fp
	ld	$fp,24($sp)
	addiu	$sp,$sp,32
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	decrypt
	.size	decrypt, .-decrypt
	.rdata
	.align	3
$LC1:
	.ascii	"usage: emulateme [key]\012\000"
	.align	3
$LC2:
	.ascii	"wrong length.\012\000"
	.align	3
$LC3:
	.ascii	"wrong key.\012\000"
	.align	3
$LC4:
	.ascii	"Decrypted: \000"
	.align	3
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
	.frame	$fp,56,$31		# vars= 8, regs= 2/0, args= 32, gp= 0
	.mask	0xc0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-56
	sd	$31,48($sp)
	sd	$fp,40($sp)
	move	$fp,$sp
	sw	$4,56($fp)
	sw	$5,64($fp)
	lw	$3,56($fp)
	li	$2,2			# 0x2
	beq	$3,$2,$L17
	nop

	li	$5,23			# 0x17
	lui	$2,%hi($LC1)
	addiu	$4,$2,%lo($LC1)
	jal	uart_write_text
	nop

	li	$2,1			# 0x1
	b	$L18
	nop

$L17:
	lw	$2,64($fp)
	lw	$2,4($2)
	sw	$2,32($fp)
	lw	$4,32($fp)
	jal	c_strlen
	nop

	move	$3,$2
	li	$2,16			# 0x10
	beq	$3,$2,$L19
	nop

	li	$5,14			# 0xe
	lui	$2,%hi($LC2)
	addiu	$4,$2,%lo($LC2)
	jal	uart_write_text
	nop

	li	$2,1			# 0x1
	b	$L18
	nop

$L19:
	lw	$4,32($fp)
	jal	decrypt
	nop

	bne	$2,$0,$L20
	nop

	li	$5,11			# 0xb
	lui	$2,%hi($LC3)
	addiu	$4,$2,%lo($LC3)
	jal	uart_write_text
	nop

	li	$2,1			# 0x1
	b	$L18
	nop

$L20:
	li	$5,11			# 0xb
	lui	$2,%hi($LC4)
	addiu	$4,$2,%lo($LC4)
	jal	uart_write_text
	nop

	li	$5,16			# 0x10
	lui	$2,%hi(seckrit)
	addiu	$4,$2,%lo(seckrit)
	jal	uart_write_text
	nop

	li	$5,1			# 0x1
	lui	$2,%hi($LC5)
	addiu	$4,$2,%lo($LC5)
	jal	uart_write_text
	nop

	move	$2,$0
$L18:
	move	$sp,$fp
	ld	$31,48($sp)
	ld	$fp,40($sp)
	addiu	$sp,$sp,56
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 14.2.0"
