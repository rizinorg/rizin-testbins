// SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
// SPDX-License-Identifier: LGPL-3.0-only
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static __thread int counter __attribute__((tls_model("initial-exec")));

static int cmp(const void *a, const void *b) {
	return strcmp(*(char *const *)a, *(char *const *)b);
}

int (*const comparators[])(const void *, const void *) = { cmp };
void (*release)(void *) = free;
const char *names[] = { "first", "second" };

__attribute__((constructor)) static void init(void) {
	counter = 1;
}

int count(const char *s) {
	puts(s);
	counter += strlen(s);
	return counter;
}
