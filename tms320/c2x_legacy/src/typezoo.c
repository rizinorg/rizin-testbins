// SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
// SPDX-License-Identifier: LGPL-3.0-only

/*
 * typezoo.c - a function/signature zoo for the legacy TMS320C2x/C5x.
 *
 * Compiled with the tms320-rs C compiler:
 *     tms320cc --c2x typezoo.c      (big-endian hex image)
 *     tms320cc --c5x -S typezoo.c   (assembly text)
 *
 * Every function has a distinct signature so that analysis has to tell them
 * apart: void/int/char returns, pointer returns, and 0..4 parameters of int,
 * char and pointer type. The call graph is deliberately layered - leaves,
 * single-level callers and a top-level driver - so function boundaries and
 * cross references are both exercised. Recursion is avoided because the
 * compiler allocates parameters and locals statically.
 */

int samples[8];
int total;
char flags;

/* --- leaves: no calls out ------------------------------------------------ */

/* void(void) - pure side effect on a global */
void reset_total(void) {
	total = 0;
}

/* int(void) - no parameters, plain int result */
int get_total(void) {
	return total;
}

/* int(int) - single int parameter */
int square(int x) {
	return x * x;
}

/* int(int, int) - two int parameters */
int add2(int a, int b) {
	return a + b;
}

/* int(int, int, int) - three int parameters */
int add3(int a, int b, int c) {
	return a + b + c;
}

/* int(int, int, int, int) - four int parameters, the declared maxargs */
int add4(int a, int b, int c, int d) {
	return a + b + c + d;
}

/* char(char) - narrow parameter and narrow return */
char to_upper(char ch) {
	if (ch >= 'a') {
		if (ch <= 'z') {
			return ch - 32;
		}
	}
	return ch;
}

/* char(int) - int in, char out */
char low_byte(int v) {
	return v & 0xff;
}

/* int(char) - char in, int out */
int widen(char c) {
	return c;
}

/* int *(void) - pointer return */
int *sample_base(void) {
	return samples;
}

/* --- pointer-taking helpers ---------------------------------------------- */

/* int(int *, int) - pointer plus length */
int sum_array(int *p, int n) {
	int i;
	int s;
	s = 0;
	for (i = 0; i < n; i = i + 1) {
		s = s + p[i];
	}
	return s;
}

/* int(int *, int) - a second pointer consumer, different body */
int max_array(int *p, int n) {
	int i;
	int m;
	m = p[0];
	for (i = 1; i < n; i = i + 1) {
		if (p[i] > m) {
			m = p[i];
		}
	}
	return m;
}

/* void(int *, int, int) - pointer, count, value: writes through the pointer */
void fill_array(int *p, int n, int v) {
	int i;
	for (i = 0; i < n; i = i + 1) {
		p[i] = v;
	}
}

/* char(char *, int) - pointer to char, folds to a single char */
char fold_chars(char *s, int n) {
	int i;
	char acc;
	acc = 0;
	for (i = 0; i < n; i = i + 1) {
		acc = acc ^ s[i];
	}
	return acc;
}

/* --- single-level callers ------------------------------------------------ */

/* int(int) - calls one leaf */
int square_plus_one(int x) {
	return square(x) + 1;
}

/* int(int, int) - calls two different leaves */
int combine(int a, int b) {
	return add2(square(a), square(b));
}

/* int(void) - calls a pointer-returning leaf, then a pointer consumer */
int sum_samples(void) {
	int *base;
	base = sample_base();
	return sum_array(base, 8);
}

/* --- driver -------------------------------------------------------------- */

/* int(void) - the top of the call graph */
int main(void) {
	int i;
	int acc;

	reset_total();
	fill_array(samples, 8, 3);
	for (i = 0; i < 8; i = i + 1) {
		samples[i] = samples[i] + i;
	}

	acc = sum_samples();
	acc = acc + max_array(samples, 8);
	acc = acc + combine(2, 3);
	acc = acc + square_plus_one(4);
	acc = acc + add3(1, 2, 3);
	acc = acc + add4(1, 2, 3, 4);
	acc = acc + widen(to_upper('q'));
	acc = acc + low_byte(0x1234);
	flags = fold_chars("rizin", 5);
	acc = acc + widen(flags);

	total = acc;
	return get_total();
}
