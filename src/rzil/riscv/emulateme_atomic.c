/**
 * \file
 * Atomic (A extension) emulateme for RISC-V.
 *
 * Ports algorithms of the other emulatemes (src/rzil/emulateme.nostd.c and src/rzil/riscv/emulateme_cf.c)
 * and keeps all of their mutable state in C11 `_Atomic` objects. The state is only updated through plain
 * C compound assignments, which the compiler turns into A extension instructions:
 *
 *   x += y, x -= y, x++, --x      amoadd
 *   x ^= y, x &= y, x |= y        amoxor, amoand, amoor
 *   x *= y, x >>= y, x %= y, ...  lr/sc loop (there is no AMO for these)
 *   any RMW on an _Atomic u8      masked lr.w/sc.w loop on the containing aligned word
 *
 * State is also never read with a plain load: a plain access of an _Atomic object is a sequentially
 * consistent load or store, which costs a `fence` on each side. Instead, every read reuses the value
 * that the last compound assignment produced (`cur = (v >>= 1)`), and counters use `i++` / `--i`, whose
 * result comes straight out of the amoadd. The one plain load left is the one the compiler puts in front
 * of every lr/sc loop to get the expected value. The only things that can not be written in plain C are
 * amoswap (`atomic_exchange`) and amomin/amomax/amominu/amomaxu (`__c11_atomic_fetch_min/max`, clang only,
 * gcc has no builtin for them). The latter are called with every memory order, so the binary also has
 * the plain, .aq, .rl and .aqrl encodings.
 *
 * Every check writes one letter into `report`: 'A' + index when it passes and '-' when it fails, so
 * after emulating from `_start` up to `emulateme_done`, `ps @ obj.report` shows which part went wrong.
 * Natively (or under qemu-user) the report is printed and the exit status is the number of failures.
 *
 *   A  decrypt          emulateme.nostd decryption, bytes xor-ed in place (lr.w/sc.w on bytes)
 *   B  gcd              binary GCD (shift loops, amoadd, amoswap)
 *   C  isqrt            digit by digit square root (amoadd, lr/sc for >>=)
 *   D  bits             popcount, bit reversal, sieve on a bitmap (amoor, amoand, amoxor)
 *   E  minmax           signed and unsigned extremes of arrays (amomin, amomax, amominu, amomaxu)
 *   F  collatz          multiply/divide/increment chains (lr/sc, amoadd)
 *   G  checksum         Fletcher-16 and FNV-1a (amoadd, amoxor, lr/sc for % and *)
 *   H  vm_run           stack machine with atomic stack, sp and pc (every AMO kind through the opcodes)
 *
 * On rv64 `long` is 64 bits wide, so all `long` state uses the .d forms; on rv32 everything is .w.
 *
 * Build (from test/bins):
 * clang-18 --target=riscv32-unknown-elf -march=rv32imac -mabi=ilp32 -O1 -nostdlib -static -ffreestanding -fno-builtin -mno-relax -fuse-ld=lld -Wl,--no-relax -o elf/riscv/emulateme_atomic.rv32imac src/rzil/riscv/emulateme_atomic.c
 * clang-18 --target=riscv64-unknown-elf -march=rv64imac -mabi=lp64 -O1 -nostdlib -static -ffreestanding -fno-builtin -mno-relax -fuse-ld=lld -Wl,--no-relax -o elf/riscv/emulateme_atomic.rv64imac src/rzil/riscv/emulateme_atomic.c
 *
 * Linker relaxation is disabled so that no code depends on `gp`, the emulation only needs `sp`.
 * Run natively with: qemu-riscv32 elf/riscv/emulateme_atomic.rv32imac; echo $?
 */

#include <stdatomic.h>

#if !defined(__clang__)
#error "amomin/amomax need __c11_atomic_fetch_min/max, build with clang"
#endif

typedef unsigned char u8;
typedef int i32;
typedef unsigned int u32;

