/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Copyright (C) 2019-2020 Kalray Inc.
 * Author: Jules Maselbas
 */
#define ENTRY(n) n##:
#define ENDPROC(n)
#define EXPORT_SYMBOL(n)

/*
 *	kvx optimized strlen
 *
 *	This implementation of strlen only does aligned memory accesses.
 *	Since we don't know the total length the idea is to do double word
 *	load and stop on the first null byte found. As it's always safe to
 *	read more up to a lower 8-bytes boundary.
 *
 *	This implementation of strlen uses a trick to detect if a double
 *	word contains a null byte [1]:
 *
 *	> #define haszero(v) (((v) - 0x01010101UL) & ~(v) & 0x80808080UL)
 *	> The sub-expression (v - 0x01010101UL), evaluates to a high bit set
 *	> in any byte whenever the corresponding byte in v is zero or greater
 *	> than 0x80. The sub-expression ~v & 0x80808080UL evaluates to high
 *	> bits set in bytes where the byte of v doesn't have its high bit set
 *	> (so the byte was less than 0x80). Finally, by ANDing these two sub-
 *	> expressions the result is the high bits set where the bytes in v
 *	> were zero, since the high bits set due to a value greater than 0x80
 *	> in the first sub-expression are masked off by the second.
 *
 *	[1] http://graphics.stanford.edu/~seander/bithacks.html#ZeroInWord
 *
 *	A second trick is used to get the exact number of characters before
 *	the first null byte in a double word:
 *
 *		clz(sbmmt(zero, 0x0102040810204080))
 *
 *	This trick uses the haszero result which maps null byte to 0x80 and
 *	others value to 0x00. The idea is to count the number of consecutive
 *	null byte in the double word (counting from less significant byte
 *	to most significant byte). To do so, using the bit matrix transpose
 *	will "pack" all high bit (0x80) to the most significant byte (MSB).
 *	It is not possible to count the trailing zeros in this MSB, however
 *	if a byte swap is done before the bit matrix transpose we still have
 *	all the information in the MSB but now we can count the leading zeros.
 *	The instruction sbmmt with the matrix 0x0102040810204080 does exactly
 *	what we need a byte swap followed by a bit transpose.
 *
 *	A last trick is used to handle the first double word misalignment.
 *	This is done by masking off the N lower bytes (excess read) with N
 *	between 0 and 7. The mask is applied on haszero results and will
 *	force the N lower bytes to be considered not null.
 *
 *	This is a C implementation of the algorithm described above:
 *
 *	size_t strlen(char *s) {
 *		uint64_t *p    = (uint64_t *)((uintptr_t)s) & ~0x7;
 *		uint64_t rem   = ((uintptr_t)s) % 8;
 *		uint64_t low   = -0x0101010101010101;
 *		uint64_t high  =  0x8080808080808080;
 *		uint64_t dword, zero;
 *		uint64_t msk, len;
 *
 *		dword = *p++;
 *		zero  = (dword + low) & ~dword & high;
 *		msk   = 0xffffffffffffffff << (rem * 8);
 *		zero &= msk;
 *
 *		while (!zero) {
 *			dword = *p++;
 *			zero  = (dword + low) & ~dword & high;
 *		}
 *
 *		zero = __builtin_kvx_sbmmt8(zero, 0x0102040810204080);
 *		len = ((void *)p - (void *)s) - 8;
 *		len += __builtin_kvx_clzd(zero);
 *
 *		return len;
 *	}
 */

.text
.align 16
ENTRY(strlen)
	andd  $r1 = $r0, ~0x7
	andd  $r2 = $r0,  0x7
	make $r10 = -0x0101010101010101
	make $r11 =  0x8080808080808080
	;;
	ld $r4 = 0[$r1]
	sllw $r2 = $r2, 3
	make $r3 = 0xffffffffffffffff
	;;
	slld $r2 = $r3, $r2
	addd $r5 = $r4, $r10
	andnd $r6 = $r4, $r11
	;;
	andd $r6 = $r6, $r2
	make $r3 = 0
	;;
.loop:
	andd $r4 = $r5, $r6
	addd $r1 = $r1, 0x8
	;;
	cb.dnez $r4? .end
	ld.deqz $r4? $r4 = [$r1]
	;;
	addd $r5 = $r4, $r10
	andnd $r6 = $r4, $r11
	goto .loop
	;;
.end:
	addd $r1 = $r1, -0x8
	sbmmt8 $r4 = $r4, 0x0102040810204080
	;;
	clzd $r4 = $r4
	sbfd $r1 = $r0, $r1
	;;
	addd $r0 = $r4, $r1
	ret
	;;
ENDPROC(strlen)
EXPORT_SYMBOL(strlen)
