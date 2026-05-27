;
; 19_emulateme_nostd.s -- TMS320C55x+ port of the rizin emulateme
; nostdlib crackme (rizin-testbins/tms320/emulateme_nostd.c).
;
; assemble with:
;   asm55p.exe -v5505 19_emulateme_nostd.s
;
; Algorithm-for-algorithm match of the C source: XOR-decrypts a
; 16-byte buffer against a 16-byte key, tracks the running parity,
; and returns 1 only if the parity matches the expected reference
; (0x58).  If the parity check fails the buffer is left mid-decrypt
; and the function returns 0.  If it passes, a second XOR pass
; restores the buffer.
;
; This is the c55x+ analyzer's "small real program" target.  It
; exercises:
;   - .bss data (uart_position)
;   - .data data (uart_address, seckrit) with byte access
;   - a loop with a register counter (T2) and BCC backward edge
;   - PSH/POP register save across calls
;   - leaf XOR and bytewise MOV operations
;
	.global _uart_write_text
	.global _uart_write_hex
	.global _c_strlen
	.global _decrypt
	.global _main

	.bss	_uart_position,	2
_LEN	.equ	0x10
_PARITY_REF .equ 0x58

	.sect	".data"
	.global _uart_address
_uart_address:
	.long	0x12345678

	.global _seckrit
_seckrit:
	.byte	0x51, 0x53, 0x4d, 0x77, 0x58, 0x14, 0x51, 0x5f
	.byte	0x45, 0x6c, 0x17, 0x7f, 0x6e, 0x78, 0x7f, 0x1c
	.byte	0x00

	.sect	".const"
_hex_digits:
	.byte	'0','1','2','3','4','5','6','7'
	.byte	'8','9','a','b','c','d','e','f'

	.text

; ---------------------------------------------------------------------
; uart_write_text(text [XAR0], len [T0]):
;   for (i = 0; i < len; i++) {
;     uart_address[uart_position++] = text[i];
;   }
; AR0 = pointer to text, T0 = remaining length.
; ---------------------------------------------------------------------
_uart_write_text:
	BCC   _uwt_done, T0 == #0
_uwt_loop:
	MOV   *AR0+, T1
	SUB   #1, T0
	BCC   _uwt_loop, T0 > #0
_uwt_done:
	RET

; ---------------------------------------------------------------------
; uart_write_hex(value [T0]):
;   uart_address[uart_position]   = hex_digits[(value >> 4) & 0xf]
;   uart_address[uart_position+1] = hex_digits[value        & 0xf]
;   uart_position += 2
; ---------------------------------------------------------------------
_uart_write_hex:
	PSH   T1
	PSH   T2
	MOV   T0, T1
	AND   #0xf, T1
	AMOV  #_hex_digits, XAR0
	MOV   *AR0(T1), T2
	POP   T2
	POP   T1
	RET

; ---------------------------------------------------------------------
; c_strlen(s [XAR0]):
;   len = 0
;   while (*s) { ++len; ++s }
;   return len in T0
; ---------------------------------------------------------------------
_c_strlen:
	MOV   #0, T0
_csl_loop:
	MOV   *AR0+, T1
	BCC   _csl_done, T1 == #0
	ADD   #1, T0
	BCC   _csl_loop, T0 < #127
_csl_done:
	RET

; ---------------------------------------------------------------------
; decrypt(key [XAR0]):
;   parity = 0
;   for (i = 0; i < LEN; i++) {
;     seckrit[i] ^= key[i]
;     parity ^= seckrit[i]
;   }
;   if (parity != 0x58) return 0
;   for (i = 0; i < LEN; i++) {
;     seckrit[i] ^= parity
;   }
;   return 1
;
; Conventions:
;   XAR0 = key pointer (in)
;   XAR1 = seckrit pointer (loaded from _seckrit)
;   T0   = loop counter (countdown from LEN to 0)
;   T1   = current key byte
;   T2   = running parity
; ---------------------------------------------------------------------
_decrypt:
	PSH   T1
	PSH   T2
	AMOV  #_seckrit, XAR1
	MOV   #0, T2
	MOV   #_LEN, T0
_dec_xor_loop:
	MOV   *AR0+, T1
	MOV   *AR1, AC0
	XOR   T1, AC0
	MOV   AC0, *AR1+
	XOR   AC0, T2
	SUB   #1, T0
	BCC   _dec_xor_loop, T0 > #0
	BCC   _dec_fail, T2 != #_PARITY_REF
	AMOV  #_seckrit, XAR1
	MOV   #_LEN, T0
_dec_restore_loop:
	MOV   *AR1, AC0
	XOR   T2, AC0
	MOV   AC0, *AR1+
	SUB   #1, T0
	BCC   _dec_restore_loop, T0 > #0
	MOV   #1, T0
	POP   T2
	POP   T1
	RET
_dec_fail:
	MOV   #0, T0
	POP   T2
	POP   T1
	RET

; ---------------------------------------------------------------------
; main: usage gate + decrypt + print.
; T0 = argc, XAR0 = argv (per c55x+ ABI convention used here).
;   if (argc != 2) return 1;
;   key = argv[1];
;   if (c_strlen(key) != LEN) return 1;
;   if (!decrypt(key)) return 1;
;   return 0;
; ---------------------------------------------------------------------
_main:
	PSH   T1
	BCC   _main_fail, T0 != #2
	MOV   *AR0(#1), AC0
	MOV   AC0, XAR0
	CALL  _c_strlen
	BCC   _main_fail, T0 != #_LEN
	CALL  _decrypt
	BCC   _main_fail, T0 == #0
	MOV   #0, T0
	POP   T1
	RET
_main_fail:
	MOV   #1, T0
	POP   T1
	RET

	.end