#define NOINLINE  __attribute__((noinline))
#define LONG_MAX_ ((long)(~0UL >> 1))
#define LONG_MIN_ (-LONG_MAX_ - 1)

/* One slot per check, see the table above. */
char report[] = "........";

/* ---------------------------------------------------------------------------------------------- */
/* A: emulateme.nostd decryption */

#define LEN        0x10
#define PARITY_REF 0x58

static _Atomic u8 seckrit[LEN] = { 0x51, 0x53, 0x4d, 0x77, 0x58, 0x14, 0x51, 0x5f, 0x45, 0x6c, 0x17, 0x7f, 0x6e, 0x78, 0x7f, 0x1c };

NOINLINE int decrypt(const char *key) {
	_Atomic u8 parity = 0;
	_Atomic u32 i = 0;
	u8 p = 0;
	for (u32 j; (j = i++) < LEN;) {
		p = parity ^= seckrit[j] ^= (u8)key[j];
	}
	if (p != PARITY_REF) {
		return 0;
	}
	for (u32 j; (j = --i) > 0;) {
		seckrit[j - 1] ^= p;
	}
	return 1;
}

static int test_decrypt(void) {
	static const char expect[] = "Hello from RzIL!";
	if (!decrypt("AnyColourYouLike")) {
		return 0;
	}
	for (u32 i = 0; i < LEN; i++) {
		if (seckrit[i] != (u8)expect[i]) {
			return 0;
		}
	}
	return 1;
}

/* ---------------------------------------------------------------------------------------------- */
/* B: binary GCD */

NOINLINE unsigned long gcd(unsigned long a, unsigned long b) {
	if (a == 0) {
		return b;
	}
	if (b == 0) {
		return a;
	}
	/* x and y always hold the current values of u and v */
	_Atomic unsigned long u = a, v = b, shift = 0;
	unsigned long x = a, y = b, s = 0;
	while (((x | y) & 1) == 0) {
		x = u >>= 1;
		y = v >>= 1;
		s = ++shift;
	}
	while ((x & 1) == 0) {
		x = u >>= 1;
	}
	do {
		while ((y & 1) == 0) {
			y = v >>= 1;
		}
		if (x > y) {
			/* u = y and v = x, both exchanges together swap x and y */
			x = atomic_exchange(&v, x);
			y = atomic_exchange(&u, x);
		}
		y = v -= x;
	} while (y != 0);
	return u <<= s;
}

static int test_gcd(void) {
	return gcd(48, 18) == 6 && gcd(0, 7) == 7 && gcd(1071, 462) == 21 && gcd(1UL << 20, 3UL << 12) == 1UL << 12 &&
		gcd(0x7fffffff, 0x7ffffffe) == 1;
}

/* ---------------------------------------------------------------------------------------------- */
/* C: digit by digit integer square root */

NOINLINE u32 isqrt(u32 n) {
	/* the current bit is kept as its index, which steps down by 2 */
	_Atomic u32 num = n, res = 0;
	_Atomic i32 shift = 30;
	u32 x = n, r = 0, b = 1u << 30;
	while (b > x) {
		i32 s = shift -= 2;
		b = s >= 0 ? 1u << s : 0;
	}
	while (b != 0) {
		if (x >= r + b) {
			x = num -= r + b;
			res >>= 1;
			r = res += b;
		} else {
			r = res >>= 1;
		}
		i32 s = shift -= 2;
		b = s >= 0 ? 1u << s : 0;
	}
	return r;
}

static int test_isqrt(void) {
	return isqrt(0) == 0 && isqrt(1) == 1 && isqrt(15) == 3 && isqrt(16) == 4 && isqrt(1000000) == 1000 &&
		isqrt(0xffffffff) == 0xffff;
}

/* ---------------------------------------------------------------------------------------------- */
/* D: bit manipulation */

