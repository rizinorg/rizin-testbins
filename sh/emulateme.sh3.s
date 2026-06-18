! SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
! SPDX-License-Identifier: LGPL-3.0-only
!
! Simple crackme-like program for the SuperH-3 (SH-3) architecture, which
! decrypts a string in memory ("Hello from RzIL!"). It is hand written so that
! the decryption loops use only non-delayed branches (bf) and no delay slots,
! which keeps it straightforward to emulate with RzIL.
!
! Build (SH-3, big endian, freestanding):
!   sh-elf-gcc -m3 -mb -nostdlib -nostartfiles -ffreestanding \
!       -Wl,-e,__start -Wl,-Ttext-segment=0x400000 \
!       -o sh3/emulateme.sh3 src/rzil/emulateme.sh3.s
!
! The algorithm matches src/rzil/emulateme.c: each byte of seckrit is XORed
! with the embedded key while a running parity is accumulated; if the parity
! matches, every byte is XORed once more with that parity.

	.text
	.globl	_start
	.type	_start, @function
	.align	2
_start:
	mov.l	.L_seckrit, r0   ! r0 = &seckrit (base pointer, preserved)
	mov.l	.L_key, r2       ! r2 = &key
	mov	r0, r1           ! r1 = working pointer into seckrit
	mov	#0, r7           ! r7 = parity = 0
	mov	#16, r3          ! r3 = LEN = 16
.L_loop1:
	mov.b	@r1, r4          ! r4 = seckrit[i]
	mov.b	@r2+, r5         ! r5 = key[i] ; r2++
	xor	r5, r4           ! r4 = seckrit[i] ^ key[i]
	mov.b	r4, @r1          ! seckrit[i] = r4
	xor	r4, r7           ! parity ^= seckrit[i]
	add	#1, r1           ! ++i
	dt	r3               ! --LEN ; T = (LEN == 0)
	bf	.L_loop1         ! loop while LEN != 0
	extu.b	r7, r7           ! parity &= 0xff
	mov	#0x58, r6        ! reference parity
	cmp/eq	r6, r7           ! T = (parity == 0x58)
	bf	done             ! bail out on mismatch
	mov	r0, r1           ! r1 = &seckrit (reset)
	mov	#16, r3          ! r3 = LEN = 16
.L_loop2:
	mov.b	@r1, r4          ! r4 = seckrit[i]
	xor	r7, r4           ! r4 ^= parity
	mov.b	r4, @r1          ! seckrit[i] = r4
	add	#1, r1           ! ++i
	dt	r3               ! --LEN ; T = (LEN == 0)
	bf	.L_loop2         ! loop while LEN != 0
	.globl	done
	.type	done, @function
done:
	bra	done             ! spin forever once decrypted
	nop

	.align	2
.L_seckrit:
	.long	seckrit
.L_key:
	.long	key

	.data
	.globl	seckrit
	.type	seckrit, @object
	.size	seckrit, 17
	.align	2
seckrit:
	.byte	0x51, 0x53, 0x4d, 0x77, 0x58, 0x14, 0x51, 0x5f
	.byte	0x45, 0x6c, 0x17, 0x7f, 0x6e, 0x78, 0x7f, 0x1c
	.byte	0x00
	.globl	key
	.type	key, @object
	.size	key, 16
key:
	.ascii	"AnyColourYouLike"
