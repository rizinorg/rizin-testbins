	.text
	.global _start
_start:
	lim	r0, 0x06cb
	lim	r1, 0x001e
	lim	r2, 0x02d2
	mov	r0, r2
	pshm	r14, r14
	lr	r14, r15
	lr	r1, r0
	ar	r1, r2
	aisp	r3, 5
	aim	r4, 0x0064
	jc	0, end
end:
	lr	r15, r14
	popm	r14, r14
	urs	r15
	nop
