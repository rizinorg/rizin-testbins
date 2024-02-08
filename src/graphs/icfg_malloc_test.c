// SPDX-FileCopyrightText: 2023 Rot127 <unisono@quyllur.org>
// SPDX-License-Identifier: LGPL-3.0-only

/**
 * \file Tests for iCFG generation.
 */

#include <stdlib.h>

unsigned start() {
  int x = 10;
  void *ptr_m = malloc(x);
  void *ptr_c = calloc(1, x);
  void *ptr_r = realloc(ptr_c, 11);

  return ptr_r == ptr_m;
}

int main() {
  return start() == 0;
}
