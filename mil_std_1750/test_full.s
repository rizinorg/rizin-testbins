; comprehensive test program covering all analysis-relevant
; MIL-STD-1750A instruction categories
	name test
start
	; --- arithmetic ---
	a	r1, value1		; ADD memory
	ar	r1, r2			; ADD register
	aisp	r3, 5			; ADD short immediate
	aim	r4, 100			; ADD immediate
	ab	r12, 4			; ADD base-relative
	abs	r5, r0			; ADS (handled as add)
	incm	2, value1		; INCM
	da	r2, value1		; DA
	dar	r3, r4			; DAR
	fa	r5, value1		; FA float
	far	r6, r7			; FAR
	efa	r0, value1		; EFA extended float
	efar	r2, r4			; EFAR

	; --- subtract ---
	s	r1, value1		; SUB memory
	sr	r1, r2			; SUB register
	sisp	r3, 5			; SUB short immediate
	sim	r4, 50			; SIM
	neg	r5, r0
	decm	1, value1		; DECM
	ds	r2, value1		; DS
	dsr	r3, r4			; DSR
	fs	r5, value1
	fsr	r6, r7
	fneg	r1, r0
	efs	r0, value1
	efsr	r2, r4

	; --- multiply ---
	m	r2, value1		; M memory
	mr	r2, r3			; MR
	misp	r4, 5
	mim	r4, 10
	ms	r2, value1		; MS short
	msr	r3, r4
	dm	r2, value1
	dmr	r4, r6
	fm	r2, value1
	fmr	r4, r6
	efm	r0, value1
	efmr	r2, r4

	; --- divide ---
	d	r2, value1
	dr	r2, r4
	disp	r4, 5
	dim	r4, 5
	dv	r2, value1
	dvr	r4, r6
	dd	r2, value1
	ddr	r4, r6
	fd	r2, value1
	fdr	r4, r6
	efd	r0, value1
	efdr	r2, r4

	; --- logical ---
	and	r1, value1
	andr	r1, r2
	andm	r3, 0xFF
	or	r1, value1
	orr	r1, r2
	orim	r3, 0x0F
	xor	r1, value1
	xorr	r1, r2
	xorm	r3, 0xFF
	n	r1, value1
	nr	r1, r2
	nim	r3, 0xFF

	; --- shifts ---
	sll	r1, 5
	srl	r2, 3
	sra	r3, 4
	slc	r4, 2
	scr	r5, r0
	sar	r6, r0
	slr	r7, r0
	dsll	r2, 3
	dsrl	r2, 1
	dsra	r2, 2
	dslc	r2, 4
	dscr	r0, r0
	dsar	r0, r0
	dslr	r0, r0

	; --- compare ---
	c	r1, value1
	cr	r1, r2
	cisn	r3, 5
	cb	r12, 8
	cbl	r4, value1
	dc	r2, value1
	dcr	r2, r4
	fc	r2, value1
	fcr	r2, r4
	efc	r0, value1
	efcr	r2, r4
	uc	r1, value1
	ucr	r1, r2

	; --- load ---
	l	r1, value1
	lr	r1, r2
	lim	r3, 0x1234
	li	r4, value1
	lisp	r5, 10
	lisn	r6, 5
	lm	5, value1
	lb	r12, 4
	llb	r1, value1
	lub	r2, value1
	dl	r2, value1
	dlr	r2, r4
	dli	r4, value1
	le	r3, value1
	dle	r4, value1
	efl	r0, value1
	lst	value1			; load status

	; --- store ---
	st	r1, value1
	sti	r2, value1
	stm	5, value1
	stb	r12, 6
	stc	5, value1
	stci	5, value1
	stlb	r1, value1
	stub	r2, value1
	dst	r2, value1
	dsti	r4, value1
	ste	r3, value1
	dste	r4, value1
	efst	r0, value1

	; --- bit operations ---
	sb	5, value1
	sbr	3, r2
	sbi	1, value1
	rb	5, value1
	rbr	3, r2
	rbi	1, value1
	tb	5, value1
	tbr	3, r2
	tbi	1, value1
	tsb	2, value1

	; --- mov / exchange ---
	mov	r1, r2
	xbr	r3
	xwr	r5, r6

	; --- stack ---
	pshm	r3, r5
	popm	r3, r5

	; --- io ---
	xio	r1, smk
	xio	r2, rsw
	vio	r3, value1

	; --- calls ---
	js	r15, subroutine		; JS — call
	sjs	r15, subroutine		; SJS — call
	soj	r1, retry		; SOJ — cond jump on subtract

	; --- conditional and unconditional branches (ICR) ---
	bez	end_marker
	bnz	end_marker
	bgt	end_marker
	blt	end_marker
	bge	end_marker
	ble	end_marker
	br	branch_target
branch_target
	bex	2

	; --- jump on condition (memory) ---
	jc	uc, skip
	jci	uc, skip
skip
	; --- BIF — branch on input flag ---
	bif	7

retry
	; --- special ---
	nop
	bpt
end_marker
	urs	r15

subroutine
	nop
	urs	r15

	; --- data section ---
value1	data	0x1234

	end	start
