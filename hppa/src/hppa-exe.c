// SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
// SPDX-License-Identifier: LGPL-3.0-only
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int cmp(const void *a, const void *b) {
	return strcmp(*(char *const *)a, *(char *const *)b);
}

__attribute__((constructor)) static void ctor(void) {
	puts("ctor");
}

__attribute__((destructor)) static void dtor(void) {
	puts("dtor");
}

unsigned divide(unsigned a, unsigned b) {
	return a / b;
}

__attribute__((noinline)) void die(const char *msg) {
	puts(msg);
	abort();
}

int main(int argc, char **argv) {
	qsort(argv, argc, sizeof(*argv), cmp);
	printf("%s %u\n", argv[0], divide(argc, 3));
	if (argc > 5) {
		abort();
	}
	if (argc > 4) {
		die("too many");
	}
	return 0;
}
