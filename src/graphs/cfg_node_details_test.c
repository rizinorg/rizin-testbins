// SPDX-FileCopyrightText: 2023 Rot127 <unisono@quyllur.org>
// SPDX-License-Identifier: LGPL-3.0-only

/**
 * \file Tests for CFG generation.
 */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct {
  void (*fcn_a)();
  void (*fcn_b)();
} Dummy;

void endless() {
endless:
  goto endless;
}

void print_something() { printf("something"); }

int main() {
  unsigned int a = rand();
  Dummy d = {
    .fcn_a = endless,
    .fcn_b = print_something,
  };
  if (a == 0xdead) {
    // Bad luck
    d.fcn_a();
  } else if (a == 0xc0ffee) {
    abort();
  } else {
    d.fcn_b();
  }
  return a;
}
