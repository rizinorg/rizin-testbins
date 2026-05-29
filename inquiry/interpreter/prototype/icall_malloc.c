// SPDX-FileCopyrightText: 2024 Rot127 <unisono@quyllur.org>
// SPDX-License-Identifier: LGPL-3.0-only

static unsigned long long z = 0;
static void *some_ptr() { return &z; };

static void *function_0() { return some_ptr(); }
static void *function_1() { return some_ptr(); }
static void *function_2() { return some_ptr(); }

typedef void *(*fcn)();

static fcn fcn_arr[] = {
    function_0,
    function_1,
    function_2,
};

/// All calls to alloc functions should be discovered.
/// But only after paths over the iterations are taken.
int main() {
  unsigned x = 0;
  for (unsigned i = 0; i < 3; ++i) {
    unsigned char *ptr = fcn_arr[i]();
    x += ptr[0];
  }
  return x;
}