/* Kernighan: every x &= x - 1 clears the lowest set bit */
NOINLINE u32 popcount(u32 x) {
	_Atomic u32 v = x, n = 0;
	u32 cur = x, cnt = 0;
	while (cur != 0) {
		cnt = ++n;
		cur = v &= cur - 1;
	}
	return cnt;
}

/* Every bit of x is or-ed straight into its mirrored position */
NOINLINE u32 reverse(u32 x) {
	_Atomic u32 out = 0, i = 0;
	u32 r = 0;
	for (u32 j; (j = i++) < 32;) {
		r = out |= ((x >> j) & 1) << (31 - j);
	}
	return r;
}

/* Sieve of Eratosthenes over a 64 bit bitmap, then folds the two halves with xor. */
NOINLINE u32 sieve(void) {
	_Atomic u32 map[2] = { 0, 0 };
	u32 cur[2];
	for (u32 i = 2; i < 64; i++) {
		cur[i / 32] = map[i / 32] |= 1u << (i % 32);
	}
	for (u32 p = 2; p * p < 64; p++) {
		if (!(cur[p / 32] & (1u << (p % 32)))) {
			continue;
		}
		for (u32 m = p * p; m < 64; m += p) {
			cur[m / 32] = map[m / 32] &= ~(1u << (m % 32));
		}
	}
	/* primes below 64 are 0x28208a20a08a28ac, 0xa08a28ac ^ 0x28208a20 == 0x88aaa28c */
	return map[0] ^= cur[1];
}

static int test_bits(void) {
	return popcount(0) == 0 && popcount(0xffffffff) == 32 && popcount(0x80000001) == 2 && reverse(1) == 0x80000000 &&
		reverse(0x12345678) == 0x1e6a2c48 && sieve() == 0x88aaa28c;
}

/* ---------------------------------------------------------------------------------------------- */
/* E: extremes, every memory order once per instruction kind */

struct extremes {
	long min, max;
	unsigned long umin, umax;
	i32 min32, max32;
	u32 umin32, umax32;
};

NOINLINE void extremes(const long *a, u32 len, struct extremes *out) {
	_Atomic long mn = LONG_MAX_, mx = LONG_MIN_;
	_Atomic unsigned long umn = ~0UL, umx = 0;
	_Atomic i32 mn32 = 0x7fffffff, mx32 = -0x7fffffff - 1;
	_Atomic u32 umn32 = ~0u, umx32 = 0;
	_Atomic u32 i = 0;
	for (u32 j; (j = i++) < len;) {
		long v = a[j];
		__c11_atomic_fetch_min(&mn, v, __ATOMIC_RELAXED);
		__c11_atomic_fetch_max(&mx, v, __ATOMIC_ACQUIRE);
		__c11_atomic_fetch_min(&umn, (unsigned long)v, __ATOMIC_RELEASE);
		__c11_atomic_fetch_max(&umx, (unsigned long)v, __ATOMIC_SEQ_CST);
		__c11_atomic_fetch_min(&mn32, (i32)v, __ATOMIC_ACQUIRE);
		__c11_atomic_fetch_max(&mx32, (i32)v, __ATOMIC_RELEASE);
		__c11_atomic_fetch_min(&umn32, (u32)v, __ATOMIC_SEQ_CST);
		__c11_atomic_fetch_max(&umx32, (u32)v, __ATOMIC_RELAXED);
	}
	/* the last fetch with an identity operand reads the result without a plain load */
	out->min = __c11_atomic_fetch_min(&mn, LONG_MAX_, __ATOMIC_RELAXED);
	out->max = __c11_atomic_fetch_max(&mx, LONG_MIN_, __ATOMIC_RELAXED);
	out->umin = __c11_atomic_fetch_min(&umn, ~0UL, __ATOMIC_RELAXED);
	out->umax = __c11_atomic_fetch_max(&umx, 0, __ATOMIC_RELAXED);
	out->min32 = __c11_atomic_fetch_min(&mn32, 0x7fffffff, __ATOMIC_RELAXED);
	out->max32 = __c11_atomic_fetch_max(&mx32, -0x7fffffff - 1, __ATOMIC_RELAXED);
	out->umin32 = __c11_atomic_fetch_min(&umn32, ~0u, __ATOMIC_RELAXED);
	out->umax32 = __c11_atomic_fetch_max(&umx32, 0, __ATOMIC_RELAXED);
}

