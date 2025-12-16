// SPDX-FileCopyrightText: 2024 Rot127 <unisono@quyllur.org>
// SPDX-License-Identifier: LGPL-3.0-only

#include <stdint.h>
#include <stdlib.h>

static void *function_0() { return calloc(1, 1); }
static void *function_1() { return malloc(1); }
static void *function_2() { return realloc(NULL, 1); }

typedef void *(*fcn)();

static fcn fcn_arr[] = {
    function_0,
    function_1,
    function_2,
};

/// All calls to alloc functions should be discovered.
/// But only after paths over the iterations are taken.
int main() {
  size_t x = 0;
  for (size_t i = 0; i < 2; ++i) {
    uint8_t *ptr = fcn_arr[i]();
    x += ptr[0];
  }
  return x;
}
