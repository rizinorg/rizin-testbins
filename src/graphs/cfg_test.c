// SPDX-FileCopyrightText: 2023 Rot127 <unisono@quyllur.org>
// SPDX-License-Identifier: LGPL-3.0-only

/**
 * \file Tests for CFG generation.
 */

#include <stdbool.h>
#include <stdlib.h>

int main() {
  int a = 0;
  int b = a + rand();
  if (b == 0xfff) {
    goto endless_loop;
  } else if (b == 1) {
    return -1;
  } else if (b == 2) {
    goto return_main;
  }

  while (b > 0) {
    --b;
  }

return_main:
  return 0;

endless_loop:
  goto endless_loop;
}

void endless() {
endless:
  goto endless;
}

void loop() {
  int a = 0;
  while (true) {
    for (int i = 0; i< 10; ++i) {
      a++;
      continue;
    }
    a += 2;
  }
}

void ignore_call() {
  rand();
}