static int test_minmax(void) {
	/* -1 is the unsigned maximum, 3 the unsigned minimum. The truncated 32 bit values differ on rv64 */
	static const long a[] = { 7, -1, 3, (long)0x7fffffff, -5, 42 };
	struct extremes e;
	extremes(a, sizeof(a) / sizeof(a[0]), &e);
	return e.min == -5 && e.max == 0x7fffffff && e.umin == 3 && e.umax == ~0UL && e.min32 == -5 &&
		e.max32 == 0x7fffffff && e.umin32 == 3 && e.umax32 == ~0u;
}

/* ---------------------------------------------------------------------------------------------- */
/* F: Collatz sequences */

NOINLINE unsigned long collatz_steps(unsigned long n) {
	_Atomic unsigned long v = n, steps = 0;
	unsigned long cur = n, s = 0;
	while (cur != 1) {
		if (cur & 1) {
			v *= 3;
			cur = ++v;
		} else {
			cur = v /= 2;
		}
		s = ++steps;
	}
	return s;
}

static int test_collatz(void) {
	return collatz_steps(1) == 0 && collatz_steps(6) == 8 && collatz_steps(27) == 111 && collatz_steps(97) == 118;
}

/* ---------------------------------------------------------------------------------------------- */
/* G: checksums */

NOINLINE u32 fletcher16(const u8 *data, u32 len) {
	_Atomic u32 a = 0, b = 0, i = 0;
	u32 x = 0, y = 0;
	for (u32 j; (j = i++) < len;) {
		a += data[j];
		x = a %= 255;
		b += x;
		y = b %= 255;
	}
	return (y << 8) | x;
}

NOINLINE u32 fnv1a(const u8 *data, u32 len) {
	_Atomic u32 h = 0x811c9dc5, i = 0;
	u32 x = 0x811c9dc5;
	for (u32 j; (j = i++) < len;) {
		h ^= data[j];
		x = h *= 0x01000193;
	}
	return x;
}

static int test_checksum(void) {
	return fletcher16((const u8 *)"abcde", 5) == 0xc8f0 && fletcher16((const u8 *)"abcdefgh", 8) == 0x0627 &&
		fnv1a((const u8 *)"", 0) == 0x811c9dc5 && fnv1a((const u8 *)"a", 1) == 0xe40c292c &&
		fnv1a((const u8 *)"foobar", 6) == 0xbf9cf968;
}

/* ---------------------------------------------------------------------------------------------- */
/* H: stack machine */

enum { OP_PUSH, OP_ADD, OP_SUB, OP_MUL, OP_AND, OP_OR, OP_XOR, OP_SHL, OP_DUP, OP_SWAP, OP_OVER, OP_DROP, OP_JNZ, OP_HALT };

/*
 * Free stack slots are always zero: pop exchanges the slot with zero and push adds to it. The top of the
 * stack is read by popping it.
 */
