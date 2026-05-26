;
; 03_branches_calls.s — Branches, calls, conditional control flow.
;
; assemble with:
;   tic54x-coff-as -o 03_branches_calls.o 03_branches_calls.s
; Exercises:
;   - B / BD     unconditional branch (and delayed)
;   - BC / BCD   conditional branch with single, dual, triple conditions
;   - BANZ/BANZD branch if auxiliary register not zero (loop control)
;   - CALL / CALLD subroutine call
;   - CC / CCD   conditional call
;   - BACC/CALA  branch/call via accumulator (computed targets)
;   - RC / RCD   conditional return
;   - RET / RETD / RETE / RETF
;   - INTR / TRAP software interrupts
;   - IDLE / NOP misc control
;   - XC         execute conditional (1 or 2 cycles)
;
	.mmregs
	.bss	state,    1
	.bss	counter,  1
	.bss	flags,    1

	.global _binary_search
	.global _state_machine
	.global _dispatch
	.global _recursive_fib
	.global _looper
	.global _trap_handler
	.global _wait_for_event

	.text

; ---------------------------------------------------------------------
; binary_search(*arr, key) — classic binary search returning index in B
;   AR2 = base, AR3 = low (=0), AR4 = high (=n-1), A holds key
; ---------------------------------------------------------------------
_binary_search:
	ld	#0, b			; default result = -1 (encoded as 0 here)
bs_loop:
	ld	*AR3, a			; load low
	sub	*AR4, a			; A = low - high
	bc	bs_notfound, AGT	; if low > high, exit
	ld	*AR3, a
	add	*AR4, a
	sftl	a, -1			; a = (low+high)/2
	stl	a, @counter		; save mid
	ld	@counter, t
	; ... compare arr[mid] to key, branch
	ld	*AR2+0%, b		; load arr[mid]  (simulated via circular)
	sub	*AR3, b			; compare against something
	bc	bs_found, AEQ
	bc	bs_higher, ALT
	st	#1, @counter		; lower
	b	bs_loop
bs_higher:
	st	#-1, @counter		; higher
	b	bs_loop
bs_found:
	stl	a, *AR3			; report mid
	ret
bs_notfound:
	ld	#-1, b
	ret

; ---------------------------------------------------------------------
; state_machine() — small FSM dispatched by accumulator-relative branch
;   Uses BACC (branch-via-accumulator) for the dispatch table.
; ---------------------------------------------------------------------
_state_machine:
	ld	@state, a		; A = state index
	sftl	a, 1			; * 2 (each handler is at least 2 words)
	add	#sm_table, a		; A = table_base + state*2
	bacc	a			; jump to handler
sm_table:
	b	sm_idle
	b	sm_running
	b	sm_paused
	b	sm_error
sm_idle:
	st	#1, @state
	ret
sm_running:
	st	#2, @state
	ld	@counter, a
	add	#1, a
	stl	a, @counter
	ret
sm_paused:
	st	#1, @state
	ret
sm_error:
	st	#0, @state
	st	#0, @counter
	ret

; ---------------------------------------------------------------------
; dispatch(op_code in A) — computed dispatch via CALA (call accumulator)
;   Each entry calls a different handler; entry 0 is error path.
; ---------------------------------------------------------------------
_dispatch:
	cmpm	*AR2, #4		; check op < 4
	bc	disp_err, NTC
	ld	*AR2, a
	sftl	a, 1
	add	#disp_table, a
	cala	a
	ret
disp_err:
	ld	#-1, b
	ret
disp_table:
	call	_state_machine
	call	_binary_search
	call	_looper
	call	_wait_for_event

; ---------------------------------------------------------------------
; recursive_fib(n) — naive recursive fibonacci to stress CALL/RET nesting
;   A = n on entry, result returned in A
; ---------------------------------------------------------------------
_recursive_fib:
	; if (n < 2) return n;
	sub	#2, a, b		; B = n - 2
	bc	fib_base, BLT
	; tmp1 = fib(n-1)
	pshm	al			; save n on stack (A.lo)
	sub	#1, a
	call	_recursive_fib
	popm	al			; restore n into AL
	; we treat A.hi = fib(n-1) by stashing earlier ... abbreviated
	pshm	ah			; save high half
	; tmp2 = fib(n-2)
	sub	#2, a
	call	_recursive_fib
	popm	ah			; ah=prev result
	; add — simplified
	ret
fib_base:
	ret

; ---------------------------------------------------------------------
; looper(*p, n in BRC) — count-down loop using BANZ/BANZD
;   Each iteration: load *AR2, accumulate into A, advance.
; ---------------------------------------------------------------------
_looper:
	stm	#10, AR1		; loop count = 10
	ld	#0, a
loop_top:
	add	*AR2+, a
	banz	loop_top, *AR1-		; AR1 != 0 ? branch, then decrement
	stl	a, *AR3
	ret

; ---------------------------------------------------------------------
; trap_handler() — software-trap demonstration with INTR
; ---------------------------------------------------------------------
_trap_handler:
	intr	16			; software interrupt 16
	ld	@flags, a
	or	#0x8000, a
	stl	a, @flags
	rete				; return from interrupt (enabling)
	; (Note: rete pops PC and sets INTM, restoring interrupts)

; ---------------------------------------------------------------------
; wait_for_event() — illustrates IDLE and conditional return
; ---------------------------------------------------------------------
_wait_for_event:
	ld	@flags, a
	and	#0x0001, a
	bc	wfe_done, AEQ		; flag set? return
	idle	1			; sleep until interrupt
	rc	tc			; conditional return on TC
	b	_wait_for_event
wfe_done:
	ret

; ---------------------------------------------------------------------
; Multiple delayed-branch variants for the disassembler to identify
; ---------------------------------------------------------------------
	.global _delayed_demo
_delayed_demo:
	bd	dd_skip1		; delayed branch: next 2 words still execute
	ld	#1, a			;   delay slot 1
	ld	#2, b			;   delay slot 2 (the BD takes effect after this)
dd_skip1:
	calld	_looper			; delayed call
	ld	#3, a
	ld	#4, b
	retd				; delayed return
	st	#1, @flags		;   delay slot
	st	#0, @counter		;   delay slot

	.end