NOINLINE long vm_run(const i32 *code) {
	_Atomic long stack[8] = { 0 };
	_Atomic u32 sp = 0, pc = 0;
	for (;;) {
		i32 op = code[pc++];
		switch (op) {
		case OP_PUSH:
			stack[sp++] += code[pc++];
			break;
		case OP_ADD: {
			u32 top = --sp;
			long r = atomic_exchange(&stack[top], 0);
			stack[top - 1] += r;
			break;
		}
		case OP_SUB: {
			u32 top = --sp;
			long r = atomic_exchange(&stack[top], 0);
			stack[top - 1] -= r;
			break;
		}
		case OP_MUL: {
			u32 top = --sp;
			long r = atomic_exchange(&stack[top], 0);
			stack[top - 1] *= r;
			break;
		}
		case OP_AND: {
			u32 top = --sp;
			long r = atomic_exchange(&stack[top], 0);
			stack[top - 1] &= r;
			break;
		}
		case OP_OR: {
			u32 top = --sp;
			long r = atomic_exchange(&stack[top], 0);
			stack[top - 1] |= r;
			break;
		}
		case OP_XOR: {
			u32 top = --sp;
			long r = atomic_exchange(&stack[top], 0);
			stack[top - 1] ^= r;
			break;
		}
		case OP_SHL: {
			u32 top = --sp;
			long r = atomic_exchange(&stack[top], 0);
			stack[top - 1] <<= r;
			break;
		}
		case OP_DUP: {
			u32 top = sp++;
			long t = stack[top - 1] |= 0;
			stack[top] += t;
			break;
		}
		case OP_SWAP: {
			u32 top = sp += 0; /* reads sp through an amoadd */
			long t = atomic_exchange(&stack[top - 1], 0);
			stack[top - 1] += atomic_exchange(&stack[top - 2], t);
			break;
		}
		case OP_OVER: {
			u32 top = sp++;
			long t = stack[top - 2] |= 0;
			stack[top] += t;
			break;
		}
		case OP_DROP:
			atomic_exchange(&stack[--sp], 0);
			break;
		case OP_JNZ: {
			/* pc is now operand + 1, jump relative to that */
			u32 operand = pc++;
			if (atomic_exchange(&stack[--sp], 0)) {
				pc += code[operand] - (operand + 1);
			}
			break;
		}
		default:
			return atomic_exchange(&stack[--sp], 0);
		}
	}
}

static int test_vm(void) {
	/* ((((3 + 4) * 5 - 6) << 2 | 1) ^ 0xff) & 0xf0 */
	static const i32 expr[] = {
		OP_PUSH, 3, OP_PUSH, 4, OP_ADD, OP_PUSH, 5, OP_MUL, OP_PUSH, 6, OP_SUB, OP_PUSH, 2, OP_SHL,
		OP_PUSH, 1, OP_OR, OP_PUSH, 0xff, OP_XOR, OP_PUSH, 0xf0, OP_AND, OP_HALT
	};
	/* sum of 1..100 with a countdown loop, stack is [acc, n] */
	static const i32 sum[] = {
		OP_PUSH, 0, OP_PUSH, 100,
		/* 4: */ OP_SWAP, OP_OVER, OP_ADD, OP_SWAP, OP_PUSH, 1, OP_SUB, OP_DUP, OP_JNZ, 4,
		OP_DROP, OP_HALT
	};
	return vm_run(expr) == 0x80 && vm_run(sum) == 5050;
}

/* ---------------------------------------------------------------------------------------------- */

typedef int (*TestFn)(void);

static const TestFn tests[] = {
	test_decrypt,
	test_gcd,
	test_isqrt,
	test_bits,
	test_minmax,
	test_collatz,
	test_checksum,
	test_vm,
};

_Static_assert(sizeof(tests) / sizeof(tests[0]) == sizeof(report) - 1, "one report slot per test");

NOINLINE int run_all(void) {
	int failures = 0;
	for (unsigned i = 0; i < sizeof(tests) / sizeof(tests[0]); i++) {
		int ok = tests[i]();
		report[i] = ok ? 'A' + i : '-';
		failures += !ok;
	}
	return failures;
}

/* Emulation runs from _start up to emulateme_done, the rest only matters when executed natively. */
__asm__(
	".text\n"
	".globl _start\n"
	"_start:\n"
	"	call run_all\n"
	".globl emulateme_done\n"
	"emulateme_done:\n"
	"	mv s0, a0\n"
	"	li a0, 1\n"
	"	lla a1, report\n"
	"	li a2, 8\n"
	"	li a7, 64\n" /* write */
	"	ecall\n"
	"	mv a0, s0\n"
	"	li a7, 93\n" /* exit */
	"	ecall\n");
